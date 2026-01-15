import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:spend_save/models/saving_goal.dart';
import 'package:spend_save/models/savings_activity.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/widgets/animated_background.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  List<SavingGoal> _savingsGoals = [];
  SavingGoal? _selectedGoal;
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _savingsGoals = HiveService.savingsBox.values
          .where((goal) => goal.isActive && goal.currentAmount > 0)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _withdrawFunds() async {
    if (_selectedGoal == null) {
      _showError('Please select a savings goal');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (amount > _selectedGoal!.currentAmount) {
      _showError('Cannot withdraw more than current balance');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Withdraw funds from the goal
      final success = await HiveService.withdrawFundsFromGoal(_selectedGoal!.id, amount);
      
      if (!success) {
        _showError('Failed to withdraw funds');
        return;
      }
      
      // Get updated goal
      final updatedGoal = HiveService.getSavingsGoal(_selectedGoal!.id);
      
      if (updatedGoal != null) {
        // Log savings activity
        await HiveService.logSavingsActivity(
          SavingsActivity(
            type: SavingsActivityType.fundsWithdrawn,
            goalName: updatedGoal.name,
            goalIcon: updatedGoal.iconCode,
            timestamp: DateTime.now(),
            goalId: updatedGoal.id,
            amount: amount,
            currentAmount: updatedGoal.currentAmount,
            targetAmount: updatedGoal.targetAmount > 0 ? updatedGoal.targetAmount : null,
          ),
        );
        
        // Show success dialog
        await _showSuccessDialog();
        
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError('Failed to withdraw funds: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        message: 'Funds withdrawn successfully!',
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyText1),
        backgroundColor: Colors.red,
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: AnimatedBackground(
      child: SafeArea(
        child: Column(
            children: [
              // Header with Back button only
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
                        'Withdraw Funds',
                        style: AppTheme.headline3,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _savingsGoals.isEmpty
                        ? _buildEmptyState()
                        : _buildContent(),
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
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 25),
            Text(
              'No Funds Available',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 10),
            Text(
              'Add funds to your savings goals first',
              style: AppTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: Column(
        children: [
          // ========== 1. SAVINGS GOALS GRID (3 COLUMNS) ==========
          _buildGoalsGrid(),
          const SizedBox(height: 25),

          // ========== 2. SELECTED GOAL DISPLAY ==========
          if (_selectedGoal != null) _buildSelectedGoalSection(),
          const SizedBox(height: 25),

          // ========== 3. AMOUNT INPUT ==========
          _buildAmountInput(),
          const SizedBox(height: 30),

          // ========== 4. WITHDRAW FUNDS BUTTON ==========
          _buildWithdrawButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGoalsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SAVINGS GOAL',
          style: AppTheme.bodyText2.copyWith(
            letterSpacing: 1,
            fontSize: AppTheme.fontSizeXSmall,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemCount: _savingsGoals.length,
          itemBuilder: (context, index) {
            final goal = _savingsGoals[index];
            final isSelected = _selectedGoal?.id == goal.id;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGoal = goal;
                });
              },
              child: Opacity(
                opacity: isSelected ? 1.0 : (_selectedGoal == null ? 1.0 : 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: goal.colorGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: isSelected ? 2 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: goal.colorGradient[0].withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Color Gradient Circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: goal.colorGradient,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Goal Name
                        Text(
                          goal.name,
                          style: AppTheme.bodyText1.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Available Balance
                        const SizedBox(height: 4),
                        Text(
                          '₱${goal.currentAmount.toStringAsFixed(0)}',
                          style: AppTheme.captionText.copyWith(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildSelectedGoalSection() {
  final goal = _selectedGoal!;
  
  return Container(
    padding: const EdgeInsets.all(AppTheme.paddingMedium),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: goal.colorGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      boxShadow: [
        BoxShadow(
          color: goal.colorGradient[0].withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        // First Row: Goal Name + Available Balance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        _getIconFromCode(goal.iconCode),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          goal.name,
                          style: AppTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected for withdrawal',
                    style: AppTheme.captionText.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Available',
                  style: AppTheme.captionText.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '₱${goal.currentAmount.toStringAsFixed(2)}',
                  style: AppTheme.headline3.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Second Row: Target + Amount Left (only if target exists)
        if (goal.targetAmount > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target',
                      style: AppTheme.captionText.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '₱${goal.targetAmount.toStringAsFixed(2)}',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: AppTheme.captionText.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 6,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: goal.progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: goal.colorGradient,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '₱${goal.amountLeft.toStringAsFixed(2)}',
                          style: AppTheme.captionText.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

  Widget _buildAmountInput() {
    final maxAmount = _selectedGoal?.currentAmount ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AMOUNT TO WITHDRAW',
              style: AppTheme.bodyText2.copyWith(
                letterSpacing: 1,
                fontSize: AppTheme.fontSizeXSmall,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            if (_selectedGoal != null)
              GestureDetector(
                onTap: () {
                  _amountController.text = maxAmount.toStringAsFixed(2);
                  setState(() {});
                },
                child: Text(
                  'Max: ₱${maxAmount.toStringAsFixed(2)}',
                  style: AppTheme.captionText.copyWith(
                    color: AppTheme.warningGradient.colors[0],
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        GlassCard(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: TextField(
            controller: _amountController,
            style: AppTheme.bodyText1.copyWith(fontSize: 18),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter amount (₱)',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, top: 16, right: 8),
                child: Text(
                  '₱',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        
        // Validation message
        if (_selectedGoal != null && _amountController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: _buildValidationMessage(),
          ),
      ],
    );
  }

  Widget _buildValidationMessage() {
    final amount = double.tryParse(_amountController.text);
    final currentAmount = _selectedGoal!.currentAmount;
    
    if (amount == null || amount <= 0) {
      return Text(
        'Enter a valid amount greater than 0',
        style: AppTheme.captionText.copyWith(
          color: AppTheme.errorGradient.colors[0],
          fontSize: 11,
        ),
      );
    }
    
    if (amount > currentAmount) {
      return Text(
        'Cannot withdraw more than available balance',
        style: AppTheme.captionText.copyWith(
          color: AppTheme.errorGradient.colors[0],
          fontSize: 11,
        ),
      );
    }
    
    return Text(
      'Available: ₱${currentAmount.toStringAsFixed(2)}',
      style: AppTheme.captionText.copyWith(
        color: Colors.white.withOpacity(0.6),
        fontSize: 11,
      ),
    );
  }

  Widget _buildWithdrawButton() {
    final amount = double.tryParse(_amountController.text);
    final isValid = _selectedGoal != null && 
                    amount != null &&
                    amount > 0 &&
                    amount <= (_selectedGoal?.currentAmount ?? 0) &&
                    !_isSubmitting;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _withdrawFunds : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppTheme.warningGradient.colors[0] : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Withdraw Funds',
                style: AppTheme.buttonText.copyWith(fontSize: 16),
              ),
      ),
    );
  }
}

// ========== SUCCESS DIALOG (Same as Add Funds) ==========
class SuccessDialog extends StatefulWidget {
  final String message;

  const SuccessDialog({super.key, required this.message});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Check mark path drawing animation
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    // Fade in animation for text
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Check Mark (Path Drawing)
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: CheckMarkPainter(progress: _checkAnimation.value),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Message
                Text(
                  widget.message,
                  style: AppTheme.headline4.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for drawing check mark
class CheckMarkPainter extends CustomPainter {
  final double progress;
  
  CheckMarkPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // Draw circle (optional, can remove if you want just the check)
    // canvas.drawCircle(center, radius, paint);
    
    // Draw check mark
    final path = Path();
    
    // Check mark points
    final startPoint = Offset(center.dx - radius * 0.4, center.dy);
    final middlePoint = Offset(center.dx - radius * 0.1, center.dy + radius * 0.5);
    final endPoint = Offset(center.dx + radius * 0.5, center.dy - radius * 0.4);
    
    // Move to start point
    path.moveTo(startPoint.dx, startPoint.dy);
    
    // Draw first line
    final firstLineLength = 0.4;
    if (progress <= firstLineLength) {
      final partialMiddlePoint = Offset(
        startPoint.dx + (middlePoint.dx - startPoint.dx) * (progress / firstLineLength),
        startPoint.dy + (middlePoint.dy - startPoint.dy) * (progress / firstLineLength),
      );
      path.lineTo(partialMiddlePoint.dx, partialMiddlePoint.dy);
    } else {
      path.lineTo(middlePoint.dx, middlePoint.dy);
      
      // Draw second line
      final secondLineProgress = (progress - firstLineLength) / (1.0 - firstLineLength);
      final partialEndPoint = Offset(
        middlePoint.dx + (endPoint.dx - middlePoint.dx) * secondLineProgress,
        middlePoint.dy + (endPoint.dy - middlePoint.dy) * secondLineProgress,
      );
      path.lineTo(partialEndPoint.dx, partialEndPoint.dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}