import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../models/interests_data.dart';
import '../../widgets/profile/profile_app_bar.dart';
import '../registration/registration_widgets/age_widget.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/profile_main_info_card.dart';
import '../../widgets/profile/profile_interests_section.dart';
import '../../widgets/profile/profile_action_buttons.dart';
import '../../widgets/profile/profile_settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  AuthUser? _authUser;
  List<String> _interests = [];
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();

    AuthService.instance.authStateChanges.listen((user) async {
      if (!mounted) return;
      setState(() { _authUser = user; });
      await _loadProfile();
    });
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.instance.getProfile();
      if (!mounted) return;
      setState(() {
        _interests = (data?['interests'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _isLoadingProfile = false; });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String get _name => _authUser?.displayName ?? 'Пользователь';
  int get _age => _authUser?.age ?? 18;
  String get _gender => _authUser?.gender ?? '—';
  String _bio = 'Добро пожаловать в Swirl! Заполните профиль, чтобы получить больше матчей.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      extendBodyBehindAppBar: true,
      appBar: ProfileAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: _isLoadingProfile
                ? Center(child: CircularProgressIndicator(color: AppTheme.toxicYellow))
                : SingleChildScrollView(
              padding: EdgeInsets.only(top: 90, bottom: 20),
              child: Column(
                children: [
                        ProfileAvatar(name: _name, isOnline: true),
                  SizedBox(height: 24),
                        ProfileMainInfoCard(
                          name: _name,
                          age: _age,
                          gender: _gender,
                          bio: _bio,
                          onEditBio: _showEditBioSheet,
                        ),
                  SizedBox(height: 24),
                  
                        ProfileInterestsSection(
                          interests: _interests,
                          onAddPressed: _showInterestCategoriesSheet,
                          onRemoveInterest: (interest) async {
                            await ProfileService.instance.removeInterest(interest);
                            setState(() { _interests.remove(interest); });
                          },
                        ),
                  SizedBox(height: 24),
                        ProfileActionButtons(
                          onEditPressed: _showEditProfileDialog,
                          onSettingsPressed: _showSettingsDialog,
                        ),
                  SizedBox(height: 24),
                        ProfileSettingsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // INTEREST SELECTOR SHEET
  // ============================================================================

  void _showInterestCategoriesSheet() {
    final interestsByCategory = InterestsData.getCategoriesForAge(_age);
    final int maxPick = InterestsData.maxInterests;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) {
        Set<String> picked = Set<String>.from(_interests);
        Set<String> expandedCategories = <String>{};
        String searchQuery = '';
        final TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void toggle(String key) {
              final already = picked.contains(key);
              if (already) {
                picked.remove(key);
              } else {
                if (picked.length >= maxPick) return;
                picked.add(key);
              }
              setSheetState(() {});
            }
            
            void toggleCategory(String category) {
              if (expandedCategories.contains(category)) {
                expandedCategories.remove(category);
              } else {
                expandedCategories.add(category);
              }
              setSheetState(() {});
            }
            
            // Filter interests by search query
            Map<String, Map<String, String>> filteredCategories = {};
            if (searchQuery.isEmpty) {
              filteredCategories = interestsByCategory;
            } else {
              for (var entry in interestsByCategory.entries) {
                final categoryName = entry.key;
                final items = entry.value;
                final filteredItems = Map<String, String>.fromEntries(
                  items.entries.where((item) =>
                    item.value.toLowerCase().contains(searchQuery.toLowerCase())
                  )
                );
                if (filteredItems.isNotEmpty) {
                  filteredCategories[categoryName] = filteredItems;
                  expandedCategories.add(categoryName);
                }
              }
            }

            Future<void> confirm() async {
              // Сохраняем ссылку на messenger заранее, чтобы не искать предка после закрытия шита
              final messenger = ScaffoldMessenger.maybeOf(this.context);
              try {
                await ProfileService.instance.setInterests(picked.toList());
                if (!mounted) return;
                setState(() { _interests = picked.toList(); });
                Navigator.pop(context);
                if (messenger != null && mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Интересы обновлены (${picked.length}/$maxPick)'),
                      backgroundColor: AppTheme.toxicYellow,
                      behavior: SnackBarBehavior.floating,
      ),
    );
  }
              } catch (e) {
                if (!mounted) return;
                if (messenger != null) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Ошибка сохранения: $e'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }

            return Stack(
      children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.75,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
    return Container(
      decoration: BoxDecoration(
                        color: AppTheme.darkGray,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        border: Border.all(color: AppTheme.toxicYellow.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
        SizedBox(height: 8),
              Container(
                            width: 40,
                            height: 4,
                decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(
                                  'Выберите интересы',
              style: GoogleFonts.montserrat(
                                    color: AppTheme.toxicYellow,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
          Row(
            children: [
          Text(
                                      '${picked.length}/$maxPick',
                                      style: GoogleFonts.montserrat(color: Colors.white),
              ),
              SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(EvaIcons.close, color: AppTheme.toxicYellow),
                                      onPressed: () => Navigator.pop(context),
              ),
            ],
                    ),
                  ],
                ),
              ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
      decoration: BoxDecoration(
                                color: AppTheme.pureBlack.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.mediumGray, width: 1),
                              ),
                              child: TextField(
                                controller: searchController,
                                style: GoogleFonts.montserrat(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Поиск интересов...',
                                  hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade500),
                                  prefixIcon: Icon(EvaIcons.search, color: AppTheme.toxicYellow),
                                  suffixIcon: searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(EvaIcons.close, color: AppTheme.toxicYellow),
                                          onPressed: () {
                                            searchController.clear();
                                            setSheetState(() { searchQuery = ''; });
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                onChanged: (value) {
                                  setSheetState(() { searchQuery = value; });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: EdgeInsets.only(bottom: 16),
                              children: filteredCategories.entries.map((entry) {
                                final categoryName = entry.key;
                                final items = entry.value;
                                final isExpanded = expandedCategories.contains(categoryName);
                                final is18Plus = categoryName.contains('18+');
                                
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () => toggleCategory(categoryName),
                                        borderRadius: BorderRadius.circular(12),
      child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
                                            color: is18Plus
                                                ? Colors.red.withValues(alpha: 0.1)
                                                : AppTheme.pureBlack.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
        border: Border.all(
                                              color: is18Plus
                                                  ? Colors.red
                                                  : AppTheme.mediumGray.withValues(alpha: 0.3),
                                              width: is18Plus ? 2 : 1,
          ),
        ),
        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
          mainAxisSize: MainAxisSize.min,
            children: [
                                                  if (is18Plus) ...[
                                                    Icon(EvaIcons.alertCircle, color: Colors.red, size: 18),
              SizedBox(width: 8),
                                                  ],
              Text(
                                                    categoryName,
                style: GoogleFonts.montserrat(
                                                      color: is18Plus ? Colors.red : AppTheme.toxicYellow,
                                                      fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
                                              Icon(
                                                isExpanded ? EvaIcons.chevronUp : EvaIcons.chevronDown,
                                                color: is18Plus ? Colors.red : AppTheme.toxicYellow,
                                                size: 20,
          ),
        ],
      ),
                                        ),
                                      ),
                                      if (isExpanded) ...[
                                        SizedBox(height: 12),
                                        Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: items.entries.map((interest) {
                                          final key = interest.key;
                                          final label = interest.value;
                                          final selected = picked.contains(key);
                                          final disabled = !selected && picked.length >= maxPick;
    return GestureDetector(
                                            onTap: disabled ? null : () => toggle(key),
                                            child: Opacity(
                                              opacity: disabled ? 0.4 : 1.0,
      child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
                                                  color: selected
                                                      ? AppTheme.toxicYellow
                                                      : AppTheme.pureBlack.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
                                                    color: selected
                                                        ? AppTheme.toxicYellow
                                                        : AppTheme.mediumGray,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Text(
              label,
            style: GoogleFonts.montserrat(
                                                        color: selected
                                                            ? AppTheme.pureBlack
                                                            : Colors.white,
                                                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                                      ),
                                                    ),
                                                    if (selected) ...[
                                                      SizedBox(width: 6),
                                                      Icon(
                                                        EvaIcons.checkmark,
                                                        size: 16,
                                                        color: AppTheme.pureBlack,
                                                      ),
                                                    ],
                                                  ],
                                                ),
        ),
      ),
    );
                                        }).toList(),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                      ],
        ],
      ),
    );
                              }).toList(),
                            ),
                          ),
        Container(
                            padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
                              color: AppTheme.darkGray,
                              border: Border(
                                top: BorderSide(
          color: AppTheme.toxicYellow.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
                            ),
                            child: SafeArea(
                              child: Row(
        children: [
                                  if (picked.isNotEmpty)
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 56,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setSheetState(() {
                                              picked.clear();
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.redAccent,
                                            side: BorderSide(color: Colors.redAccent, width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            'Убрать все',
          style: GoogleFonts.montserrat(
                                              fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
                                        ),
                                      ),
                                    ),
                                  if (picked.isNotEmpty) SizedBox(width: 12),
            Expanded(
                                    flex: picked.isEmpty ? 1 : 2,
                                    child: SizedBox(
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed: picked.isEmpty ? null : confirm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: picked.isEmpty
                                              ? AppTheme.mediumGray
                                              : AppTheme.toxicYellow,
                                          foregroundColor: AppTheme.pureBlack,
                                          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: picked.isEmpty ? 0 : 8,
                                          shadowColor: picked.isEmpty
                                              ? null
                                              : AppTheme.toxicYellow.withValues(alpha: 0.3),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            picked.isEmpty
                                                ? 'Выберите интересы'
                                                : 'Сохранить (${picked.length}/$maxPick)',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
                                        ),
                  ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
                    );
                  },
      ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // EDIT PROFILE DIALOG
  // ============================================================================

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    int tempAge = _age;
    String tempGender = (_gender == '—') ? 'other' : _gender;
    final interests = List<String>.from(_interests);

    bool isSaving = false;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
        backgroundColor: AppTheme.darkGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> save() async {
              final messenger = ScaffoldMessenger.maybeOf(this.context);
              if (nameController.text.trim().isEmpty) {
                setModalState(() { error = 'Введите имя'; });
                return;
              }
              if (tempAge < 18 || tempAge > 120) {
                setModalState(() { error = 'Возраст должен быть от 18 до 120'; });
                return;
              }
              if (!(tempGender == 'male' || tempGender == 'female' || tempGender == 'other')) {
                setModalState(() { error = 'Выберите пол'; });
                return;
              }
              setModalState(() { isSaving = true; error = null; });
              try {
                await ProfileService.instance.setProfile(
                  name: nameController.text.trim(),
                  age: tempAge,
                  gender: tempGender,
                  interests: interests,
                );
                if (!mounted) return;
                setState(() {
                  _interests = interests;
                });
                Navigator.pop(context);
                if (messenger != null && mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Профиль сохранен'),
                      backgroundColor: AppTheme.toxicYellow,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                setModalState(() { error = 'Ошибка сохранения: $e'; });
              } finally {
                setModalState(() { isSaving = false; });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
            Text(
                    'Редактирование профиля',
              style: GoogleFonts.montserrat(
                color: AppTheme.toxicYellow,
                      fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
                  SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.montserrat(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
        children: [
          Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tempGender,
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Мужской')),
                            DropdownMenuItem(value: 'female', child: Text('Женский')),
                            DropdownMenuItem(value: 'other', child: Text('Другое')),
                          ],
                          onChanged: (v) => setModalState(() { if (v != null) tempGender = v; }),
                          dropdownColor: AppTheme.darkGray,
                          decoration: InputDecoration(
                            labelText: 'Пол',
                            labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.toxicYellow, width: 1),
                            foregroundColor: AppTheme.toxicYellow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          onPressed: () async {
                            final selected = await showModalBottomSheet<int>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) {
                                int localAge = tempAge;
                                return Container(
                                  height: MediaQuery.of(ctx).size.height * 0.6,
        decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    border: Border.all(color: AppTheme.toxicYellow.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
                                      SizedBox(height: 12),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade700,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
            ),
            SizedBox(height: 8),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          'Выберите возраст',
                                          style: GoogleFonts.montserrat(color: AppTheme.toxicYellow, fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Expanded(
                                        child: AgeWidget(
                                          selectedAge: tempAge,
                                          onAgeChanged: (a) { localAge = a; },
                                        ),
                                      ),
                                      SafeArea(
                                        top: false,
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 56,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.toxicYellow,
                                                foregroundColor: AppTheme.pureBlack,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(ctx, localAge);
                                              },
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text('Выбрать', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
                                              ),
                                            ),
                                          ),
                                        ),
          ),
        ],
      ),
    );
                              },
                            );
                            if (selected is int) {
                              setModalState(() { tempAge = selected; });
                            }
                          },
        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                              Text('Возраст', style: GoogleFonts.montserrat(color: AppTheme.toxicYellow)),
                              Text('$tempAge', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
                  if (error != null) ...[
                    SizedBox(height: 12),
                    Text(error!, style: GoogleFonts.montserrat(color: Colors.redAccent, fontSize: 12)),
                  ],
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.toxicYellow,
                        foregroundColor: AppTheme.pureBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isSaving
                          ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.pureBlack))
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Сохранить', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // SETTINGS DIALOG
  // ============================================================================

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Настройки',
          style: GoogleFonts.montserrat(
            color: AppTheme.toxicYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Настройки профиля будут доступны в следующем обновлении',
          style: GoogleFonts.montserrat(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Понятно',
              style: GoogleFonts.montserrat(
                color: AppTheme.toxicYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BIO EDIT SHEET
  // ==========================================================================

  void _showEditBioSheet() {
    final TextEditingController bioController = TextEditingController(text: _bio);
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final messenger = ScaffoldMessenger.maybeOf(this.context);
            Future<void> saveBio() async {
              final text = bioController.text.trim();
              if (text.length > 90) {
                setSheetState(() { errorText = 'Максимум 90 символов'; });
                return;
              }
              try {
                await ProfileService.instance.updateBio(text);
                if (!mounted) return;
                setState(() { _bio = text; });
                Navigator.pop(ctx);
                if (messenger != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Описание обновлено'),
                      backgroundColor: AppTheme.toxicYellow,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {}
            }

            return Container(
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: AppTheme.toxicYellow.withValues(alpha: 0.2), width: 1),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(2))),
                  SizedBox(height: 12),
                  Text('Редактировать описание', style: GoogleFonts.montserrat(color: AppTheme.toxicYellow, fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  TextField(
                    controller: bioController,
                    maxLength: 90,
                    maxLines: 3,
          style: GoogleFonts.montserrat(color: Colors.white),
          decoration: InputDecoration(
                      counterStyle: GoogleFonts.montserrat(color: Colors.grey.shade500, fontSize: 12),
                      labelText: 'Описание (до 90 символов)',
                      labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      errorText: errorText,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: saveBio,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.toxicYellow,
              foregroundColor: AppTheme.pureBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Сохранить', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
            ),
            ),
          ),
        ],
      ),
            );
          },
        );
      },
    );
  }
}

