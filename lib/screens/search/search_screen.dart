import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<User> _users = [
    User(
      id: '1',
      name: 'Анна',
      age: 25,
      gender: 'female',
      avatarUrl: '',
      bio: 'Люблю путешествия и хорошую музыку',
      interests: ['Музыка', 'Путешествия', 'Фотография'],
    ),
    User(
      id: '2',
      name: 'Максим',
      age: 28,
      gender: 'male',
      avatarUrl: '',
      bio: 'Спортсмен, люблю активный отдых',
      interests: ['Спорт', 'Горы', 'Книги'],
    ),
    User(
      id: '3',
      name: 'Елена',
      age: 23,
      gender: 'female',
      avatarUrl: '',
      bio: 'Художница, творческий человек',
      interests: ['Искусство', 'Живопись', 'Кино'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.pureBlack,
        elevation: 0,
        title: Text(
          'Поиск',
          style: TextStyle(
            color: AppTheme.toxicYellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.mediumGray, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Аватар
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.toxicYellow,
                  ),
                  child: Center(
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.pureBlack,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Информация о пользователе
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '${user.age} лет',
                        style: TextStyle(
                          color: AppTheme.toxicYellow,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Кнопки действий
                Row(
                  children: [
                    _buildActionButton(Icons.close, Colors.red),
                    SizedBox(width: 8),
                    _buildActionButton(Icons.favorite, AppTheme.toxicYellow),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Биография
            Text(
              user.bio,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
            
            SizedBox(height: 12),
            
            // Интересы
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: user.interests.map((interest) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.toxicYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.toxicYellow, width: 1),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: AppTheme.toxicYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: () {
          // TODO: Реализовать действия
        },
      ),
    );
  }
}