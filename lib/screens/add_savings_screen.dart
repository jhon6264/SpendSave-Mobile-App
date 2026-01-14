import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:spend_save/models/saving_goal.dart';
import 'package:spend_save/services/hive_service.dart';


class AddSavingsScreen extends StatefulWidget {
  const AddSavingsScreen({super.key});

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  
  // Available icons (focused on savings goals)
  final List<IconData> _availableIcons = [
    FontAwesomeIcons.piggyBank,      // General savings
    FontAwesomeIcons.house,          // House
    FontAwesomeIcons.car,            // Car
    FontAwesomeIcons.plane,          // Vacation
    FontAwesomeIcons.graduationCap,  // Education
    FontAwesomeIcons.heart,          // Wedding
    FontAwesomeIcons.baby,           // Baby
    FontAwesomeIcons.stethoscope,    // Medical
    FontAwesomeIcons.tv,             // Electronics
    FontAwesomeIcons.gamepad,        // Entertainment
    FontAwesomeIcons.dumbbell,       // Fitness
    FontAwesomeIcons.book,           // Books/Learning
    FontAwesomeIcons.music,          // Music
    FontAwesomeIcons.camera,         // Photography
    FontAwesomeIcons.bicycle,        // Hobby
    FontAwesomeIcons.gift,           // Gifts
    FontAwesomeIcons.tree,           // Environment
    FontAwesomeIcons.handsHelping,   // Charity
    FontAwesomeIcons.briefcase,      // Business
    FontAwesomeIcons.chartLine,      // Investment
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createSavingsGoal() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter savings goal name');
      return;
    }

    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;

    try {
      final savingGoal = SavingGoal(
        name: name,
        iconCode: _availableIcons[_selectedIconIndex].codePoint.toString(),
        colorIndex: _selectedColorIndex,
        targetAmount: targetAmount,
        currentAmount: 0,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      await HiveService.savingsBox.add(savingGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Savings goal created!', style: AppTheme.bodyText1),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to create savings goal: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyText1),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'New Savings Goal',
                        style: AppTheme.headline3,
                      ),
                    ),
                    IconButton(
                      onPressed: _createSavingsGoal,
                      icon: const Icon(Icons.check, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Goal Name
                      Text(
                        'GOAL NAME',
                        style: AppTheme.bodyText2.copyWith(
                          letterSpacing: 1,
                          fontSize: AppTheme.fontSizeXSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      GlassCard(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        child: TextField(
                          controller: _nameController,
                          style: AppTheme.bodyText1,
                          decoration: InputDecoration(
                            hintText: 'e.g., Vacation Fund, House Downpayment...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Target Amount (Optional)
                      Text(
                        'TARGET AMOUNT (Optional)',
                        style: AppTheme.bodyText2.copyWith(
                          letterSpacing: 1,
                          fontSize: AppTheme.fontSizeXSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      GlassCard(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        child: TextField(
                          controller: _targetAmountController,
                          style: AppTheme.bodyText1,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Target amount (₱) - Leave empty for no target',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                            prefixIcon: Icon(Icons.currency_exchange, color: Colors.white70, size: 20)
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Choose Icon
                      Text(
                        'CHOOSE ICON',
                        style: AppTheme.bodyText2.copyWith(
                          letterSpacing: 1,
                          fontSize: AppTheme.fontSizeXSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      GlassCard(
  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
  child: SizedBox(
    height: 80, // Same height as before
    child: ListView.builder(
      scrollDirection: Axis.horizontal, // ← Makes it horizontal
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        return Container(
          width: 60, // Fixed width for each icon
          padding: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () => setState(() => _selectedIconIndex = index),
            child: Container(
              decoration: BoxDecoration(
                color: _selectedIconIndex == index
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedIconIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: FaIcon(
                  _availableIcons[index],
                  color: Colors.white,
                  size: 24, // Slightly larger for better visibility
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
),
                      const SizedBox(height: 20),

                      // Choose Color
                      Text(
                        'CHOOSE COLOR',
                        style: AppTheme.bodyText2.copyWith(
                          letterSpacing: 1,
                          fontSize: AppTheme.fontSizeXSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      GlassCard(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: AppTheme.envelopeColorOptions.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColorIndex = index),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: AppTheme.envelopeColorOptions[index],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _selectedColorIndex == index
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description (Optional)
                      Text(
                        'DESCRIPTION (Optional)',
                        style: AppTheme.bodyText2.copyWith(
                          letterSpacing: 1,
                          fontSize: AppTheme.fontSizeXSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      GlassCard(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        child: TextField(
                          controller: _descriptionController,
                          style: AppTheme.bodyText1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'What are you saving for? e.g., "Dream vacation to Japan"',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createSavingsGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.saveButtonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Create Savings Goal',
                            style: AppTheme.buttonText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}