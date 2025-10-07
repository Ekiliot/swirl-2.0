// functions/src/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Инициализация Firebase Admin
admin.initializeApp();

const db = admin.database();
const firestore = admin.firestore();

// Пути в RTDB
const QUEUE_PATH = 'chat_roulette/queue';
const MATCHES_PATH = 'chat_roulette/matches';

// Пути в Firestore
const DIRECT_MESSAGES_PATH = 'direct_messages';

/**
 * Функция для поиска и создания матчей
 */
exports.findMatches = functions.database
  .ref(`${QUEUE_PATH}/{userId}`)
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    
    // Получаем данные пользователя
    const userData = change.after.val();
    
    // Если пользователь удален или не в поиске, пропускаем
    if (!userData || userData.status !== 'searching') {
      return;
    }

    try {
      // Получаем всех пользователей в очереди
      const queueSnapshot = await db.ref(QUEUE_PATH).once('value');
      const queueData = queueSnapshot.val() || {};
      
      const availableUsers = [];
      
      // Фильтруем доступных пользователей
      Object.entries(queueData).forEach(([uid, user]) => {
        if (uid !== userId && user.status === 'searching') {
          availableUsers.push({
            uid,
            ...user,
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
async function createMatch(userId1, userData1, userId2, userData2) {
  const chatId = `${userId1}_${userId2}`;
  
  try {
    // Получаем актуальные данные профилей из Firestore
    const [profile1, profile2] = await Promise.all([
      firestore.collection('Users').doc(userId1).get(),
      firestore.collection('Users').doc(userId2).get()
    ]);
    
    const profileData1 = profile1.exists ? profile1.data() : userData1;
    const profileData2 = profile2.exists ? profile2.data() : userData2;
    
    // Создаем записи матчей в RTDB с актуальными данными
    const match1 = {
      partnerId: userId2,
      partnerName: profileData2.name || userData2.name,
      partnerAvatar: (profileData2.name || userData2.name).charAt(0).toUpperCase(),
      partnerAge: profileData2.age || userData2.age,
      partnerGender: profileData2.gender || userData2.gender,
      partnerInterests: profileData2.interests || userData2.interests,
      chatId,
      createdAt: Date.now(),
    };
    
    const match2 = {
      partnerId: userId1,
      partnerName: profileData1.name || userData1.name,
      partnerAvatar: (profileData1.name || userData1.name).charAt(0).toUpperCase(),
      partnerAge: profileData1.age || userData1.age,
      partnerGender: profileData1.gender || userData1.gender,
      partnerInterests: profileData1.interests || userData1.interests,
      chatId,
      createdAt: Date.now(),
    };

    // Обновляем статусы пользователей на 'connected'
    const updates = {};
    updates[`${QUEUE_PATH}/${userId1}/status`] = 'connected';
    updates[`${QUEUE_PATH}/${userId2}/status`] = 'connected';
    updates[`${MATCHES_PATH}/${userId1}`] = match1;
    updates[`${MATCHES_PATH}/${userId2}`] = match2;

    await db.ref().update(updates);

    // Создаем чат сразу в direct_messages с актуальными данными
    await createDirectChat(chatId, userId1, profileData1, userId2, profileData2);
    
  } catch (error) {
    console.error('Ошибка при создании матча:', error);
    throw error;
  }
}

/**
 * Создание постоянного чата в Firestore
 */
async function createDirectChat(chatId, userId1, userData1, userId2, userData2) {
  const chatData = {
    id: chatId,
    participants: [userId1, userId2],
    participantNames: {
      [userId1]: userData1.name || 'Неизвестно',
      [userId2]: userData2.name || 'Неизвестно',
    },
    participantAvatars: {
      [userId1]: (userData1.name || '?').charAt(0).toUpperCase(),
      [userId2]: (userData2.name || '?').charAt(0).toUpperCase(),
    },
    participantAges: {
      [userId1]: userData1.age || 18,
      [userId2]: userData2.age || 18,
    },
    participantGenders: {
      [userId1]: userData1.gender || 'other',
      [userId2]: userData2.gender || 'other',
    },
    participantInterests: {
      [userId1]: userData1.interests || [],
      [userId2]: userData2.interests || [],
    },
    isTemporary: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastMessage: null,
    lastMessageTime: null,
  };

  await firestore.collection(DIRECT_MESSAGES_PATH).doc(chatId).set(chatData);
}

/**
 * Функция для завершения матча
 */
exports.endMatch = functions.https.onCall(async (data, context) => {
  const userId = context.auth?.uid;
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'Пользователь не авторизован');
  }

  try {
    // Получаем информацию о текущем матче
    const matchSnapshot = await db.ref(`${MATCHES_PATH}/${userId}`).once('value');
    const match = matchSnapshot.val();
    
    if (!match) {
      throw new functions.https.HttpsError('not-found', 'Активный матч не найден');
    }

    const partnerId = match.partnerId;
    const chatId = match.chatId;

    // Удаляем записи матчей
    const updates = {};
    updates[`${MATCHES_PATH}/${userId}`] = null;
    updates[`${MATCHES_PATH}/${partnerId}`] = null;

    // Сбрасываем статусы пользователей на 'searching'
    updates[`${QUEUE_PATH}/${userId}/status`] = 'searching';
    updates[`${QUEUE_PATH}/${partnerId}/status`] = 'searching';

    await db.ref().update(updates);

    // НЕ удаляем чат! Он остается для продолжения общения
    // await deleteDirectChat(chatId);

    return { success: true, message: 'Матч завершен' };
  } catch (error) {
    console.error('Ошибка при завершении матча:', error);
    throw new functions.https.HttpsError('internal', 'Ошибка при завершении матча');
  }
});

/**
 * Функция для удаления чата
 */
exports.deleteChat = functions.https.onCall(async (data, context) => {
  const userId = context.auth?.uid;
  const { chatId } = data;
  
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'Пользователь не авторизован');
  }

  if (!chatId) {
    throw new functions.https.HttpsError('invalid-argument', 'ID чата не указан');
  }

  try {
    // Получаем данные чата
    const chatDoc = await firestore.collection(DIRECT_MESSAGES_PATH).doc(chatId).get();
    
    if (!chatDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Чат не найден');
    }

    const chatData = chatDoc.data();
    
    // Проверяем, что пользователь является участником чата
    if (!chatData.participants.includes(userId)) {
      throw new functions.https.HttpsError('permission-denied', 'Нет доступа к чату');
    }

    // Удаляем сообщения
    const messagesSnapshot = await firestore
      .collection(DIRECT_MESSAGES_PATH)
      .doc(chatId)
      .collection('messages')
      .get();

    const batch = firestore.batch();
    
    messagesSnapshot.docs.forEach((messageDoc) => {
      batch.delete(messageDoc.reference);
    });

    // Удаляем сам чат
    batch.delete(firestore.collection(DIRECT_MESSAGES_PATH).doc(chatId));
    
    await batch.commit();

    return { 
      success: true, 
      message: 'Чат удален',
      chatId: chatId
    };
  } catch (error) {
    console.error('Ошибка при удалении чата:', error);
    throw new functions.https.HttpsError('internal', 'Ошибка при удалении чата: ' + error.message);
  }
});

/**
 * Удаление временного чата
 */
async function deleteDirectChat(chatId) {
  // Удаляем сообщения
  const messagesSnapshot = await firestore
    .collection(DIRECT_MESSAGES_PATH)
    .doc(chatId)
    .collection('messages')
    .get();

  const batch = firestore.batch();
  
  messagesSnapshot.docs.forEach((messageDoc) => {
    batch.delete(messageDoc.ref);
  });

  // Удаляем сам чат
  batch.delete(firestore.collection(DIRECT_MESSAGES_PATH).doc(chatId));
  
  await batch.commit();
}

/**
 * Поиск совместимого партнера
 */
function findCompatiblePartner(user, availableUsers) {
  // Простой алгоритм совместимости
  
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
 */
exports.cleanupOldRecords = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const oneHourAgo = Date.now() - (60 * 60 * 1000);
    
    try {
      // Очищаем старые записи в очереди
      const queueSnapshot = await db.ref(QUEUE_PATH).once('value');
      const queueData = queueSnapshot.val() || {};
      
      const updates = {};
      
      Object.entries(queueData).forEach(([uid, user]) => {
        if (user.joinedAt < oneHourAgo) {
          updates[`${QUEUE_PATH}/${uid}`] = null;
          // Также удаляем связанные матчи
          updates[`${MATCHES_PATH}/${uid}`] = null;
        }
      });
      
      if (Object.keys(updates).length > 0) {
        await db.ref().update(updates);
        console.log(`Очищено ${Object.keys(updates).length / 2} старых записей из очереди и матчей`);
      }
      
    } catch (error) {
      console.error('Ошибка при очистке старых записей:', error);
    }
  });

/**
 * Функция для очистки данных при выходе пользователя
 */
exports.cleanupOnUserLeave = functions.database
  .ref(`${QUEUE_PATH}/{userId}`)
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    
    try {
      // Получаем информацию о матче
      const matchSnapshot = await db.ref(`${MATCHES_PATH}/${userId}`).once();
      const match = matchSnapshot.val();
      
      if (match) {
        const partnerId = match.partnerId;
        const chatId = match.chatId;
        
        // Удаляем матч пользователя
        await db.ref(`${MATCHES_PATH}/${userId}`).remove();
        
        // Если есть партнер, удаляем и его матч
        if (partnerId) {
          await db.ref(`${MATCHES_PATH}/${partnerId}`).remove();
          
          // Сбрасываем статус партнера на 'searching'
          await db.ref(`${QUEUE_PATH}/${partnerId}/status`).set('searching');
        }
        
        // Удаляем временный чат, если он существует
        if (chatId) {
          await deleteDirectChat(chatId);
        }
      } else {
        // Просто удаляем матч, если он есть
        await db.ref(`${MATCHES_PATH}/${userId}`).remove();
      }
      
      console.log(`Очищены данные для пользователя: ${userId}`);
    } catch (error) {
      console.error('Ошибка при очистке данных пользователя:', error);
    }
  });
