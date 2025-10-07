/// Данные интересов для приложения Swirl
/// 
/// Каждый интерес имеет:
/// - Ключ (key) на английском для хранения в Firestore
/// - Лейбл (label) на русском для отображения в UI

class InterestsData {
  /// Максимальное количество интересов, которое можно выбрать
  static const int maxInterests = 13;

  /// Все интересы, сгруппированные по категориям
  /// 
  /// Структура: Map<Название категории, Map<Английский ключ, Русский лейбл>>
  static Map<String, Map<String, String>> getCategoriesForAge(int age) {
    final categories = <String, Map<String, String>>{
      'Активный отдых': activeOutdoor,
      'Спорт': sports,
      'Творчество': creativity,
      'Культура и искусство': culture,
      'Образ жизни': lifestyle,
      'Развлечения': entertainment,
      'Тусовки и вечеринки': parties,
    };

    // Добавляем категорию 18+ только для взрослых
    if (age >= 18) {
      categories['🔞 18+'] = adult18Plus;
    }

    return categories;
  }

  /// Маппинг всех интересов (ключ → лейбл) для отображения выбранных интересов
  static final Map<String, String> allInterestsLabels = {
    ...activeOutdoor,
    ...sports,
    ...creativity,
    ...culture,
    ...lifestyle,
    ...entertainment,
    ...parties,
    ...adult18Plus,
  };

  // ============================================================================
  // КАТЕГОРИИ ИНТЕРЕСОВ
  // ============================================================================

  /// Активный отдых
  static const Map<String, String> activeOutdoor = {
    'travel': 'Путешествия',
    'hiking': 'Походы в горы',
    'camping': 'Кемпинг',
    'fishing': 'Рыбалка',
    'hunting': 'Охота',
    'surfing': 'Серфинг',
    'climbing': 'Скалолазание',
    'skydiving': 'Парашютный спорт',
    'diving': 'Дайвинг',
    'kayaking': 'Каякинг',
    'windsurfing': 'Виндсерфинг',
    'paragliding': 'Парапланеризм',
    'mountaineering': 'Альпинизм',
    'road_trips': 'Путешествия на машине',
  };

  /// Спорт
  static const Map<String, String> sports = {
    // Базовые и популярные
    'sport': 'Спорт',
    'fitness': 'Фитнес',
    'running': 'Бег',
    'cycling': 'Велоспорт',
    'swimming': 'Плавание',
    
    // Силовые виды спорта
    'crossfit': 'Кроссфит',
    'weightlifting': 'Тяжёлая атлетика',
    'powerlifting': 'Пауэрлифтинг',
    'bodybuilding': 'Бодибилдинг',
    'functional_training': 'Функциональный тренинг',
    'streetlifting': 'Стритлифтинг',
    'kettlebell_sport': 'Гиревой спорт',
    'armwrestling': 'Армрестлинг',
    
    // Единоборства
    'boxing': 'Бокс',
    'kickboxing': 'Кикбоксинг',
    'mma': 'MMA',
    'grappling': 'Грэпплинг',
    'bjj': 'Бразильское джиу-джитсу',
    'capoeira': 'Капоэйра',
    'taekwondo': 'Тхэквондо',
    'hapkido': 'Хапкидо',
    'wing_chun': 'Вин Чун',
    'wushu': 'Ушу',
    'sumo': 'Сумо',
    'wrestling': 'Борьба',
    'greco_roman': 'Греко-римская борьба',
    'sambo': 'Самбо',
    'martial_arts': 'Боевые искусства',
    'krav_maga': 'Крав-мага',
    'aikido': 'Айкидо',
    'muay_thai': 'Тайский бокс',
    'judo': 'Дзюдо',
    'karate': 'Каратэ',
    
    // Командные виды спорта
    'football': 'Футбол',
    'basketball': 'Баскетбол',
    'volleyball': 'Волейбол',
    'frisbee': 'Фрисби',
    'rugby': 'Регби',
    'american_football': 'Американский футбол',
    'australian_football': 'Австралийский футбол',
    'field_hockey': 'Хоккей на траве',
    'ice_hockey': 'Хоккей с шайбой',
    'water_polo': 'Водное поло',
    'streetball': 'Стритбол',
    'beach_volleyball': 'Пляжный волейбол',
    'beach_football': 'Пляжный футбол',
    
    // Ракеточные виды спорта
    'tennis': 'Теннис',
    'beach_tennis': 'Пляжный теннис',
    'padel': 'Падел',
    'squash': 'Сквош',
    'badminton': 'Бадминтон',
    'table_tennis': 'Настольный теннис',
    
    // Зимние виды спорта
    'snowboarding': 'Сноубординг',
    'skiing': 'Лыжи',
    'figure_skating': 'Фигурное катание',
    'speedskating': 'Спидскейтинг',
    'short_track': 'Шорт-трек',
    'curling': 'Кёрлинг',
    'bobsleigh': 'Бобслей',
    'skeleton': 'Скелетон',
    'ski_jumping': 'Прыжки с трамплина',
    'freestyle_skiing': 'Фристайл',
    'mogul': 'Могул',
    'halfpipe': 'Хафпайп',
    'slopestyle': 'Слоупстайл',
    'big_air': 'Биг-эйр',
    
    // Водные виды спорта
    'synchronized_swimming': 'Синхронное плавание',
    'diving': 'Прыжки в воду',
    'wakeboarding': 'Вейкбординг',
    'kitesurfing': 'Кайтсерфинг',
    'flyboarding': 'Флайбординг',
    'wakesurfing': 'Вейксерфинг',
    'bodyboarding': 'Бодибординг',
    'skimboarding': 'Скимбординг',
    'sup': 'Станд-ап паддлинг',
    'rafting': 'Рафтинг',
    'river_rafting': 'Сплав по рекам',
    'kayaking': 'Гребля на байдарках',
    'rowing': 'Академическая гребля',
    'dragon_boat': 'Драгонбот',
    
    // Экстрим
    'skateboarding': 'Скейтбординг',
    'rollerblading': 'Ролики',
    'roller_derby': 'Роллер-дерби',
    'parkour': 'Паркур',
    'freerunning': 'Фрираннинг',
    'sport_climbing': 'Спортивное скалолазание',
    'bouldering': 'Боулдеринг',
    'ice_climbing': 'Ледолазание',
    'slackline': 'Слэклайн',
    'highline': 'Хайлайн',
    'base_jumping': 'Бейсджампинг',
    'wingsuit': 'Вингсьют',
    'hang_gliding': 'Дельтапланеризм',
    'parasailing': 'Парасейлинг',
    'paragliding': 'Парапланеризм',
    'mountaineering': 'Альпинизм',
    'surfing': 'Серфинг',
    
    // Гимнастика и акробатика
    'acrobatics': 'Акробатика',
    'gymnastics': 'Спортивная гимнастика',
    'rhythmic_gymnastics': 'Художественная гимнастика',
    'trampoline': 'Батутный спорт',
    'jump_rope': 'Прыжки на скакалке',
    'cheerleading': 'Чирлидинг',
    'pilates': 'Пилатес',
    'zumba': 'Зумба',
    'sports_aerobics': 'Спортивная аэробика',
    
    // Танцы
    'sports_dance': 'Спортивные танцы',
    'breakdance': 'Брейкданс',
    
    // Стрельба и метание
    'archery': 'Стрельба из лука',
    'crossbow': 'Стрельба из арбалета',
    'sport_shooting': 'Спортивная стрельба',
    'darts': 'Дартс',
    'biathlon': 'Биатлон',
    'javelin': 'Метание копья',
    'discus': 'Метание диска',
    'hammer_throw': 'Метание молота',
    'shot_put': 'Толкание ядра',
    
    // Фехтование
    'fencing': 'Фехтование',
    'sabre_fencing': 'Фехтование на саблях',
    'foil_fencing': 'Фехтование на рапирах',
    'epee_fencing': 'Фехтование на шпагах',
    
    // Многоборье и бег
    'triathlon': 'Триатлон',
    'duathlon': 'Дуатлон',
    'pentathlon': 'Пентатлон',
    'heptathlon': 'Гептатлон',
    'decathlon': 'Декатлон',
    'orienteering': 'Спортивное ориентирование',
    'rogaining': 'Рогейн',
    'trail_running': 'Трейлраннинг',
    'skyrunning': 'Скайраннинг',
    'mountain_running': 'Горный бег',
    'cross_country': 'Кросс-кантри',
    'race_walking': 'Спортивная ходьба',
    'marathon': 'Марафоны',
    'ultramarathon': 'Ультрамарафоны',
    
    // Настольные игры как спорт
    'billiards': 'Бильярд',
    'snooker': 'Снукер',
    
    // Конный спорт
    'equestrian': 'Конный спорт',
    'polo': 'Поло',
    'rodeo': 'Родео',
    
    // Автоспорт и мотоспорт
    'motorcycles': 'Мотоциклы',
    'motorsport': 'Автоспорт',
    'retro_cars': 'Ретро-автомобили',
    'drift': 'Дрифт',
    'rally': 'Ралли',
    'karting': 'Картинг',
    'motocross': 'Мотокросс',
    'enduro': 'Эндуро',
    'supermoto': 'Супермото',
    
    // Велоспорт
    'bike_trial': 'Велотриал',
    'bmx_freestyle': 'BMX фристайл',
    'bmx_racing': 'BMX рейсинг',
    'pump_track': 'Памп-трек',
    
    // Другие
    'battle_rope': 'Баттл-ропинг',
    'beach_crossfit': 'Кроссфит на пляже',
  };

