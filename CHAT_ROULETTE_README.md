# Архитектура чат-рулетки Swirl

## Обзор

Реализована полная архитектура сервиса чат-рулетки согласно техническому заданию. Система использует Firebase Realtime Database для очереди поиска и Firestore для хранения чатов.

## Компоненты системы

### 1. Клиентская часть (Flutter)

#### ChatRouletteService (`lib/services/chat_roulette_service.dart`)
- Управление очередью поиска в RTDB
- Создание и управление временными чатами
- Интеграция с Cloud Functions
- Обработка матчинга пользователей

#### ChatRouletteScreen (`lib/screens/chat_roulette/chat_roulette_screen.dart`)
- Обновленный UI с кнопками управления
- Интеграция с новой архитектурой
- Обработка состояний поиска и чата

### 2. Серверная часть (Cloud Functions)

#### Основные функции (`functions/src/chatRoulette.ts`)
- `findMatches` - автоматический поиск совместимых пользователей
- `endMatch` - завершение матча и очистка данных
- `saveChat` - сохранение чата в постоянное хранилище
- `cleanupOldRecords` - очистка старых записей

### 3. База данных

#### Realtime Database
```
chat_roulette/
├── queue/
│   └── {userId}/
│       ├── uid: string
│       ├── name: string
│       ├── age: number
│       ├── gender: string
│       ├── interests: string[]
│       ├── status: "searching" | "connected"
│       └── joinedAt: timestamp
└── matches/
    └── {userId}/
        ├── partnerId: string
        ├── partnerName: string
        ├── partnerAvatar: string
        ├── chatId: string
        └── createdAt: timestamp
```

#### Firestore
```
temp_chats/
└── {chatId}/
    ├── participants: string[]
    ├── participantNames: object
    ├── participantAvatars: object
    ├── isTemporary: boolean
    ├── createdAt: timestamp
    └── messages/
        └── {messageId}/
            ├── text: string
            ├── senderId: string
            ├── timestamp: timestamp
            └── isRead: boolean

direct_messages/
└── {chatId}/
    ├── participants: string[]
    ├── participantNames: object
    ├── participantAvatars: object
    ├── isTemporary: boolean
    ├── savedAt: timestamp
    └── messages/
        └── {messageId}/
            ├── text: string
            ├── senderId: string
            ├── timestamp: timestamp
            └── isRead: boolean
```

## Логика работы

### 1. Процесс матчинга

1. **Присоединение к очереди**: Пользователь вызывает `joinSearchQueue()`
2. **Автоматический поиск**: Cloud Function `findMatches` находит совместимого партнера
3. **Создание матча**: Создаются записи в RTDB и временный чат в Firestore
4. **Обновление статусов**: Статусы пользователей меняются на "connected"

### 2. Управление чатами

#### Сценарий 1: Выход без сохранения
- Вызывается `endMatch()`
- Удаляется временный чат из Firestore
- Удаляются записи матчей из RTDB
- Статусы пользователей сбрасываются на "searching"

#### Сценарий 2: "Следующий собеседник"
- Вызывается `findNextPartner()`
- Завершается текущий матч
- Пользователь остается в очереди для нового поиска

#### Сценарий 3: Сохранение чата
- Вызывается `saveChat()`
- Чат переносится в `direct_messages`
- Сообщения копируются в постоянное хранилище
- Временный чат удаляется

## Развертывание

### 1. Настройка Firebase

```bash
# Установка Firebase CLI
npm install -g firebase-tools

# Вход в аккаунт
firebase login

# Инициализация проекта
firebase init
```

### 2. Настройка Realtime Database

1. Включите Realtime Database в Firebase Console
2. Установите правила безопасности из `database.rules.json`
3. Настройте индексы при необходимости

### 3. Развертывание Cloud Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 4. Обновление правил Firestore

```bash
firebase deploy --only firestore:rules
```

### 5. Обновление зависимостей Flutter

```bash
flutter pub get
```

## Алгоритм совместимости

Текущий алгоритм проверяет:
1. **Возраст**: Разница не более 10 лет
2. **Интересы**: Наличие общих интересов
3. **Статус**: Только пользователи со статусом "searching"

Можно расширить более сложной логикой:
- Геолокация
- Предпочтения по полу
- Время активности
- История матчей

## Безопасность

### Правила RTDB
- Пользователи могут читать/писать только свои данные
- Валидация структуры данных

### Правила Firestore
- Доступ только для участников чата
- Валидация отправителей сообщений
- Защита от несанкционированного доступа

## Мониторинг и отладка

### Логи Cloud Functions
```bash
firebase functions:log
```

### Мониторинг RTDB
- Используйте Firebase Console для просмотра данных
- Настройте алерты на аномальную активность

### Отладка клиента
- Логи в консоли Flutter
- Проверка состояния через Firebase Console

## Производительность

### Оптимизации
- Индексы для частых запросов
- Очистка старых записей по расписанию
- Батчевые операции для сообщений

### Масштабирование
- Cloud Functions автоматически масштабируются
- RTDB поддерживает до 200,000 одновременных подключений
- Firestore масштабируется горизонтально

## Дальнейшее развитие

1. **Геолокация**: Поиск пользователей поблизости
2. **Уведомления**: Push-уведомления о новых сообщениях
3. **Медиа**: Поддержка изображений и файлов
4. **Видеозвонки**: Интеграция с WebRTC
5. **Аналитика**: Отслеживание метрик использования
