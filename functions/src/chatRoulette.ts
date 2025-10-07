// Cloud Functions для чат-рулетки
// Файл: functions/src/chatRoulette.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.database();
const firestore = admin.firestore();

// Пути в RTDB
const QUEUE_PATH = 'chat_roulette/queue';
const MATCHES_PATH = 'chat_roulette/matches';

// Пути в Firestore
const TEMP_CHATS_PATH = 'temp_chats';
const DIRECT_MESSAGES_PATH = 'direct_messages';

interface QueueUser {
  uid: string;
  name: string;
  age: number;
  gender: string;
  interests: string[];
  status: 'searching' | 'connected';
  joinedAt: number;
}

interface Match {
  partnerId: string;
  partnerName: string;
  partnerAvatar: string;
  chatId: string;
  createdAt: number;
}

/**
 * Функция для поиска и создания матчей
 * Запускается при изменении очереди поиска
 */
export const findMatches = functions.database
  .ref(`${QUEUE_PATH}/{userId}`)
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    
    // Получаем данные пользователя
    const userData = change.after.val() as QueueUser;
    
    // Если пользователь удален или не в поиске, пропускаем
    if (!userData || userData.status !== 'searching') {
      return;
    }

    try {
      // Получаем всех пользователей в очереди
      const queueSnapshot = await db.ref(QUEUE_PATH).once('value');
      const queueData = queueSnapshot.val() || {};
      
      const availableUsers: QueueUser[] = [];
      
      // Фильтруем доступных пользователей
      Object.entries(queueData).forEach(([uid, user]) => {
        const userInfo = user as QueueUser;
        if (uid !== userId && userInfo.status === 'searching') {
          availableUsers.push({
            uid,
            ...userInfo,
          });
        }
      });

      // Ищем совместимого пользователя
      const partner = findCompatiblePartner(userData, availableUsers);
      
      if (partner) {
        await createMatch(userId, userData, partner.uid, partner);
      }
      
    } catch (error) {
      console.error('Ошибка при поиске матча:', error);
    }
  });

/**
 * Функция для создания матча между двумя пользователями
 */
async function createMatch(
  userId1: string, 
  userData1: QueueUser, 
  userId2: string, 
  userData2: QueueUser
) {
  const chatId = `${userId1}_${userId2}`;
  
  // Создаем записи матчей в RTDB
  const match1: Match = {
    partnerId: userId2,
    partnerName: userData2.name,
    partnerAvatar: userData2.name.charAt(0).toUpperCase(),
    chatId,
    createdAt: Date.now(),
  };
  
  const match2: Match = {
    partnerId: userId1,
    partnerName: userData1.name,
    partnerAvatar: userData1.name.charAt(0).toUpperCase(),
    chatId,
    createdAt: Date.now(),
  };

  // Обновляем статусы пользователей на 'connected'
  const updates: { [key: string]: any } = {};
  updates[`${QUEUE_PATH}/${userId1}/status`] = 'connected';
  updates[`${QUEUE_PATH}/${userId2}/status`] = 'connected';
  updates[`${MATCHES_PATH}/${userId1}`] = match1;
  updates[`${MATCHES_PATH}/${userId2}`] = match2;

  await db.ref().update(updates);

  // Создаем временный чат в Firestore
  await createTempChat(chatId, userId1, userData1, userId2, userData2);
}

/**
 * Создание временного чата в Firestore
 */
async function createTempChat(
  chatId: string,
  userId1: string,
  userData1: QueueUser,
  userId2: string,
  userData2: QueueUser
) {
  const chatData = {
    id: chatId,
    participants: [userId1, userId2],
    participantNames: {
      [userId1]: userData1.name,
      [userId2]: userData2.name,
    },
    participantAvatars: {
      [userId1]: userData1.name.charAt(0).toUpperCase(),
      [userId2]: userData2.name.charAt(0).toUpperCase(),
    },
    isTemporary: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastMessage: null,
    lastMessageTime: null,
  };

  await firestore.collection(TEMP_CHATS_PATH).doc(chatId).set(chatData);
}

/**
 * Функция для завершения матча
 * Вызывается клиентом при выходе из чата
 */
export const endMatch = functions.https.onCall(async (data, context) => {
  const userId = context.auth?.uid;
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'Пользователь не авторизован');
  }

  try {
    // Получаем информацию о текущем матче
    const matchSnapshot = await db.ref(`${MATCHES_PATH}/${userId}`).once('value');
    const match = matchSnapshot.val() as Match;
    
    if (!match) {
      throw new functions.https.HttpsError('not-found', 'Активный матч не найден');
    }

    const partnerId = match.partnerId;
    const chatId = match.chatId;

    // Удаляем записи матчей
    const updates: { [key: string]: any } = {};
    updates[`${MATCHES_PATH}/${userId}`] = null;
    updates[`${MATCHES_PATH}/${partnerId}`] = null;

    // Сбрасываем статусы пользователей на 'searching'
    updates[`${QUEUE_PATH}/${userId}/status`] = 'searching';
    updates[`${QUEUE_PATH}/${partnerId}/status`] = 'searching';

    await db.ref().update(updates);

    // Удаляем временный чат
    await deleteTempChat(chatId);

    return { success: true };
  } catch (error) {
    console.error('Ошибка при завершении матча:', error);
    throw new functions.https.HttpsError('internal', 'Ошибка при завершении матча');
  }
});

