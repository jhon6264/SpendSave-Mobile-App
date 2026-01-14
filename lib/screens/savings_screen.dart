import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/models/saving_goal.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/screens/add_savings_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with TickerProviderStateMixin {
  List<SavingGoal> _savingsGoals = [];
  bool _isLoading = true;

  // Animation controller for total savings card only
  late AnimationController _totalSavingsAnimationController;
  late Animation<double> _colorCycleAnimation;
  
  // Color cycle animation values
  final List<Color> _cycleColors1 = [const Color(0xFF8A2BE2), const Color(0xFF4B0082)];
  final List<Color> _cycleColors2 = [const Color(0xFF1E90FF), const Color(0xFF00BFFF)];
  final List<Color> _cycleColors3 = [const Color(0xFF00B09B), const Color(0xFF96C93D)];

  // Animation for long press feedback
  final Map<String, AnimationController> _pressAnimationControllers = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for total savings card color cycling
    _totalSavingsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    
    _colorCycleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _totalSavingsAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _loadData();
  }

  @override
  void dispose() {
    _totalSavingsAnimationController.dispose();
    // Dispose press animation controllers
    for (var controller in _pressAnimationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _savingsGoals = HiveService.savingsBox.values
          .where((goal) => goal.isActive)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  double get _totalSavings {
    return _savingsGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  // Get current color for color cycle
  List<Color> _getCurrentCycleColors(double value) {
    if (value < 0.33) {
      // First third: color1 to color2
      final progress = value / 0.33;
      return [
        Color.lerp(_cycleColors1[0], _cycleColors2[0], progress)!,
        Color.lerp(_cycleColors1[1], _cycleColors2[1], progress)!,
      ];
    } else if (value < 0.66) {
      // Second third: color2 to color3
      final progress = (value - 0.33) / 0.33;
      return [
        Color.lerp(_cycleColors2[0], _cycleColors3[0], progress)!,
        Color.lerp(_cycleColors2[1], _cycleColors3[1], progress)!,
      ];
    } else {
      // Last third: color3 back to color1
      final progress = (value - 0.66) / 0.34;
      return [
        Color.lerp(_cycleColors3[0], _cycleColors1[0], progress)!,
        Color.lerp(_cycleColors3[1], _cycleColors1[1], progress)!,
      ];
    }
  }

  // Available icons (same as add_savings_screen)
  final List<IconData> _availableIcons = [
    FontAwesomeIcons.piggyBank,
    FontAwesomeIcons.house,
    FontAwesomeIcons.car,
    FontAwesomeIcons.plane,
    FontAwesomeIcons.graduationCap,
    FontAwesomeIcons.heart,
    FontAwesomeIcons.baby,
    FontAwesomeIcons.stethoscope,
    FontAwesomeIcons.tv,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.book,
    FontAwesomeIcons.music,
    FontAwesomeIcons.camera,
    FontAwesomeIcons.bicycle,
    FontAwesomeIcons.gift,
    FontAwesomeIcons.tree,
    FontAwesomeIcons.handsHelping,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.chartLine,
  ];

  // Show edit modal for savings goal
  void _showEditSavingsModal(SavingGoal goal) {
    showDialog(
      context: context,
      builder: (context) => EditSavingsModal(
        goal: goal,
        availableIcons: _availableIcons,
        onSave: (updatedGoal) async {
          await HiveService.updateSavingsGoal(updatedGoal);
          _refreshData();
        },
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
              // Simple centered title
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.paddingMedium,
                ),
                child: Center(
                  child: Text(
                    'Savings',
                    style: AppTheme.headline3,
                  ),
                ),
              ),

              // Main Content - Scrollable
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _savingsGoals.isEmpty
                        ? _buildEmptyState()
                        : _buildWithSavings(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text('Loading...', style: AppTheme.bodyText1),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.piggyBank,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 30),
            Text(
              'No Savings Yet',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 10),
            Text(
              'Start building your savings goals',
              style: AppTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSavingsScreen(),
                  ),
                ).then((_) => _refreshData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.saveButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
              child: const Text('Start Saving Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithSavings() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
        child: Column(
          children: [
            // ========== 1. HORIZONTAL TOTAL SAVINGS CARD ==========
            _buildTotalSavingsCard(),
            const SizedBox(height: 20),

            // ========== 2. SAVINGS GOALS GRID ==========
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: _savingsGoals.length,
                itemBuilder: (context, index) {
                  final goal = _savingsGoals[index];
                  return _buildSavingsCard(goal);
                },
              ),
            ),
            const SizedBox(height: 20),

            // ========== 3. 2x2 ICON BUTTONS GRID ==========
            _buildIconButtonsGrid(),
            const SizedBox(height: 20),

            // ========== 4. CHART SECTION ==========
            _buildChartSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSavingsCard() {
    return AnimatedBuilder(
      animation: _colorCycleAnimation,
      builder: (context, child) {
        final currentColors = _getCurrentCycleColors(_colorCycleAnimation.value);
        
        return Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: currentColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: currentColors[0].withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Total Savings + Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Savings',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₱${_totalSavings.toStringAsFixed(2)}',
                      style: AppTheme.headline2.copyWith(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side: Number of goals
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Goals',
                      style: AppTheme.captionText.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_savingsGoals.length}',
                      style: AppTheme.headline4.copyWith(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavingsCard(SavingGoal goal) {
    // Get or create animation controller for this card
    if (!_pressAnimationControllers.containsKey(goal.id)) {
      _pressAnimationControllers[goal.id] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
    final animationController = _pressAnimationControllers[goal.id]!;
    final scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    final opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    return GestureDetector(
      onLongPressStart: (details) {
        // Start scale down animation when long press begins
        animationController.forward();
      },
      onLongPressEnd: (details) {
        // Bounce back animation then show modal
        animationController.reverse().then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _showEditSavingsModal(goal);
          });
        });
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: Opacity(
              opacity: opacityAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: goal.colorGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: goal.colorGradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      FaIcon(
                        _getIconFromCode(goal.iconCode),
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 8),

                      // Name
                      Text(
                        goal.name,
                        style: AppTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Amount
                      Text(
                        '₱${goal.currentAmount.toStringAsFixed(2)}',
                        style: AppTheme.numberText.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // Target (if set)
                      if (goal.targetAmount > 0)
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '/ ₱${goal.targetAmount.toStringAsFixed(2)}',
                              style: AppTheme.bodyText2.copyWith(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 6),
                            
                            // Progress bar
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: goal.progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal.progressPercentage,
                              style: AppTheme.captionText.copyWith(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'No target set',
                            style: AppTheme.captionText.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButtonsGrid() {
    return Column(
      children: [
        // First row of icon buttons
        Row(
          children: [
            // New Button (Piggy Bank) - Reduced shadow to match others
            Expanded(
              child: _buildIconButtonCard(
                icon: FontAwesomeIcons.piggyBank,
                color: const Color(0xFF6A11CB),
                shadowOpacity: 0.3, // Reduced from 0.4 to match others
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSavingsScreen(),
                    ),
                  ).then((_) => _refreshData());
                },
                label: 'New',
              ),
            ),
            const SizedBox(width: 10),
            
            // Add Funds Button (Money Bill Wave)
            Expanded(
              child: _buildIconButtonCard(
                icon: FontAwesomeIcons.moneyBillWave,
                color: const Color(0xFF00B09B),
                shadowOpacity: 0.3,
                onTap: () => _showComingSoon('Add Funds'),
                label: 'Add Funds',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // Second row of icon buttons
        Row(
          children: [
            // Withdraw Button (Money Check)
            Expanded(
              child: _buildIconButtonCard(
                icon: FontAwesomeIcons.moneyCheck,
                color: const Color(0xFFFF7E5F),
                shadowOpacity: 0.3,
                onTap: () => _showComingSoon('Withdraw'),
                label: 'Withdraw',
              ),
            ),
            const SizedBox(width: 10),
            
            // History Button (Clock Rotate Left)
            Expanded(
              child: _buildIconButtonCard(
                icon: FontAwesomeIcons.clockRotateLeft,
                color: const Color(0xFF1E90FF),
                shadowOpacity: 0.3,
                onTap: () => _showComingSoon('History'),
                label: 'History',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButtonCard({
    required IconData icon,
    required Color color,
    required double shadowOpacity,
    required VoidCallback onTap,
    required String label,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(shadowOpacity),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.captionText.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: const Color(0x33FFFFFF),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.chartLine,
            size: 32,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'Savings Progress',
            style: AppTheme.headline4.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Track your savings growth over time',
            style: AppTheme.bodyText2.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!', style: AppTheme.bodyText1),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Helper to get IconData from stored code
  IconData _getIconFromCode(String code) {
    try {
      final codePoint = int.tryParse(code);
      return codePoint != null
          ? IconData(
              codePoint,
              fontFamily: 'FontAwesomeSolid',
              fontPackage: 'font_awesome_flutter',
            )
          : FontAwesomeIcons.piggyBank;
    } catch (e) {
      return FontAwesomeIcons.piggyBank;
    }
  }
}

// ========== EDIT SAVINGS MODAL ==========
class EditSavingsModal extends StatefulWidget {
  final SavingGoal goal;
  final List<IconData> availableIcons;
  final Function(SavingGoal) onSave;

  const EditSavingsModal({
    super.key,
    required this.goal,
    required this.availableIcons,
    required this.onSave,
  });

  @override
  State<EditSavingsModal> createState() => _EditSavingsModalState();
}

class _EditSavingsModalState extends State<EditSavingsModal> {
  late TextEditingController _nameController;
  late int _selectedColorIndex;
  late int _selectedIconIndex;
  late String _originalIconCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _selectedColorIndex = widget.goal.colorIndex;
    _originalIconCode = widget.goal.iconCode;
    
    // Find the current icon index
    _selectedIconIndex = widget.availableIcons.indexWhere(
      (icon) => icon.codePoint.toString() == widget.goal.iconCode,
    );
    if (_selectedIconIndex == -1) {
      _selectedIconIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedGoal = SavingGoal(
      id: widget.goal.id,
      name: _nameController.text.trim(),
      iconCode: widget.availableIcons[_selectedIconIndex].codePoint.toString(),
      colorIndex: _selectedColorIndex,
      targetAmount: widget.goal.targetAmount,
      currentAmount: widget.goal.currentAmount,
      description: widget.goal.description,
      targetDate: widget.goal.targetDate,
      createdAt: widget.goal.createdAt,
      isActive: widget.goal.isActive,
    );
    
    widget.onSave(updatedGoal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.envelopeColorOptions[_selectedColorIndex],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Back and Check icons
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  // Check button
                  IconButton(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Name Field (Large, Centered)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingMedium,
              ),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: AppTheme.headline3.copyWith(
                  fontSize: 24,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Goal name',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            // Color Selection (Horizontal Scrollable)
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.paddingMedium,
                right: AppTheme.paddingMedium,
                bottom: AppTheme.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppTheme.paddingMedium,
                      bottom: 8,
                    ),
                    child: Text(
                      'COLOR',
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppTheme.envelopeColorOptions.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColorIndex = index);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppTheme.envelopeColorOptions[index],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _selectedColorIndex == index
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Icon Selection (Horizontal Scrollable)
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.paddingMedium,
                right: AppTheme.paddingMedium,
                bottom: AppTheme.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppTheme.paddingMedium,
                      bottom: 8,
                    ),
                    child: Text(
                      'ICON',
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.availableIcons.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIconIndex = index);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _selectedIconIndex == index
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _selectedIconIndex == index
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: FaIcon(
                                widget.availableIcons[index],
                                color: Colors.white,
                                size: 22,
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
          ],
        ),
      ),
    );
  }
}