  /// Творчество
  static const Map<String, String> creativity = {
    // Цифровое и графический дизайн
    'digital_illustration': 'Цифровая иллюстрация',
    'pixel_art': 'Пиксель-арт',
    'modeling_3d': '3D-моделирование',
    'animation': 'Анимация',
    'stop_motion': 'Стоп-моушн съёмка',
    'sticker_creation': 'Создание стикеров',
    'emoji_design': 'Дизайн эмодзи',
    'hand_typography': 'Ручная типографика',
    'lettering': 'Леттеринг',
    'graphic_design': 'Графический дизайн',
    'uiux_design': 'UI/UX дизайн',
    'logo_design': 'Создание лого',
    'branding': 'Брендинг',
    
    // Кастомизация и прикладное
    'sneaker_painting': 'Роспись кроссовок',
    'clothes_custom': 'Кастомизация шмоток',
    'tattoo_design': 'Тату-дизайн',
    'piercing_sketches': 'Эскизы для пирсинга',
    
    // Медиа-креатив
    'meme_creation': 'Создание мемов',
    'video_essays': 'Видеоэссе',
    'tiktok_editing': 'Монтаж тиктоков',
    'vlogging': 'Влогинг',
    'reels_shooting': 'Съёмка рилсов',
    'ig_filters': 'Создание фильтров для инсты',
    'gif_creation': 'Гифки',
    'logo_animation': 'Анимация логотипов',
    'album_cover_design': 'Дизайн обложек альбомов',
    'party_poster_design': 'Постеры для вечеринок',
    
    // Письменные практики
    'handwriting': 'Ручное письмо',
    'journaling': 'Журналинг',
    'artbooks': 'Артбуки',
    'sketchbook': 'Зарисовки в скетчбуке',
    
    // Живопись и материалы
    'plein_air': 'Пленэрная живопись',
    'watercolor': 'Акварель',
    'gouache': 'Гуашь',
    'oil_painting': 'Масляные краски',
    'acrylic_painting': 'Акриловая роспись',
    'spray_art': 'Спрей-арт',
    'marker_sketches': 'Маркерные скетчи',
    
    // Печать и бумага
    'linocut': 'Линогравюра',
    'stencil_printing': 'Трафаретная печать',
    'silkscreen': 'Шелкография',
    'zines': 'Создание зинов',
    'collage_art': 'Коллажное искусство',
    'photo_manipulation': 'Фотоманипуляции',
    'digital_collage': 'Цифровой коллаж',
    'book_cover_design': 'Дизайн обложек книг',
    'children_illustration': 'Иллюстрации для детей',
    'storyboarding': 'Сторибординг',
    'shot_lists': 'Раскадровки',
    'character_design': 'Создание персонажей',
    
    // Игры и настолки
    'boardgame_design': 'Дизайн настолок',
    'cardgame_design': 'Карточные игры дизайн',
    
    // Рукоделие и текстиль
    'embroidery': 'Ручная вышивка',
    'bead_weaving': 'Плетение бисером',
    'macrame_patterns': 'Макраме узоры',
    'crochet': 'Вязание крючком',
    'knit_blankets': 'Создание пледов',
    'doll_clothes': 'Пошив кукольной одежды',
    'custom_dolls': 'Кастом кукол',
    
    // Миниатюры и театр
    'mini_figures': 'Миниатюрные фигурки',
    'dioramas': 'Диорамы',
    'scene_modeling': 'Моделирование сцен',
    'puppet_theater': 'Кукольный театр',
    'marionettes': 'Марионетки',
    
    // Бумажное творчество
    'mask_making': 'Создание масок',
    'papier_mache': 'Папье-маше',
    'origami_sculptures': 'Оригами-скульптуры',
    'quilling': 'Квиллинг',
    'paper_installations': 'Бумажные инсталляции',
    'paper_cutting': 'Резка по бумаге',
    'scrap_art': 'Скрап-арт',
    'card_design': 'Дизайн открыток',
    'hand_invites': 'Ручные пригласительные',
    'marker_calligraphy': 'Каллиграфия маркерами',
    
    // Боди-арт и пространство
    'henna_tattoos': 'Татуировки хной',
    'body_art': 'Бодиарт (не эротический)',
    'wall_painting': 'Роспись стен',
    'murals': 'Муралы',
    'furniture_decor': 'Декор мебели',
    
    // Апсайклинг и хендмейд
    'upcycling_clothes': 'Апсайклинг шмоток',
    'recycle_old': 'Переработка старья',
    'candle_making': 'Создание свечей',
    'aroma_design': 'Аромадизайн',
    'soap_making': 'Мыловарение',
    'handmade_cosmetics': 'Косметика ручной работы',
    
    // Аудио и подкасты
    'lipsync_video': 'Липсинк-видео',
    'meme_dubbing': 'Озвучка мемов',
    'podcasting': 'Создание подкастов',
    'audio_stories': 'Аудиоистории',
    'sound_design': 'Звуковой дизайн',
    'music_remix': 'Музыкальные ремиксы',
    'loops_beats': 'Лупы и биты',
    'songwriting': 'Написание текстов песен',
    
    // Письмо для соцсетей
    'social_poetry': 'Поэзия для соцсетей',
    'micro_stories': 'Микрорассказы',
    'flash_fiction': 'Флеш-фикшн',
    'free_essays': 'Эссе на свободные темы',
    'creative_blogging': 'Блогинг о творчестве',
    
    // Челленджи и марафоны
    'art_challenges': 'Арт-челленджи',
    'sketch_30days': '30-дневные скетчи',
    'doodling': 'Дудлинг',
    'art_marathons_home': 'Арт-марафоны',
    
    // Комиксы и фан-арт
    'comic_creation': 'Создание комиксов',
    'web_comics': 'Веб-комиксы',
    'fan_art': 'Фан-арт',
    
    // Гейм-арт
    'game_concepts': 'Эскизы для игр',
    'merch_design': 'Дизайн мерча',
    'poster_design': 'Плакатный дизайн',
    'hand_animation': 'Ручная анимация',
    'digital_portraits': 'Цифровые портреты',
    'story_art': 'Арт для сторис',
    'tattoo_sleeve_design': 'Дизайн тату-рукавов',
    'jeans_painting': 'Роспись по джинсам',
    'bag_custom': 'Кастом сумок',
    
    // Терапия
    'home_art_therapy': 'Арт-терапия дома',
  };

