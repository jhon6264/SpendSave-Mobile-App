import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:spend_save/models/custom_envelope.dart';
import 'package:spend_save/models/budget_period.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/models/activity.dart';
import 'package:spend_save/widgets/animated_background.dart';

class BudgetCreationScreen extends StatefulWidget {
  const BudgetCreationScreen({super.key});

  @override
  State<BudgetCreationScreen> createState() => _BudgetCreationScreenState();
}

class _BudgetCreationScreenState extends State<BudgetCreationScreen> {
  // Section 1: New Envelope Creation
  final TextEditingController _envelopeNameController = TextEditingController();
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  
  // Section 2: Created Envelopes
  final List<CustomEnvelope> _createdEnvelopes = [];
  
  // Section 3: Budget Setup
  final TextEditingController _budgetAmountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  double _totalBudget = 0.0;
  int _durationDays = 0;
  bool _budgetSet = false;
  
  // Available icons
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
    // Start with 2 empty envelopes as minimum
    _addEmptyEnvelope();
    _addEmptyEnvelope();
  }

  @override
  void dispose() {
    _envelopeNameController.dispose();
    _budgetAmountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addEmptyEnvelope() {
    setState(() {
      _createdEnvelopes.add(CustomEnvelope(
        name: '',
        iconCode: _availableIcons[_selectedIconIndex].codePoint.toString(),
        colorIndex: _selectedColorIndex,
        percentage: 0.0,
      ));
    });
  }

  void _createEnvelope() {
    final name = _envelopeNameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter envelope name');
      return;
    }

    setState(() {
      // Update the first empty envelope
      for (var envelope in _createdEnvelopes) {
        if (envelope.name.isEmpty) {
          envelope.name = name;
          envelope.iconCode = _availableIcons[_selectedIconIndex].codePoint.toString();
          envelope.colorIndex = _selectedColorIndex;
          break;
        }
      }
      
      // Reset form
      _envelopeNameController.clear();
      _selectedIconIndex = 0;
      _selectedColorIndex = 0;
      
      // Add new empty envelope if needed
      if (_createdEnvelopes.every((env) => env.name.isNotEmpty)) {
        _addEmptyEnvelope();
      }
    });
  }

  IconData _getIconFromCode(String code) {
    try {
      final codePoint = int.tryParse(code);
      return codePoint != null 
          ? IconData(codePoint, fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter')
          : FontAwesomeIcons.moneyBill;
    } catch (e) {
      return FontAwesomeIcons.moneyBill;
    }
  }

  void _setBudget() {
    final amount = double.tryParse(_budgetAmountController.text) ?? 0;
    final days = int.tryParse(_durationController.text) ?? 0;
    
    if (amount <= 0) {
      _showError('Please enter a valid budget amount');
      return;
    }
    
    if (days <= 0) {
      _showError('Please enter a valid duration (days)');
      return;
    }
    
    final namedEnvelopes = _createdEnvelopes
        .where((env) => env.name.isNotEmpty)
        .length;
    
    if (namedEnvelopes < 2) {
      _showError('Please create at least 2 envelopes');
      return;
    }
    
    setState(() {
      _totalBudget = amount;
      _durationDays = days;
      _budgetSet = true;
      
      // Set equal percentages
      final percentagePerEnvelope = 100.0 / namedEnvelopes;
      for (var envelope in _createdEnvelopes) {
        if (envelope.name.isNotEmpty) {
          envelope.percentage = percentagePerEnvelope;
        }
      }
      
      _updateAllocatedAmounts();
    });
  }

  void _updateAllocatedAmounts() {
    if (!_budgetSet) return;
    
    for (var envelope in _createdEnvelopes) {
      if (envelope.name.isNotEmpty) {
        envelope.allocatedAmount = _totalBudget * (envelope.percentage / 100);
        envelope.remainingAmount = envelope.allocatedAmount;
      }
    }
  }

  void _updatePercentage(int index, double percentage) {
    if (!_budgetSet) return;
    
    setState(() {
      _createdEnvelopes[index].percentage = percentage.clamp(0, 100);
      _updateAllocatedAmounts();
    });
  }

  double get _totalPercentage {
    return _createdEnvelopes
        .where((env) => env.name.isNotEmpty)
        .fold(0.0, (sum, env) => sum + env.percentage);
  }

  Future<void> _saveBudget() async {
  if (!_budgetSet) {
    _showError('Please set budget amount and duration first');
    return;
  }

  final validEnvelopes = _createdEnvelopes
      .where((env) => env.name.isNotEmpty)
      .toList();

  if (validEnvelopes.length < 2) {
    _showError('Please create at least 2 envelopes');
    return;
  }

  if (_totalPercentage != 100.0) {
    _showError('Total percentage must equal 100%');
    return;
  }

  try {
    // Create budget period
    final budget = BudgetPeriod.createWithDays(
      amount: _totalBudget,
      start: DateTime.now(),
      days: _durationDays,
    );

    // Save budget
    await HiveService.budgetBox.add(budget);

    // Save envelopes with budget info
    for (var envelope in validEnvelopes) {
      envelope.updateWithBudget(
        totalBudget: _totalBudget,
        start: budget.startDate,
        end: budget.endDate,
      );
      await HiveService.envelopeBox.add(envelope);
    }

    // Log activity - Add this part
    await HiveService.logActivity(
      Activity.multipleEnvelopes(
        type: ActivityType.envelopeAdded,
        envelopeNames: validEnvelopes.map((e) => e.name).toList(),
        envelopeIcons: validEnvelopes.map((e) => e.iconCode).toList(),
        timestamp: DateTime.now(),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget created!', style: AppTheme.bodyText1),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  } catch (e) {
    _showError('Failed to save budget: $e');
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
    final namedEnvelopes = _createdEnvelopes
        .where((env) => env.name.isNotEmpty)
        .toList();
  return Scaffold(
    body: AnimatedBackground(
      child: SafeArea(
        child: Column(
            children: [
              // Simple Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Budget',
                      style: AppTheme.headline3,
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
                      // SECTION 1: CREATE NEW ENVELOPE
                      _buildCreateEnvelopeSection(),
                      const SizedBox(height: 25),
                      
                      // SECTION 2: CREATED ENVELOPES GRID
                      if (namedEnvelopes.isNotEmpty) ...[
                        _buildEnvelopesGridSection(),
                        const SizedBox(height: 25),
                      ],
                      
                      // SECTION 3: BUDGET SETUP
                      _buildBudgetSetupSection(),
                      const SizedBox(height: 25),
                      
                      // SECTION 4: PERCENTAGE ALLOCATION
                      if (_budgetSet && namedEnvelopes.isNotEmpty) ...[
                        _buildAllocationSection(),
                        const SizedBox(height: 20),
                      ],
                      
                      // SAVE BUTTON
                      _buildSaveButton(),
                      const SizedBox(height: 30),
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

  Widget _buildCreateEnvelopeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CREATE ENVELOPE',
          style: AppTheme.bodyText2.copyWith(
            letterSpacing: 1,
            fontSize: AppTheme.fontSizeXSmall,
          ),
        ),
        const SizedBox(height: 12),
        
        GlassCard(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Column(
            children: [
              // Envelope Name
              TextField(
                controller: _envelopeNameController,
                style: AppTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: 'Envelope name...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Choose Icon (Scrollable)
              Text(
                'CHOOSE ICON:',
                style: AppTheme.captionText,
              ),
              const SizedBox(height: 8),
              
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconIndex = index),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _selectedIconIndex == index
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
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
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Choose Color
              Text(
                'CHOOSE COLOR:',
                style: AppTheme.captionText,
              ),
              const SizedBox(height: 8),
              
              SizedBox(
  height: 40,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: AppTheme.envelopeColorOptions.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () => setState(() => _selectedColorIndex = index),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 8),
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
              const SizedBox(height: 16),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createEnvelope,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Create Envelope'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnvelopesGridSection() {
    final namedEnvelopes = _createdEnvelopes
        .where((env) => env.name.isNotEmpty)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR ENVELOPES (${namedEnvelopes.length})',
          style: AppTheme.bodyText2.copyWith(
            letterSpacing: 1,
            fontSize: AppTheme.fontSizeXSmall,
          ),
        ),
        const SizedBox(height: 12),
        
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: namedEnvelopes.length,
          itemBuilder: (context, index) {
            final envelope = namedEnvelopes[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: envelope.colorGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  FaIcon(
                    _getIconFromCode(envelope.iconCode),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  
                  // Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      envelope.name,
                      style: AppTheme.bodyText1.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetSetupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET SETUP',
          style: AppTheme.bodyText2.copyWith(
            letterSpacing: 1,
            fontSize: AppTheme.fontSizeXSmall,
          ),
        ),
        const SizedBox(height: 12),
        
        GlassCard(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Column(
            children: [
              // Total Budget
              TextField(
                controller: _budgetAmountController,
                style: AppTheme.bodyText1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Total Budget (₱)',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.white70, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              
              // Duration
              TextField(
                controller: _durationController,
                style: AppTheme.bodyText1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Duration (days)',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              
              // Set Budget Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _setBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.saveButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(_budgetSet ? 'Update Budget' : 'Set Budget'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationSection() {
    final namedEnvelopes = _createdEnvelopes
        .where((env) => env.name.isNotEmpty)
        .toList();
    
    final totalPercentage = _totalPercentage;
    final isValid = totalPercentage == 100.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALLOCATE PERCENTAGES',
          style: AppTheme.bodyText2.copyWith(
            letterSpacing: 1,
            fontSize: AppTheme.fontSizeXSmall,
          ),
        ),
        const SizedBox(height: 12),
        
        // Total Percentage Indicator
        GlassCard(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: AppTheme.bodyText1,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isValid ? AppTheme.successGradient : AppTheme.errorGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${totalPercentage.toStringAsFixed(1)}%',
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Envelope Sliders
        ...namedEnvelopes.asMap().entries.map((entry) {
          final index = entry.key;
          final envelope = entry.value;
          final originalIndex = _createdEnvelopes.indexOf(envelope);
          
          return Column(
            children: [
              GlassCard(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Envelope header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: envelope.colorGradient,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FaIcon(
                            _getIconFromCode(envelope.iconCode),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                envelope.name,
                                style: AppTheme.bodyText1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${envelope.percentage.toStringAsFixed(1)}% • '
                                '₱${envelope.allocatedAmount.toStringAsFixed(2)}',
                                style: AppTheme.bodyText2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor: envelope.colorGradient[0],
                        inactiveTrackColor: envelope.colorGradient[1].withOpacity(0.3),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: envelope.percentage,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: envelope.percentage.toStringAsFixed(1),
                        onChanged: (value) {
                          _updatePercentage(originalIndex, value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (index < namedEnvelopes.length - 1) const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSaveButton() {
    final totalPercentage = _totalPercentage;
    final isValid = totalPercentage == 100.0 && _budgetSet;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _saveBudget : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppTheme.saveButtonColor : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Save Budget',
          style: AppTheme.buttonText,
        ),
      ),
    );
  }
}