/**
 * Функция для сохранения чата
 * Переносит временный чат в постоянное хранилище
 */
export const saveChat = functions.https.onCall(async (data, context) => {
  const userId = context.auth?.uid;
  const { chatId } = data;
  
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'Пользователь не авторизован');
  }

  if (!chatId) {
    throw new functions.https.HttpsError('invalid-argument', 'ID чата не указан');
  }

  try {
    // Получаем данные временного чата
    const tempChatDoc = await firestore.collection(TEMP_CHATS_PATH).doc(chatId).get();
    
    if (!tempChatDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Чат не найден');
    }

    const tempChatData = tempChatDoc.data()!;
    
    // Проверяем, что пользователь является участником чата
    if (!tempChatData.participants.includes(userId)) {
      throw new functions.https.HttpsError('permission-denied', 'Нет доступа к чату');
    }

    // Создаем постоянный чат
    const permanentChatData = {
      ...tempChatData,
      isTemporary: false,
      savedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Переносим чат в постоянное хранилище
    await firestore.collection(DIRECT_MESSAGES_PATH).doc(chatId).set(permanentChatData);

    // Переносим сообщения
    const messagesSnapshot = await firestore
      .collection(TEMP_CHATS_PATH)
      .doc(chatId)
      .collection('messages')
      .get();

    const batch = firestore.batch();
    
    messagesSnapshot.docs.forEach((messageDoc) => {
      const messageData = messageDoc.data();
      const newMessageRef = firestore
        .collection(DIRECT_MESSAGES_PATH)
        .doc(chatId)
        .collection('messages')
        .doc(messageDoc.id);
      
      batch.set(newMessageRef, messageData);
    });

    await batch.commit();

    // Удаляем временный чат
    await deleteTempChat(chatId);

    return { success: true };
  } catch (error) {
    console.error('Ошибка при сохранении чата:', error);
    throw new functions.https.HttpsError('internal', 'Ошибка при сохранении чата');
  }
});

/**
 * Удаление временного чата
 */
async function deleteTempChat(chatId: string) {
  // Удаляем сообщения
  const messagesSnapshot = await firestore
    .collection(TEMP_CHATS_PATH)
    .doc(chatId)
    .collection('messages')
    .get();

  const batch = firestore.batch();
  
  messagesSnapshot.docs.forEach((messageDoc) => {
    batch.delete(messageDoc.ref);
  });

  // Удаляем сам чат
  batch.delete(firestore.collection(TEMP_CHATS_PATH).doc(chatId));
  
  await batch.commit();
}

/**
 * Поиск совместимого партнера
 */
function findCompatiblePartner(user: QueueUser, availableUsers: QueueUser[]): QueueUser | null {
  // Простой алгоритм совместимости
  // Можно расширить более сложной логикой
  
  for (const candidate of availableUsers) {
    // Проверка возраста (разница не более 10 лет)
    if (Math.abs(user.age - candidate.age) > 10) {
      continue;
    }
    
    // Проверка общих интересов
    const commonInterests = user.interests.filter(interest => 
      candidate.interests.includes(interest)
    );
    
    // Если есть хотя бы один общий интерес, считаем совместимыми
    if (commonInterests.length > 0) {
      return candidate;
    }
  }
  
  // Если не нашли по интересам, берем первого подходящего по возрасту
  for (const candidate of availableUsers) {
    if (Math.abs(user.age - candidate.age) <= 10) {
      return candidate;
    }
  }
  
  return null;
}

/**
 * Функция для очистки старых записей
 * Запускается по расписанию
 */
export const cleanupOldRecords = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const oneHourAgo = Date.now() - (60 * 60 * 1000);
    
    try {
      // Очищаем старые записи в очереди
      const queueSnapshot = await db.ref(QUEUE_PATH).once('value');
      const queueData = queueSnapshot.val() || {};
      
      const updates: { [key: string]: any } = {};
      
      Object.entries(queueData).forEach(([uid, user]) => {
        const userInfo = user as QueueUser;
        if (userInfo.joinedAt < oneHourAgo) {
          updates[`${QUEUE_PATH}/${uid}`] = null;
        }
      });
      
      if (Object.keys(updates).length > 0) {
        await db.ref().update(updates);
        console.log(`Очищено ${Object.keys(updates).length} старых записей из очереди`);
      }
      
    } catch (error) {
      console.error('Ошибка при очистке старых записей:', error);
    }
  });