  /// Культура и искусство
  static const Map<String, String> culture = {
    // Визуальное искусство
    'gallery_visits': 'Посещение галерей',
    'contemporary_art': 'Современное искусство',
    'classical_painting': 'Классическая живопись',
    'abstract_art': 'Абстракционизм',
    'street_art': 'Стрит-арт',
    'graffiti_tours': 'Граффити туры',
    'art_installations': 'Арт-инсталляции',
    'sculpture': 'Скульптура',
    'photo_artists': 'Фотохудожники',
    'bw_photography': 'Черно-белая фотография',
    'portrait_photography': 'Портретная съёмка',
    'land_art': 'Ленд-арт',
    'performance_art': 'Перформанс-арт',
    'video_art': 'Видеоарт',
    'digital_art': 'Цифровое искусство',
    'nft_collecting': 'NFT коллекционирование',
    'art_criticism': 'Арт-критика',
    
    // Музеи и выставки
    'museums': 'Музеи',
    'museum_tours': 'Музейные походы',
    'art_exhibitions': 'Выставки искусства',
    'antique_art': 'Античное искусство',
    'renaissance': 'Ренессансные шедевры',
    'baroque': 'Барокко вайб',
    'impressionism': 'Импрессионизм',
    'expressionism': 'Экспрессионизм',
    'surrealism': 'Сюрреализм',
    'pop_art': 'Поп-арт',
    'minimalism_art': 'Минимализм в искусстве',
    'conceptual_art': 'Концептуальное искусство',
    'art_brut': 'Арт-брют',
    'op_art': 'Оп-арт',
    'kinetic_art': 'Кинетическое искусство',
    'art_deco': 'Арт-деко',
    
    // Архитектура
    'gothic_architecture': 'Готическая архитектура',
    'modernist_architecture': 'Модернистская архитектура',
    'cathedral_visits': 'Посещение соборов',
    'historic_castles': 'Исторические замки',
    'ruins_tours': 'Экскурсии по руинам',
    
    // Литература
    'reading': 'Чтение книг',
    'literary_readings': 'Литературные чтения',
    'poetry_evenings': 'Поэтические вечера',
    'prose_slams': 'Прозаические слэмы',
    'book_fairs': 'Книжные ярмарки',
    'library_hangouts': 'Библиотечные посиделки',
    'first_edition_collecting': 'Коллекционирование первых изданий',
    'manuscript_books': 'Рукописные книги',
    'literary_cafes': 'Литературные кафе',
    'writing_workshops': 'Писательские воркшопы',
    'text_editing': 'Редактирование текстов',
    'literary_blogs': 'Литературные блоги',
    'fanfiction': 'Фанфикшн сообщества',
    'book_club': 'Книжный клуб',
    'philosophy': 'Философия',
    'literary_debates': 'Литературные дебаты',
    'philosophical_salons': 'Философские салоны',
    'ancient_texts': 'Изучение древних текстов',
    'literary_translations': 'Литературные переводы',
    
    // Театр
    'theater': 'Театр',
    'theater_premieres': 'Театральные премьеры',
    'experimental_theater': 'Экспериментальный театр',
    'immersive_theater': 'Иммерсивные спектакли',
    'street_theater': 'Уличный театр',
    'pantomime': 'Пантомима',
    'musicals': 'Мюзиклы',
    'standup': 'Стендап-комедия',
    
    // Опера и балет
    'opera': 'Опера',
    'opera_productions': 'Оперные постановки',
    'ballet': 'Балет',
    'ballet_performances': 'Балетные спектакли',
    'contemporary_choreography': 'Современная хореография',
    'dance_performances': 'Танцевальные перформансы',
    
    // Музыка
    'music': 'Музыка',
    'classical_music': 'Классическая музыка',
    'baroque_music': 'Барочная музыка',
    'chamber_concerts': 'Камерные концерты',
    'symphonic_orchestras': 'Симфонические оркестры',
    'choral_singing': 'Хоровое пение',
    'organ_concerts': 'Органные концерты',
    'music_salons': 'Музыкальные салоны',
    'vinyl_evenings': 'Виниловые вечера',
    'jazz_music': 'Джаз',
    'jazz_improv': 'Джазовые импровизации',
    'experimental_music': 'Экспериментальная музыка',
    'ethnic_music': 'Этническая музыка',
    'folk_music': 'Фолк-музыка',
    'chanson': 'Шансон',
    'rock_music': 'Рок-музыка',
    'electronic_music': 'Электронная музыка',
    'hiphop_music': 'Хип-хоп',
    'reggae': 'Регги',
    'concerts': 'Концерты',
    'festivals': 'Фестивали',
    'music_archives': 'Музыкальные архивы',
    'sheet_music_collecting': 'Коллекционирование нот',
    'music_lectures': 'Музыкальные лекции',
    
    // Музыкальные инструменты
    'guitar': 'Игра на гитаре',
    'piano': 'Игра на пианино',
    'drums': 'Ударные инструменты',
    'djing': 'DJ-инг',
    'music_production': 'Создание музыки',
    'karaoke': 'Караоке',
    
    // Танцы
    'dancing': 'Танцы',
    'hiphop_dance': 'Танцы хип-хоп',
    'salsa': 'Сальса',
    'ballroom_dancing': 'Бальные танцы',
    'national_dances': 'Национальные танцы',
    
    // Кино
    'cinema': 'Кино',
    'film_festivals': 'Кинофестивали',
    'arthouse_cinema': 'Артхаус кино',
    'cinema_classics': 'Классика кинематографа',
    'documentary_films': 'Документальное кино',
    'short_films': 'Короткометражки',
    'film_forums': 'Кинофорумы',
    'film_lectures': 'Кинолектории',
    'amateur_filmmaking': 'Съёмка любительского кино',
    'video_editing': 'Монтаж видео',
    'screenwriting': 'Сценаристика',
    'film_schools': 'Киношколы',
    'superhero_movies': 'Супергеройские фильмы',
    'sci_fi': 'Фантастика',
    'fantasy': 'Фэнтези',
    'detective': 'Детективы',
    
    // Поп-культура
    'anime': 'Аниме',
    'manga': 'Манга',
    'comics': 'Комиксы',
    'comic_culture': 'Комикс-культура',
    'graphic_novels': 'Графические романы',
    'cosplay': 'Косплей',
    'cultural_memes': 'Культурные мемы',
    
    // История и этнография
    'history': 'История',
    'historical_reenactment': 'Исторические реконструкции',
    'medieval_festivals': 'Средневековые фестивали',
    'renaissance_fairs': 'Ренессансные ярмарки',
    'victorian_balls': 'Викторианские балы',
    'ethnographic_exhibitions': 'Этнографические выставки',
    'folklore_festivals': 'Фольклорные фестивали',
    'cultural_traditions': 'Культурные традиции',
    'mythology': 'Изучение мифов',
    'anthropology': 'Антропология',
    'ethnology': 'Этнология',
    'archaeology_tours': 'Археологические экскурсии',
    
    // Мода и дизайн
    'fashion_museums': 'Музеи моды',
    'costume_history': 'История костюма',
    'vintage_clothing': 'Винтажная одежда',
    'vintage_fashion': 'Винтажная мода',
    'retro_style': 'Ретро-стиль',
    'street_fashion': 'Уличная мода',
    'fashion_exhibitions': 'Модные выставки',
    'clothing_design': 'Дизайн одежды',
    'fashion_illustration': 'Иллюстрация моды',
    'textile_design': 'Текстильный дизайн',
    'book_illustration': 'Книжная иллюстрация',
    
    // Наука и технологии
    'science': 'Наука',
    'technology': 'Технологии',
    
    // Медиа и образование
    'art_journals': 'Арт-журналы',
    'cultural_podcasts': 'Культурные подкасты',
    'art_lectures': 'Лекции по искусству',
    'cultural_blogs': 'Культурные блоги',
    'cultural_tours': 'Культурные туры',
    'library_visits': 'Посещение библиотек',
    'cultural_workshops': 'Культурные воркшопы',
    
    // Арт-терапия и практики
    'art_therapy': 'Арт-терапия',
    'music_therapy': 'Музыкотерапия',
    'art_meditation': 'Арт-медитация',
    
    // Коллекционирование и реставрация
    'print_collecting': 'Коллекционирование гравюр',
    'painting_restoration': 'Реставрация картин',
    'calligraphy_exhibitions': 'Каллиграфические выставки',
    
    // Совместное творчество
    'art_collaborations': 'Арт-коллаборации',
    'museum_quests': 'Музейные квесты',
    'art_marathons': 'Арт-марафоны',
    'art_activism': 'Арт-активизм',
  };

