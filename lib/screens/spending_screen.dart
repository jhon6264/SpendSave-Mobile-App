import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/models/custom_envelope.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/screens/budget_creation_screen.dart';
import 'package:spend_save/screens/edit_budget_screen.dart';
import 'package:spend_save/screens/history_screen.dart';
import 'package:spend_save/widgets/animated_background.dart';
class SpendingScreen extends StatefulWidget {
  const SpendingScreen({super.key});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen>
    with TickerProviderStateMixin {
  List<CustomEnvelope> _envelopes = [];
  bool _hasBudget = false;
  bool _isLoading = true;

  // Animation for budget card
  late AnimationController _budgetAnimationController;
  late Animation<double> _colorCycleAnimation;
  
  // Warm color cycle for budget card
  final List<Color> _warmColors1 = [const Color(0xFFFF416C), const Color(0xFFFF4B2B)];
  final List<Color> _warmColors2 = [const Color(0xFFFF7E5F), const Color(0xFFFEB47B)];
  final List<Color> _warmColors3 = [const Color(0xFFFFE259), const Color(0xFFFFA751)];
  
  // Animation controllers for long press
  final Map<String, AnimationController> _pressAnimationControllers = {};

  // Available icons for edit modal
  final List<IconData> _availableIcons = [
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.water,
    FontAwesomeIcons.tv,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.car,
    FontAwesomeIcons.shoppingCart,
    FontAwesomeIcons.mobileScreen,
    FontAwesomeIcons.wifi,
    FontAwesomeIcons.gasPump,
    FontAwesomeIcons.utensils,
    FontAwesomeIcons.moneyBill,
    FontAwesomeIcons.heart,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.book,
    FontAwesomeIcons.music,
    FontAwesomeIcons.plane,
    FontAwesomeIcons.gift,
    FontAwesomeIcons.coffee,
    FontAwesomeIcons.house,
    FontAwesomeIcons.paw,
    FontAwesomeIcons.bicycle,
    FontAwesomeIcons.bus,
    FontAwesomeIcons.train,
    FontAwesomeIcons.suitcase,
    FontAwesomeIcons.shirt,
    FontAwesomeIcons.pills,
    FontAwesomeIcons.stethoscope,
    FontAwesomeIcons.graduationCap,
    FontAwesomeIcons.baby,
    FontAwesomeIcons.dog,
    FontAwesomeIcons.cat,
    FontAwesomeIcons.tree,
    FontAwesomeIcons.sun,
    FontAwesomeIcons.cloud,
    FontAwesomeIcons.umbrella,
    FontAwesomeIcons.tools,
    FontAwesomeIcons.wrench,
    FontAwesomeIcons.lightbulb,
    FontAwesomeIcons.key,
    FontAwesomeIcons.lock,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for budget card
    _budgetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    
    _colorCycleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _budgetAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _loadData();
  }

  @override
  void dispose() {
    _budgetAnimationController.dispose();
    for (var controller in _pressAnimationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final budget = HiveService.getActiveBudget();
    setState(() {
      _hasBudget = budget != null;
      _envelopes = _hasBudget ? HiveService.getActiveEnvelopes() : [];
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  // Get current color for warm color cycle
  List<Color> _getCurrentWarmColors(double value) {
    if (value < 0.33) {
      final progress = value / 0.33;
      return [
        Color.lerp(_warmColors1[0], _warmColors2[0], progress)!,
        Color.lerp(_warmColors1[1], _warmColors2[1], progress)!,
      ];
    } else if (value < 0.66) {
      final progress = (value - 0.33) / 0.33;
      return [
        Color.lerp(_warmColors2[0], _warmColors3[0], progress)!,
        Color.lerp(_warmColors2[1], _warmColors3[1], progress)!,
      ];
    } else {
      final progress = (value - 0.66) / 0.34;
      return [
        Color.lerp(_warmColors3[0], _warmColors1[0], progress)!,
        Color.lerp(_warmColors3[1], _warmColors1[1], progress)!,
      ];
    }
  }

  // Show edit modal for envelope
  void _showEditEnvelopeModal(CustomEnvelope envelope) {
    showDialog(
      context: context,
      builder: (context) => EditEnvelopeModal(
        envelope: envelope,
        availableIcons: _availableIcons,
        onSave: (updatedEnvelope) async {
          // Update envelope in Hive
          final index = HiveService.envelopeBox.values
              .toList()
              .indexWhere((env) => env.id == updatedEnvelope.id);
          if (index != -1) {
            await HiveService.envelopeBox.putAt(index, updatedEnvelope);
            _refreshData();
          }
        },
      ),
    );
  }

  double get _totalBudget {
    return _envelopes.fold(0.0, (sum, envelope) => sum + envelope.allocatedAmount);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: AnimatedBackground(
      child: SafeArea(
        child: Column(
            children: [
              // REMOVED TITLE HEADER - Only SafeArea padding
              const SizedBox(height: 10),

              // Main Content - Scrollable
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasBudget
                        ? _buildWithBudget()
                        : _buildNoBudget(),
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
          Text(
            'Loading...',
            style: AppTheme.bodyText1,
          ),
        ],
      ),
    );
  }

  Widget _buildNoBudget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.folderOpen,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 25),
            Text(
              'No Budget Yet',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 10),
            Text(
              'Create your first budget to start tracking spending',
              style: AppTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetCreationScreen(),
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
              child: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithBudget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
        child: Column(
          children: [
            // ========== 1. HORIZONTAL TOTAL BUDGET CARD ==========
            _buildTotalBudgetCard(),
            const SizedBox(height: 20),

            // ========== 2. ENVELOPES GRID (SAME HEIGHT AS SAVINGS) ==========
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _envelopes.length,
                itemBuilder: (context, index) {
                  final envelope = _envelopes[index];
                  return _buildEnvelopeCard(envelope);
                },
              ),
            ),
            const SizedBox(height: 20),

            // ========== 3. 2 BUTTONS (SIDE BY SIDE, 50% EACH) ==========
            _buildButtonsRow(),
            const SizedBox(height: 20),

            // ========== 4. CHART SECTION ==========
            _buildChartSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBudgetCard() {
    return AnimatedBuilder(
      animation: _colorCycleAnimation,
      builder: (context, child) {
        final currentColors = _getCurrentWarmColors(_colorCycleAnimation.value);
        
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
              // Left side: Total Budget + Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Budget',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₱${_totalBudget.toStringAsFixed(2)}',
                      style: AppTheme.headline2.copyWith(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side: Number of envelopes
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
                      'Envelopes',
                      style: AppTheme.captionText.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_envelopes.length}',
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

  Widget _buildEnvelopeCard(CustomEnvelope envelope) {
    // Get or create animation controller for this card
    if (!_pressAnimationControllers.containsKey(envelope.id)) {
      _pressAnimationControllers[envelope.id] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
    final animationController = _pressAnimationControllers[envelope.id]!;
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
        // Bounce back animation then show modal with fade+scale
        animationController.reverse().then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _showEditEnvelopeModal(envelope);
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
                    colors: envelope.colorGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: envelope.colorGradient[0].withOpacity(0.3),
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
                        _getIconFromCode(envelope.iconCode),
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 8),

                      // Name
                      Text(
                        envelope.name,
                        style: AppTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Remaining Amount
                      Text(
                        '₱${envelope.remainingAmount.toStringAsFixed(2)}',
                        style: AppTheme.numberText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Daily & Days Info
                      Text(
                        '₱${envelope.dailyBudget.toStringAsFixed(2)}/day • ${envelope.daysLeft}d',
                        style: AppTheme.captionText.copyWith(
                          fontSize: 8,
                          color: Colors.white.withOpacity(0.8),
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

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Edit Button (50% width)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 5),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBudgetScreen(
                      onBudgetUpdated: _refreshData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.editButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Edit'),
            ),
          ),
        ),

        // History Button (50% width)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 5),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.historyButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('History'),
            ),
          ),
        ),
      ],
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
          Text(
            '📊 Spending Visualization',
            style: AppTheme.headline4.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Charts and graphs coming soon',
            style: AppTheme.bodyText2.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.chartLine,
                size: 28,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
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
          : FontAwesomeIcons.moneyBill;
    } catch (e) {
      return FontAwesomeIcons.moneyBill;
    }
  }
}

// ========== EDIT ENVELOPE MODAL ==========
class EditEnvelopeModal extends StatefulWidget {
  final CustomEnvelope envelope;
  final List<IconData> availableIcons;
  final Function(CustomEnvelope) onSave;

  const EditEnvelopeModal({
    super.key,
    required this.envelope,
    required this.availableIcons,
    required this.onSave,
  });

  @override
  State<EditEnvelopeModal> createState() => _EditEnvelopeModalState();
}

class _EditEnvelopeModalState extends State<EditEnvelopeModal> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late int _selectedColorIndex;
  late int _selectedIconIndex;
  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogOpacityAnimation;
  late Animation<double> _dialogScaleAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.envelope.name);
    _selectedColorIndex = widget.envelope.colorIndex;
    
    // Find the current icon index
    _selectedIconIndex = widget.availableIcons.indexWhere(
      (icon) => icon.codePoint.toString() == widget.envelope.iconCode,
    );
    if (_selectedIconIndex == -1) {
      _selectedIconIndex = 0;
    }
    
    // Dialog animation controller
    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _dialogOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeIn,
      ),
    );
    
    _dialogScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dialogAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dialogAnimationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedEnvelope = CustomEnvelope(
      id: widget.envelope.id,
      name: _nameController.text.trim(),
      iconCode: widget.availableIcons[_selectedIconIndex].codePoint.toString(),
      colorIndex: _selectedColorIndex,
      percentage: widget.envelope.percentage,
      allocatedAmount: widget.envelope.allocatedAmount,
      remainingAmount: widget.envelope.remainingAmount,
      dailyBudget: widget.envelope.dailyBudget,
      startDate: widget.envelope.startDate,
      endDate: widget.envelope.endDate,
      isActive: widget.envelope.isActive,
    );
    
    widget.onSave(updatedEnvelope);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _dialogOpacityAnimation.value,
          child: Transform.scale(
            scale: _dialogScaleAnimation.value,
            child: Dialog(
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
                          hintText: 'Envelope name',
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
            ),
          ),
        );
      },
    );
  }
}