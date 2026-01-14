import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/models/custom_envelope.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/screens/budget_creation_screen.dart';
import 'package:spend_save/screens/edit_budget_screen.dart';
import 'package:spend_save/screens/history_screen.dart';

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

  // Animation controllers for each card
  final Map<String, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _animationControllers.values) {
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

    // Initialize animations for envelopes
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Clear old controllers
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();

    // Create new animation controllers for each envelope
    for (var envelope in _envelopes) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(reverse: true);

      _animationControllers[envelope.id] = controller;
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
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
                    'Spending',
                    style: AppTheme.headline3,
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasBudget
                        ? _buildWithBudget()
                        : _buildNoBudget(),
              ),

              // Bottom Buttons
              if (!_isLoading) _buildBottomButtons(),
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
    if (_envelopes.isEmpty) {
      return Center(
        child: Text(
          'No envelopes found',
          style: AppTheme.bodyText1,
        ),
      );
    }

    return Column(
      children: [
        // Scrollable Envelopes Grid Only (30% smaller)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8, // Reduced from 12
                mainAxisSpacing: 8, // Reduced from 12
                childAspectRatio: 1.0, // Changed from 0.85 (more square, smaller)
              ),
              itemCount: _envelopes.length,
              itemBuilder: (context, index) {
                final envelope = _envelopes[index];
                return _buildEnvelopeCard(envelope);
              },
            ),
          ),
        ),

        // Fixed Chart Placeholder
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
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
                  style: AppTheme.headline4.copyWith(fontSize: 16), // Smaller
                ),
                const SizedBox(height: 6), // Reduced
                Text(
                  'Charts and graphs coming soon',
                  style: AppTheme.bodyText2.copyWith(fontSize: 12), // Smaller
                ),
                const SizedBox(height: 10), // Reduced
                Container(
                  height: 60, // Reduced from 80
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.chartLine,
                      size: 28, // Reduced from 32
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnvelopeCard(CustomEnvelope envelope) {
    final animationController = _animationControllers[envelope.id];
    
    return AnimatedBuilder(
      animation: animationController ?? AnimationController(vsync: this),
      builder: (context, child) {
        // Animated gradient positions
        final animationValue = animationController?.value ?? 0;
        final beginAlignment = Alignment(-1.0 + animationValue, -1.0 + animationValue);
        final endAlignment = Alignment(1.0 - animationValue, 1.0 - animationValue);
        
        return GestureDetector(
          onTap: () {
            // TODO: Envelope detail screen
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: envelope.colorGradient,
                begin: beginAlignment, // Animated position
                end: endAlignment, // Animated position
                tileMode: TileMode.clamp,
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: envelope.colorGradient[0].withOpacity(0.3),
                  blurRadius: 8, // Reduced from 10
                  offset: const Offset(0, 3), // Reduced from 4
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8), // Reduced from 12 (30% smaller)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon (30% smaller: 32px → 22px)
                  FaIcon(
                    _getIconFromCode(envelope.iconCode),
                    color: Colors.white,
                    size: 30, // Reduced from 32
                  ),
                  const SizedBox(height: 6), // Reduced from 10

                  // Name (30% smaller: 14px → 10px)
                  Text(
                    envelope.name,
                    style: AppTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Reduced from 14
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5), // Reduced from 8

                  // Remaining Amount (30% smaller: 18px → 13px)
                  Text(
                    '₱${envelope.remainingAmount.toStringAsFixed(2)}',
                    style: AppTheme.numberText.copyWith(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3), // Reduced from 4

                  // Daily & Days Info (30% smaller: 9px → 6px)
                  Text(
                    '₱${envelope.dailyBudget.toStringAsFixed(2)}/day • ${envelope.daysLeft}d',
                    style: AppTheme.captionText.copyWith(
                      fontSize: 8, // Reduced from 10
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: const Color(0x30FFFFFF),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Edit Button
          ElevatedButton(
            onPressed: _hasBudget
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBudgetScreen(
                          onBudgetUpdated: _refreshData,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.editButtonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('Edit'),
          ),

          // History Button
          ElevatedButton(
            onPressed: _hasBudget
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.historyButtonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('History'),
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