  /// Образ жизни
  static const Map<String, String> lifestyle = {
    'cooking': 'Кулинария',
    'yoga': 'Йога',
    'meditation': 'Медитация',
    'sup_yoga': 'Йога на сапбордах',
    'gardening': 'Садоводство',
    'plant_care': 'Уход за растениями',
    'volunteering': 'Волонтерство',
    'animal_protection': 'Защита животных',
    'ecology': 'Экология',
    'veganism': 'Веганство',
    'vegetarianism': 'Вегетарианство',
    'bbq': 'Барбекю',
    'wine_tasting': 'Дегустация вин',
    'craft_beer': 'Крафтовое пиво',
    'coffee': 'Кофе',
    'tea_ceremony': 'Чайные церемонии',
    'barista': 'Бариста-искусство',
  };

  /// Развлечения
  static const Map<String, String> entertainment = {
    'videogames': 'Видеоигры',
    'board_games': 'Настольные игры',
    'chess': 'Шахматы',
    'poker': 'Покер',
    'astronomy': 'Астрономия',
    'stargazing': 'Наблюдение за звездами',
    'collecting': 'Коллекционирование',
    'programming': 'Программирование',
    'gadgets': 'Гаджеты',
    'vr': 'Виртуальная реальность',
    'drones': 'Дроны',
    'magic': 'Фокусы',
    'illusionism': 'Магия',
    'archaeology': 'Археология',
    'astrology': 'Астрология',
    'tarot': 'Таро',
    'esoterics': 'Эзотерика',
    'travel_blogging': 'Трэвел-блогинг',
    'food_blogging': 'Фуд-блогинг',
    'streaming': 'Стриминг',
  };

