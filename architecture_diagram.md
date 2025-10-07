# Архитектура приложения Swirl

## Общая структура

```
┌─────────────────────────────────────────────────────────────┐
│                        SWIRL APP                            │
│                    (Flutter/Dart)                           │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    MAIN ENTRY POINT                         │
│                    lib/main.dart                           │
│  • Firebase инициализация                                   │
│  • Auth state management                                    │
│  • Theme setup                                              │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION                          │
│                  lib/services/auth_service.dart             │
│  • Firebase Auth integration                               │
│  • Email/Password registration                            │
│  • User profile management                                 │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      SCREENS                               │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   WELCOME       │  │   REGISTRATION  │  │    MAIN     │ │
│  │   SCREEN        │  │   SCREEN        │  │   SCREEN    │ │
│  │                 │  │                 │  │             │ │
│  │ • Login/Reg     │  │ • Age selection  │  │ • Matches   │ │
│  │ • Onboarding    │  │ • Gender pick   │  │ • Messages  │ │
│  │                 │  │ • Name input    │  │ • Profile   │ │
│  │                 │  │ • Email/Pass    │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │     MATCH        │  │      CHAT       │  │   PROFILE   │ │
│  │     SCREEN       │  │     SCREEN      │  │   SCREEN    │ │
│  │                 │  │                 │  │             │ │
│  │ • Card swiper    │  │ • Messages      │  │ • User info │ │
│  │ • Like/Pass      │  │ • Typing        │  │ • Interests │ │
│  │ • Super Like     │  │ • Read status   │  │ • Settings  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│                                                             │
│  ┌─────────────────┐                                       │
│  │   CHAT ROULETTE  │                                       │
│  │     SCREEN       │                                       │
│  │                 │                                       │
│  │ • Random chat   │                                       │
│  │ • Search anim   │                                       │
│  │ • Skeleton UI   │                                       │
│  └─────────────────┘                                       │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      MODELS                                │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │      USER       │  │      CHAT        │  │ INTERESTS   │ │
│  │                 │  │                 │  │   DATA      │ │
│  │ • id            │  │ • id            │  │             │ │
│  │ • name          │  │ • name          │  │ • Categories│ │
│  │ • age           │  │ • lastMessage   │  │ • Labels    │ │
│  │ • gender        │  │ • timestamp     │  │ • 18+ filter│ │
│  │ • avatarUrl     │  │ • avatarUrl     │  │             │ │
│  │ • bio           │  │ • isOnline      │  │             │ │
│  │ • interests     │  │ • unreadCount   │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     SERVICES                               │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │   AUTH SERVICE   │  │ PROFILE SERVICE │                 │
│  │                 │  │                 │                 │
│  │ • register()     │  │ • getProfile()  │                 │
│  │ • login()        │  │ • setProfile()  │                 │
│  │ • logout()       │  │ • updateBio()   │                 │
│  │ • authState()    │  │ • setInterests()│                 │
│  └─────────────────┘  └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                        │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   AUTHENTICATION│  │    FIRESTORE     │  │   STORAGE   │ │
│  │                 │  │                 │  │             │ │
│  │ • User accounts │  │ • Users          │  │ • Avatars   │ │
│  │ • Email/Pass    │  │ • Chats          │  │ • Photos    │ │
│  │ • Sessions      │  │ • Messages       │  │ • Media     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      THEME                                 │
│                  lib/theme/app_theme.dart                   │
│                                                             │
│  • Dark theme (Pure Black + Toxic Yellow)                  │
│  • Montserrat font family                                  │
│  • Custom color palette                                     │
│  • Material 3 design system                                 │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     WIDGETS                                │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   REGISTRATION   │  │    PROFILE      │  │    CHAT     │ │
│  │    WIDGETS       │  │    WIDGETS      │  │   WIDGETS   │ │
│  │                 │  │                 │  │             │ │
│  │ • Age picker     │  │ • Avatar        │  │ • Message   │ │
│  │ • Gender picker  │  │ • Bio editor    │  │   bubble    │ │
│  │ • Name input     │  │ • Interests     │  │ • Typing    │ │
│  │ • Email/Pass     │  │ • Settings      │  │   indicator │ │
│  │ • Progress bar   │  │                 │  │ • Input     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Ключевые особенности архитектуры

### 1. **Слоистая архитектура**
- **Presentation Layer**: Экраны и виджеты
- **Business Logic Layer**: Сервисы и модели
- **Data Layer**: Firebase интеграция

### 2. **State Management**
- StreamBuilder для auth state
- setState для локального состояния
- Firebase streams для real-time данных

### 3. **Navigation Flow**
```
Welcome → Registration → Main Screen
    ↓           ↓            ↓
  Login    Age/Gender/    Match/Chat/
           Name/Email     Profile
```

### 4. **Firebase Integration**
- **Authentication**: Email/Password
- **Firestore**: User profiles, chats, messages
- **Storage**: Avatars and media files

### 5. **UI/UX Features**
- Dark theme с токсично-желтыми акцентами
- Анимации и переходы
- Skeleton loading states
- Swipe gestures для карточек
- Real-time chat с typing indicators

### 6. **Key Dependencies**
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `flutter_card_swiper` для Tinder-like карточек
- `google_fonts` для типографики
- `eva_icons_flutter` для иконок
- `animations` для переходов
