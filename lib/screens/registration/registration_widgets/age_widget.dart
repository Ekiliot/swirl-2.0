import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AgeWidget extends StatefulWidget {
  final int? selectedAge;
  final Function(int) onAgeChanged;

  const AgeWidget({
    super.key,
    required this.selectedAge,
    required this.onAgeChanged,
  });

  @override
  State<AgeWidget> createState() => _AgeWidgetState();
}

class _AgeWidgetState extends State<AgeWidget> {
  late int _selectedAge;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.selectedAge ?? 18;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 20),
          
          // Выбор возраста с красивым колесом
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 60,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 53,
                    builder: (context, index) {
                      final age = 18 + index;
                      final isSelected = age == _selectedAge;

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.toxicYellow.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 200),
                            style: GoogleFonts.montserrat(
                              color: isSelected ? AppTheme.toxicYellow : Colors.grey.shade400,
                              fontSize: isSelected ? 32 : 24,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            child: Text('$age'),
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedAge = 18 + index;
                    });
                    widget.onAgeChanged(_selectedAge);
                  },
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