  /// Тусовки и вечеринки
  static const Map<String, String> parties = {
    // Ночная жизнь
    'night_parties': 'Ночные тусовки',
    'club_parties': 'Клубные вечеринки',
    'raves': 'Рейвы',
    'techno_parties': 'Техно движухи',
    'house_parties': 'Хаус вечеринки',
    'bar_hopping': 'Бар-хоппинг',
    'pub_crawling': 'Паб-кроулинг',
    
    // Развлечения и шоу
    'karaoke_battles': 'Караоке-баттлы',
    'standup_shows': 'Стендап-шоу',
    'comedy_clubs': 'Комедийные клубы',
    'drag_shows': 'Драг-шоу',
    'burlesque': 'Бурлеск-выступления',
    'cabaret': 'Кабаре ночи',
    
    // Коктейльные вечера
    'cocktail_evenings': 'Коктейльные вечера',
    'pool_parties': 'Вечеринки у бассейна',
    'foam_parties': 'Пенные вечеринки',
    
    // Тематические вечеринки
    'costume_parties': 'Костюмированные тусы',
    'theme_parties': 'Тематические вечеринки',
    'eighties_parties': '80-е вечеринки',
    'nineties_parties': '90-е тусовки',
    'glitter_parties': 'Глиттер-пати',
    'masquerade_balls': 'Маскарадные балы',
    'neon_parties': 'Флуоресцентные вечеринки',
    'retro_disco': 'Ретро-дискотеки',
    
    // Танцевальные вечера
    'latino_parties': 'Латино вечеринки',
    'salsa_nights': 'Сальса ночи',
    'bachata_parties': 'Бачата тусовки',
    'tango_evenings': 'Танго вечера',
    'queer_parties': 'Квир-вечеринки',
    
    // Музыкальные вечера
    'jazz_evenings': 'Джазовые вечера',
    'blues_parties': 'Блюз тусовки',
    'live_concerts': 'Лайв-концерты',
    'music_festivals': 'Музыкальные фестивали',
    'edm_festivals': 'EDM фестивали',
    'rock_concerts': 'Рок-концерты',
    'hiphop_parties': 'Хип-хоп тусы',
    'reggaeton_parties': 'Реггетон вечеринки',
    'country_evenings': 'Кантри вечера',
    'kpop_parties': 'К-поп тусовки',
    
    // Гиковские тусовки
    'anime_parties': 'Аниме-вечеринки',
    'gamer_meetups': 'Геймерские сходки',
    'lan_parties': 'Лан-пати',
    'esports_tournaments': 'Киберспортивные турниры',
    'retro_gaming': 'Ретро-гейминг ночи',
    'vr_parties': 'VR вечеринки',
    'cosplay_parties': 'Косплей вечеринки',
    
    // Культурные вечера
    'art_parties': 'Арт-вечеринки',
    'wine_tastings': 'Винные дегустации',
    'whiskey_evenings': 'Виски вечера',
    'tequila_parties': 'Текила тусы',
    'craft_beer_tastings': 'Крафтовое пиво пробники',
    'coffee_meetups': 'Кофейные посиделки',
    'tea_evenings': 'Чайные вечера',
    'cocktail_classes': 'Коктейль мастер-классы',
    'cooking_parties': 'Кулинарные тусовки',
    
    // Outdoor вечеринки
    'bbq_parties': 'Барбекю вечеринки',
    'sunset_picnics': 'Пикники на закате',
    'night_picnics': 'Ночные пикники',
    'bonfire_hangouts': 'Костровые посиделки',
    'camping_parties': 'Кемпинг тусы',
    'glamping_weekends': 'Глэмпинг уикенды',
    'car_camping': 'Автокемпинг',
    
    // Кино и сериалы
    'drive_in_movies': 'Автокинотеатры',
    'night_screenings': 'Ночные кинопоказы',
    'horror_marathons': 'Хоррор-марафоны',
    'romcom_evenings': 'Ромком вечера',
    'scifi_nights': 'Сай-фай ночи',
    'anime_marathons': 'Аниме марафоны',
    'series_parties': 'Сериальные тусовки',
    'netflix_and_chill': 'Нетфликс и чилл',
    'disney_marathons': 'Дисней марафоны',
    'trash_movie_parties': 'Треш-фильм вечеринки',
    
    // Активные развлечения
    'escape_rooms': 'Квест-комнаты',
    'lasertag_battles': 'Лазертаг баттлы',
    'paintball_parties': 'Пейнтбол движухи',
    'airsoft_parties': 'Страйкбол тусы',
    'archery_tag': 'Арчери таг',
    'bumperball': 'Бампербол',
    'zorbing': 'Зорбинг',
    'trampoline_parks': 'Батутные парки',
    'rope_parks': 'Веревочные парки',
    'karting_races': 'Картинг гонки',
    'racing_simulators': 'Гоночные симуляторы',
    'drift_parties': 'Дрифт-вечеринки',
    'moto_meetups': 'Мото-тусовки',
    
    // Экстрим и спорт
    'roller_parties': 'Роллер-вечеринки',
    'skate_parties': 'Скейт-пати',
    'bmx_meetups': 'BMX тусовки',
    
    // Уличная культура
    'graffiti_jams': 'Граффити джемы',
    'street_art_tours': 'Стрит-арт туры',
    'photo_hunts': 'Фотоохота в городе',
    'flashmobs': 'Флешмобы',
    'street_performances': 'Уличные перформансы',
    
    // Творческие баттлы
    'improv_theater': 'Импров-театр',
    'poetry_slams': 'Поэтические слэмы',
    'open_mics': 'Открытые микрофоны',
    'karaoke_duels': 'Караоке дуэли',
    'beatbox_battles': 'Битбокс баттлы',
    'freestyle_rap': 'Фристайл рэп',
    'dance_battles': 'Танцевальные баттлы',
    'hiphop_jams': 'Хип-хоп джемы',
    'art_jams': 'Арт-джемы',
    'music_jams': 'Музыкальные джемы',
    
    // Интеллектуальные игры
    'quiz_nights': 'Квизовые вечера',
    'pub_quizzes': 'Паб-квизы',
    'trivia_nights': 'Трэш-викторины',
    'mafia_parties': 'Мафия вечеринки',
    'board_game_nights': 'Настолки тусы',
    'poker_nights': 'Покерные ночи',
    'blackjack_evenings': 'Блэкджек вечера',
    'casino_parties': 'Казино тусовки',
    'bingo_parties': 'Бинго вечеринки',
    'lottery_evenings': 'Лотерейные вечера',
    'fun_auctions': 'Аукционы (весёлые)',
    
    // Шоппинг и маркеты
    'thrift_shopping': 'Секонд-хенд шопинг',
    'vintage_markets': 'Винтажные маркеты',
    'flea_markets': 'Блошиные рынки',
    'food_truck_festivals': 'Фуд-трак фестивали',
    'street_food_parties': 'Стрит-фуд тусы',
    'night_markets': 'Ночные маркеты',
    'farmers_markets': 'Фермерские ярмарки',
    
    // Секретные и особые тусовки
    'popup_parties': 'Поп-ап вечеринки',
    'secret_parties': 'Секретные тусовки',
    'apartment_parties': 'Квартирники',
    'loft_parties': 'Лофт-вечеринки',
    'yacht_parties': 'Яхт-пати',
    'beach_parties': 'Пляжные тусовки',
    'open_air_parties': 'Оупен-эйр вечеринки',
    
    // Шоу и инсталляции
    'fireworks_shows': 'Фейерверк шоу',
    'laser_shows': 'Лазерное шоу',
    'light_installations': 'Световые инсталляции',
    'neon_hangouts': 'Неоновые тусовки',

    // Дополнительно: Развлечения (100+ идей)
    // Rooftops & night rides
    'rooftop_parties': 'Тусовки на крышах',
    'night_bike_rides': 'Ночные катания на велике',
    'scooter_drift': 'Дрифт на самокатах',
    'night_skateparks': 'Скейт-парки ночью',

    // Street food & markets
    'street_food_festivals': 'Фестивали уличной еды',
    'night_markets_plus': 'Ночные маркеты (расширенные)',
    'popup_bars': 'Поп-ап бары',

    // Secret & apartment
    'secret_gatherings': 'Секретные вечеринки',
    'apartment_acoustic': 'Квартирники с акустикой',

    // Jams & comedy
    'jam_sessions': 'Джем-сейшны',
    'improv_comedy': 'Импров-комедии',
    'standup_battles': 'Стендап баттлы',
    'poetry_meetups': 'Поэтические тусовки',

    // Quizzes & party games
    'pub_quiz_plus': 'Квизы в пабах (тематические)',
    'trash_trivia': 'Треш-викторины',
    'mafia_friends': 'Мафия с друзьями',
    'board_games_all_night': 'Настолки до утра',
    'card_tournaments': 'Карточные турниры',
    'home_casino_games': 'Казино-игры дома',
    'domino_nights': 'Домино вечера',
    'fun_lotto': 'Лото с приколами',
    'beer_bingo': 'Бинго с пивом',

    // Dress code & themes
    'dress_code_parties': 'Вечеринки с дресс-кодом',
    'pajama_parties': 'Пижамные тусы',
    'retro_parties': 'Ретро-вечеринки',
    'glitter_parties_plus': 'Глиттерные пати',
    'neon_parties_plus': 'Неоновые тусовки (ночные)',
    'masquerades_plus': 'Маскарады',

    // Quests & city games
    'themed_quests': 'Тематические квесты',
    'street_quests': 'Уличные квесты',
    'city_puzzles': 'Городские загадки',

    // Wheels & rollers
    'kart_racing_meets': 'Гонки на картингах',
    'bike_meetups': 'Велосипедные тусы',
    'roller_discos': 'Роллер-дискотеки',
    'dance_flashmobs': 'Танцевальные флешмобы',

    // Street shows & lights
    'street_performances_plus': 'Уличные перформансы (ночью)',
    'fire_shows': 'Огненные шоу',
    'fireworks_parties_plus': 'Фейерверк вечеринки',
    'laser_parties': 'Лазерные шоу (вечеринки)',
    'light_parties': 'Световые тусовки',

    // Picnics & beach & yacht
    'dj_picnics': 'Пикники с диджеем',
    'sunset_bbq': 'Барбекю на закате',
    'beach_parties_plus': 'Пляжные тусовки (ночные)',
    'yacht_parties_plus': 'Яхт-пати (ночные)',
    'boat_rides': 'Катание на катере',
    'kayak_walks': 'Прогулки на каяках',
    'night_sup': 'Ночные сап-борды',
    'foam_parties_plus': 'Пенные вечеринки (ночные)',

    // Water battles
    'water_battles': 'Водные битвы',
    'water_gun_battles': 'Баттлы на водных пистолетах',

    // Walks & adventures
    'park_picnics': 'Пикники в парке',
    'night_walks': 'Ночные прогулки',
    'urban_adventures': 'Городские приключения',
    'urbex': 'Исследование заброшек',

    // Photo & video nights
    'photo_hunt_plus': 'Фотоохота (ночью)',
    'timelapse_shooting': 'Съёмка таймлапсов',
    'night_photoshoots': 'Ночные фотосессии',

    // Cinema outdoors
    'street_cinemas': 'Уличные кинотеатры',
    'stars_screenings': 'Кинопоказы под звездами',
    'horror_nights': 'Хоррор-ночи',
    'romcom_marathons': 'Ромком-марафоны',
    'scifi_evenings': 'Сай-фай вечера',
    'anime_hangouts': 'Аниме посиделки',
    'series_marathons_plus': 'Сериальные марафоны',
    'trash_movies_beer': 'Треш-фильмы с пивом',
    'movie_quizzes': 'Киновикторины',

    // Gaming & VR
    'gamer_nights': 'Геймерские вечера',
    'lan_party_plus': 'Лан-пати (большие)',
    'vr_crowd_games': 'VR-игры с толпой',
    'retro_arcades': 'Ретро-аркады',
    'fighting_tournaments': 'Турниры по файтингам',
    'racing_sim_parties': 'Симуляторы гонок (тусы)',
    'dance_arcades': 'Танцевальные автоматы',
    'esports_meetups': 'Киберспорт тусы',
    'tabletop_rpg': 'Настольные ролевки',

    // Drinks & food
    'rum_tastings': 'Дегустация рома',
    'beer_festivals': 'Пивные фестивали',
    'wine_hangouts': 'Винные тусовки',
    'coffee_parties': 'Кофейные вечеринки',
    'tea_meetups_plus': 'Чайные посиделки',
    'cooking_battles': 'Кулинарные баттлы',
    'pizza_party': 'Пицца-пати',
    'burger_parties': 'Бургерные тусы',
    'sweet_parties': 'Сладкие вечеринки',
    'caramel_workshops': 'Карамельные мастер-классы',
    'chocolate_tastings': 'Шоколадные дегустации',
    'food_truck_meets': 'Фуд-трак тусовки',

    // Markets & fairs
    'night_fairs': 'Ночные ярмарки',
    'vintage_markets_plus': 'Винтажные маркеты (ночные)',
    'flea_bazaars': 'Барахолки',
    'thrift_raids': 'Секонд-хенд рейды',
    'art_fairs': 'Арт-ярмарки',
    'popup_galleries': 'Поп-ап галереи',

    // Music & performances
    'street_concerts': 'Уличные концерты',
    'busking': 'Баскинг (уличные выступления)',
    'dance_jams': 'Танцевальные джемы',
    'rap_battles': 'Рэп-баттлы',
    'beatbox_meetups': 'Битбокс тусовки',
    'karaoke_marathons': 'Караоке-марафоны',
    'playlist_parties': 'Вечеринки с плейлистами',
    'music_quizzes_plus': 'Музыкальные викторины (ночные)',
    'dj_theme_sets': 'Тематические диджей-сеты',
    'retro_radio_nights': 'Ретро-радио вечера',
    'podcast_parties': 'Подкаст-вечеринки',
    
    // Books & art chill
    'book_hangouts': 'Книжные тусовки',
    'art_jams_plus': 'Арт-джемы (ночные)',
    'creative_meetups': 'Креативные посиделки',
  };

  /// Интересы для взрослых (18+)
  static const Map<String, String> adult18Plus = {
    // Романтика и флирт
    'flirting': 'Флирт',
    'blind_dates': 'Свидания вслепую',
    'romantic_dinners': 'Романтические ужины',
    'sexting': 'Секстинг',
    'starry_kisses': 'Поцелуи под звездами',
    'hot_texts': 'Горячие переписки',
    'first_date_sparks': 'Искры на первом свидании',
    'naughty_texting': 'Непристойные сообщения',
    'dick_pics': 'Дик-пики',
    'nude_snaps': 'Голые снэпы',
    'flirty_dms': 'Флиртовые DM',
    'dirty_talk': 'Грязные разговоры',
    'public_flirting': 'Публичный флирт',
    'bar_hookups': 'Знакомства в барах',
    'club_grinding': 'Танцы в клубе',
    'dancefloor_teasing': 'Соблазнение на танцполе',
    
    // Casual отношения
    'fwb': 'Friends with benefits',
    'casual_sex': 'Казуальный секс',
    'booty_calls': 'Бути коллы',
    'hookup_vibes': 'Хукап-вайб',
    'quickies': 'Квики',
    'no_strings_attached': 'Без обязательств',
    'fuck_buddies': 'Факбади',
    'weekend_flings': 'Уикенд-флинг',
    'vacation_hookups': 'Отпускные хукапы',
    'stranger_hookups': 'Незнакомцы',
    'neighbor_fantasies': 'Соседи',
    'party_hookups': 'Вечеринки',
    
    // Базовые практики
    'blowjob': 'Минет',
    'handjob': 'Дрочка',
    'oral_sex': 'Оральный секс',
    'deepthroat': 'Дипсроат',
    'sixty_nine': '69',
    'fingering': 'Фингеринг',
    'pussy_eating': 'Куни',
    'cock_sucking': 'Сосание члена',
    'ball_play': 'Игра с яйцами',
    'rimjobs': 'Римджоб',
    'anal_sex': 'Анальный секс',
    'butt_play': 'Игра с попой',
    
    // Позы
    'doggy_style': 'Догги-стайл',
    'missionary': 'Миссионерская',
    'cowgirl': 'Наездница',
    'reverse_cowgirl': 'Обратная наездница',
    'spooning_sex': 'Ложечкой',
    'standing_sex': 'Стоя',
    'wall_sex': 'У стены',
    
    // Интимность
    'bedroom_games': 'Игры в спальне',
    'erotic_fantasies': 'Эротические фантазии',
    'roleplay_adult': 'Ролевые игры (взрослые)',
    'tantric_sex': 'Тантрический секс',
    'bedroom_experiments': 'Эксперименты в постели',
    'erotic_massage': 'Эротический массаж',
    'sensual_touch': 'Чувственные прикосновения',
    'long_foreplay': 'Долгие прелюдии',
    'outdoor_sex': 'Секс на природе',
    'bedroom_romance': 'Романтика в спальне',
    'candles_roses': 'Свечи и лепестки роз',
    'hot_baths': 'Горячие ванны вдвоём',
    'moaning_loud': 'Громкие стоны',
    'quiet_sex': 'Тихий секс',
    'rough_sex': 'Грубый секс',
    'gentle_sex': 'Нежный секс',
    'slow_fucking': 'Медленный секс',
    'hard_pounding': 'Жёсткий секс',
    'morning_quickies': 'Утренний секс',
    'late_night_sex': 'Ночной секс',
    'bed_breaking': 'Разрушение кровати',
    
    // Места для секса
    'shower_sex': 'Секс в душе',
    'car_quickies': 'Секс в машине',
    'public_sex': 'Публичный секс',
    'park_hookups': 'Секс в парке',
    'beach_banging': 'Секс на пляже',
    'movie_theater_teasing': 'В кинотеатре',
    'club_bathroom_sex': 'Секс в туалете клуба',
    'elevator_quickies': 'Секс в лифте',
    'hotel_sex': 'Секс в отеле',
    'motel_quickies': 'Секс в мотеле',
    'camping_sex': 'Секс в кемпинге',
    'tent_banging': 'Секс в палатке',
    'public_pool_sex': 'Секс в бассейне',
    'hot_tub_fun': 'Секс в джакузи',
    'sauna_sex': 'Секс в сауне',
    'tabletop_fun': 'Секс на столе',
    'couch_hookups': 'Секс на диване',
    'house_party_sex': 'Секс на вечеринке',
    'rooftop_quickies': 'Секс на крыше',
    'balcony_sex': 'Секс на балконе',
    'window_sex': 'Секс у окна',
    'mirror_sex': 'Секс у зеркала',
    
    // Прелюдия и ласки
    'hair_pulling': 'Дёргание за волосы',
    'ass_slapping': 'Шлепки по заднице',
    'neck_kissing': 'Поцелуи в шею',
    'lip_biting': 'Покусывание губ',
    'ear_nibbling': 'Покусывание ушей',
    'thigh_grinding': 'Трение о бёдра',
    'dry_humping': 'Сухой секс',
    'making_out': 'Страстные поцелуи',
    'french_kissing': 'Французские поцелуи',
    'hickeys': 'Засосы',
    'body_kissing': 'Поцелуи по телу',
    'titty_play': 'Игра с сиськами',
    'nipple_sucking': 'Сосание сосков',
    'clit_play': 'Игра с клитором',
    'massage_hookups': 'Массажные хукапы',
    'oily_sex': 'Секс с маслом',
    
    // Игрушки и аксессуары
    'sex_toys': 'Секс-игрушки',
    'vibrators': 'Вибраторы',
    'dildos': 'Дилдо',
    'cock_rings': 'Кольца на член',
    'nipple_clamps': 'Зажимы для сосков',
    'blindfold_sex': 'Секс с завязанными глазами',
    'handcuff_play': 'Наручники',
    'tie_up_quickies': 'Связывание',
    'spanking_sessions': 'Шлёпанье',
    'lube_fun': 'Смазка',
    
    // Ролевые игры
    'roleplay_sex': 'Ролевой секс',
    'teacher_fantasy': 'Учитель',
    'nurse_kink': 'Медсестра',
    'cop_roleplay': 'Полицейский',
    'boss_vibes': 'Босс',
    
    // Внешний вид и стиль
    'lingerie': 'Сексуальное бельё',
    'lingerie_teasing': 'Дразнение в белье',
    'thong_fetish': 'Стринги-фетиш',
    'panties_play': 'Игра с трусиками',
    'naked_cuddles': 'Голые обнимашки',
    'skinny_dipping': 'Купание голышом',
    'striptease': 'Стриптиз',
    'pole_dance': 'Поул-дэнс',
    'erotic_photoshoot': 'Эротические фотосессии',
    'sexual_confidence': 'Сексуальная уверенность',
    
    // BDSM
    'bdsm': 'БДСМ',
    'light_bondage': 'Лёгкий бондаж',
    'kinky': 'Кинки-вайб',
    'submissive': 'Сабмиссив',
    'masochist': 'Мазохист',
    'pain_slut': 'Pain slut',
    
    // Роли и динамика
    'bottom': 'Боттом',
    'power_bottom': 'Пауэр боттом',
    'total_bottom': 'Тотал боттом',
    'switch': 'Свитч',
    'slut': 'Слат',
    'cumdump': 'Камдамп',
    'cumslut': 'Камслат',
    'whore': 'Шлюха',
    'cockslut': 'Кокслат',
    'bitch': 'Сучка',
    'cuckold': 'Куколд',
    'cuckquean': 'Кукквин',
    'hotwife': 'Хотвайф',
    'stag_vixen': 'Стэг/Виксен',
    'voyeurism': 'Вуайеризм',
    'exhibitionism': 'Эксгибиционизм',
    
    // Pet play
    'pet_play': 'Пет плей',
    'puppy_play': 'Паппи плей',
    'kitten_play': 'Киттен плей',
    'pony_play': 'Пони плей',
    
    // Age play
    'little': 'Литл',
    'age_play': 'Эйдж плей',
    'ddlg': 'DDLG (Daddy Dom/Little Girl)',
    'ddlb': 'DDLB (Daddy Dom/Little Boy)',
    'mdlb': 'MDLB (Mommy Dom/Little Boy)',
    'mdlg': 'MDlg (Mommy Dom/little girl)',
    
    // Фем/кросс
    'femboy': 'Фембой',
    'sissy': 'Сисси',
    'sissy_training': 'Сисси-тренинг',
    'forced_feminization': 'Принудительная феминизация',
    'crossdressing': 'Кроссдрессинг',
    'trap': 'Трап',
    'twink': 'Твинк',
    'otoko_no_ko': 'Отоко но ко',
    
    // Гендер и идентичность
    'genderfluid': 'Гендерфлюид',
    'non_binary_kink': 'Нон-бинари кинк',
    'trans_kink': 'Транс кинк',
    
    // Унижение
    'humiliation': 'Унижение',
    'erotic_humiliation': 'Эротическое унижение',
    'verbal_degradation': 'Вербальная деградация',
    'name_calling': 'Обзывательства',
    'slut_shaming': 'Слат-шейминг',
    'objectification': 'Объективация',
    'dehumanization': 'Дегуманизация',
    
    // Использование
    'free_use': 'Свободное использование',
    'use_toy': 'Игрушка для использования',
    'fucktoy': 'Фактой',
    'sex_doll': 'Секс-кукла',
    'human_furniture': 'Человеческая мебель',
    
    // Фут-фетиш
    'boot_worship': 'Поклонение ботинкам',
    'foot_slave': 'Фут-слейв',
    'heel_slut': 'Хил-слат',
    
    // Материалы и одежда
    'latex_fetish': 'Латекс-фетиш',
    'leather_kink': 'Кожаный кинк',
    'rubber_play': 'Резиновый плей',
    'pvc_slut': 'ПВХ-слат',
    'corset_training': 'Корсетный тренинг',
    
    // Целомудрие и контроль
    'chastity': 'Целомудрие',
    'cock_cage': 'Кок-кейдж',
    'orgasm_denial': 'Отказ в оргазме',
    'edging': 'Эджинг',
    'ruined_orgasm': 'Испорченный оргазм',
    'forced_orgasm': 'Принудительный оргазм',
    
    // Анальные практики
    'pegging': 'Пеггинг',
    'strap_on_slut': 'Страпон-слат',
    'prostate_play': 'Простата-плей',
    'anal_training': 'Анальный тренинг',
    'gape_slut': 'Гейп-слат',
    'ass_worship': 'Поклонение заднице',
    'rimjob_receiver': 'Римджоб-ресивер',
    
    // Групповые активности
    'threesome_fun': 'Секс втроём',
    'group_sex': 'Групповой секс',
    'swinger_parties': 'Свингер-вечеринки',
    'open_relationships': 'Открытые отношения',
    'glory_hole': 'Глори-хол',
    'gangbang': 'Гангбанг',
    'bukkake': 'Буккаке',
    'creampie': 'Кримпай',
    'breeding_kink': 'Бридинг-кинк',
    'impregnation_fantasy': 'Фантазия об оплодотворении',
    
    // Игры и развлечения
    'strip_games': 'Стрип-игры',
    'naughty_bets': 'Непристойные пари',
    'truth_or_dare': 'Правда или действие',
    'strip_poker': 'Стрип-покер',
    'body_shots': 'Шоты с тела',
    'tequila_licking': 'Слизывание текилы',
    'whipped_cream_play': 'Игра со взбитыми сливками',
    'chocolate_licking': 'Слизывание шоколада',
    'ice_cube_teasing': 'Дразнение льдом',
    'blindfold_kisses': 'Поцелуи вслепую',
    
    // Онлайн и дистанционное
    'video_call_sex': 'Секс по видеосвязи',
    'phone_sex': 'Телефонный секс',
    'cam_fun': 'Кам-забавы',
    'sexting_all_night': 'Секстинг всю ночь',
    'naughty_selfies': 'Непристойные селфи',
    'erotic_voice_notes': 'Эротические голосовые',
    'flirty_emojis': 'Флиртовые эмодзи',
    'dirty_memes': 'Грязные мемы',
    'porn_watching_together': 'Порно вместе',
    
    // Primal и CNC
    'primal_play': 'Примал-плей',
    'predator_prey': 'Хищник/жертва',
    'cnc': 'CNC (Consensual Non-Consent)',
    'somnophilia': 'Сомнофилия',
    'somno_slut': 'Сомно-слат',
    
    // Рабство и владение
    'pet_slave': 'Пет-слейв',
    'collar_and_leash': 'Ошейник и поводок',
    'slave_24_7': '24/7 слейв',
    'no_limits_sub': 'Саб без ограничений',
    'brat': 'Брат',
    'brat_tamer': 'Укротитель братов',
    'service_sub': 'Сервис-саб',
    'domestic_discipline': 'Домашняя дисциплина',
    
    // Финансовое доминирование
    'findom': 'Финдом',
    'paypig': 'Пейпиг',
    'human_atm': 'Человеческий банкомат',
    'wallet_slave': 'Кошелёк-слейв',
    'blackmail_kink': 'Блэкмейл-кинк',
    'exposure_risk': 'Риск разоблачения',
    
    // Онлайн активности
    'online_humiliation': 'Онлайн-унижение',
    'cam_slut': 'Кам-слат',
    'gooning': 'Гунинг',
    
    // Бимбофикация
    'bimbofication': 'Бимбофикация',
    'himbo': 'Химбо',
    'dumb_slut': 'Тупая шлюха',
    'iq_reduction_fantasy': 'Фантазия о снижении IQ',
    
    // Гипноз и контроль разума
    'hypnosis_kink': 'Гипно-кинк',
    'mind_control': 'Контроль разума',
    'brainwashing': 'Промывание мозгов',
    'sissy_hypno': 'Сисси-гипно',
    
    // Оральные практики
    'cock_worship': 'Поклонение члену',
    'oral_fixation': 'Оральная фиксация',
    'deepthroat_training': 'Дипсроат-тренинг',
    'throat_slut': 'Горло-слат',
    'face_fucking': 'Фейс-факинг',
    'spit_play': 'Слюна-плей',
    
    // Водные игры
    'watersports': 'Уотерспорт',
    'piss_slut': 'Писс-слат',
    
    // Экстремальные практики
    'scat_play': 'Скат-плей',
    'vore_fantasy': 'Вор-фантазия',
    
    // Размер и трансформация
    'giantess': 'Гигантесса',
    'macro_micro': 'Макро/микро',
    'inflation_fetish': 'Инфляция-фетиш',
    'hyper_fetish': 'Гипер-фетиш',
    
    // Фурри
    'furry_kink': 'Фурри-кинк',
    'yiff': 'Йифф',
    'anthro_play': 'Антро-плей',
    
    // Фантастические существа
    'tentacle_fantasy': 'Тентакли-фантазия',
    'monster_fucking': 'Монстро-факинг',
    'oviposition': 'Овипозиция',
    'egg_laying': 'Откладывание яиц',
    
    // Лактация и грудь
    'lactation_kink': 'Лактация-кинк',
    'milking': 'Доение',
    'hucow': 'Хьюкау',
    'human_cow': 'Человеческая корова',
    'breast_worship': 'Поклонение груди',
    'nipple_torture': 'Пытка сосков',
    
    // CBT и генитальные пытки
    'cbt': 'CBT (Cock and Ball Torture)',
    'ballbusting': 'Баллбастинг',
    'genital_spanking': 'Генитальный спанкинг',
    
    // Электро и температура
    'electro_play': 'Электро-плей',
    'e_stim_slut': 'Э-стим слат',
    'wax_play': 'Воск-плей',
    'ice_play': 'Лёд-плей',
    'temperature_kink': 'Температурный кинк',
    
    // Экстремальные edge play
    'needle_play': 'Иглы-плей',
    'blood_play': 'Кровь-плей',
    'knife_play': 'Нож-плей',
    'edge_play': 'Эдж-плей',
    
    // Дыхательные практики
    'breath_play': 'Дыхательный плей',
    'asphyxiation': 'Асфиксия',
    'choking_kink': 'Удушение-кинк',
    
    // Фиггинг
    'figging': 'Фиггинг',
    'ginger_play': 'Имбирный плей',
    'figging_slut': 'Фиггинг-слат',
  };
}

