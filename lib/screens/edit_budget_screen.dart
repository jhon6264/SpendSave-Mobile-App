import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:spend_save/models/custom_envelope.dart';
import 'package:spend_save/models/budget_period.dart';
import 'package:spend_save/models/activity.dart';
import 'package:spend_save/services/hive_service.dart';

class EditBudgetScreen extends StatefulWidget {
  final VoidCallback? onBudgetUpdated;
  
  const EditBudgetScreen({
    super.key,
    this.onBudgetUpdated,
  });

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  // Current data
  late BudgetPeriod _budget;
  List<CustomEnvelope> _envelopes = [];
  
  // Editing state
  final List<CustomEnvelope> _editedEnvelopes = [];
  bool _isLoading = true;
  
  // New envelope creation
  final TextEditingController _newNameController = TextEditingController();
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  
  // Budget editing
  final TextEditingController _budgetAmountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  // Track changes for activity logging
  final List<CustomEnvelope> _addedEnvelopes = [];
  final List<CustomEnvelope> _deletedEnvelopes = [];
  final List<CustomEnvelope> _editedEnvelopeList = [];
  
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
    _loadData();
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _budgetAmountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final budget = HiveService.getActiveBudget();
    if (budget == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final envelopes = HiveService.getActiveEnvelopes();
    
    setState(() {
      _budget = budget;
      _envelopes = envelopes;
      _editedEnvelopes.addAll(envelopes.map((e) => CustomEnvelope(
        id: e.id,
        name: e.name,
        iconCode: e.iconCode,
        colorIndex: e.colorIndex,
        percentage: e.percentage,
        allocatedAmount: e.allocatedAmount,
        remainingAmount: e.remainingAmount,
        dailyBudget: e.dailyBudget,
        startDate: e.startDate,
        endDate: e.endDate,
        isActive: e.isActive,
      )));
      
      _budgetAmountController.text = _budget.totalAmount.toStringAsFixed(2);
      _durationController.text = _budget.durationDays.toString();
      _isLoading = false;
    });
  }

  void _updatePercentage(int index, double percentage) {
    setState(() {
      _editedEnvelopes[index].percentage = percentage.clamp(0, 100);
      _updateAllocatedAmounts();
    });
  }

  void _updateAllocatedAmounts() {
    final totalBudget = double.tryParse(_budgetAmountController.text) ?? _budget.totalAmount;
    
    for (var envelope in _editedEnvelopes) {
      envelope.allocatedAmount = totalBudget * (envelope.percentage / 100);
      if (envelope.allocatedAmount > 0) {
        final ratio = envelope.remainingAmount / envelope.allocatedAmount;
        envelope.remainingAmount = envelope.allocatedAmount * ratio;
      } else {
        envelope.remainingAmount = 0;
      }
    }
  }

  void _addNewEnvelope() {
    final name = _newNameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter envelope name');
      return;
    }

    if (_editedEnvelopes.any((env) => env.name.toLowerCase() == name.toLowerCase())) {
      _showError('Envelope with this name already exists');
      return;
    }

    final newEnvelope = CustomEnvelope(
      name: name,
      iconCode: _availableIcons[_selectedIconIndex].codePoint.toString(),
      colorIndex: _selectedColorIndex,
      percentage: 0.0,
    );

    setState(() {
      _editedEnvelopes.add(newEnvelope);
      _addedEnvelopes.add(newEnvelope);
      
      // Distribute percentages equally
      final equalPercentage = 100.0 / _editedEnvelopes.length;
      for (var envelope in _editedEnvelopes) {
        envelope.percentage = equalPercentage;
      }
      
      _newNameController.clear();
      _selectedIconIndex = 0;
      _selectedColorIndex = 0;
      _updateAllocatedAmounts();
    });
  }

  void _deleteEnvelope(int index) {
    if (_editedEnvelopes.length <= 2) {
      _showError('Need at least 2 envelopes');
      return;
    }

    setState(() {
      final deletedEnvelope = _editedEnvelopes[index];
      _deletedEnvelopes.add(deletedEnvelope);
      
      final deletedPercentage = deletedEnvelope.percentage;
      _editedEnvelopes.removeAt(index);
      
      // Distribute deleted percentage
      final remainingEnvelopes = _editedEnvelopes.length;
      if (remainingEnvelopes > 0) {
        final addPercentage = deletedPercentage / remainingEnvelopes;
        for (var envelope in _editedEnvelopes) {
          envelope.percentage += addPercentage;
        }
      }
      
      _updateAllocatedAmounts();
    });
  }

  void _editEnvelope(int index) {
    final envelope = _editedEnvelopes[index];
    _newNameController.text = envelope.name;
    _selectedIconIndex = _availableIcons.indexWhere(
      (icon) => icon.codePoint.toString() == envelope.iconCode,
    );
    if (_selectedIconIndex == -1) _selectedIconIndex = 0;
    _selectedColorIndex = envelope.colorIndex;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildEditEnvelopeModal(index, envelope);
      },
    );
  }

  Future<void> _saveChanges() async {
    // Validate total percentage
    final totalPercentage = _editedEnvelopes.fold(
      0.0, (sum, env) => sum + env.percentage
    );
    
    if (totalPercentage != 100.0) {
      _showError('Total percentage must equal 100%');
      return;
    }

    final newAmount = double.tryParse(_budgetAmountController.text);
    final newDays = int.tryParse(_durationController.text);
    
    if (newAmount == null || newAmount <= 0) {
      _showError('Please enter valid budget amount');
      return;
    }
    
    if (newDays == null || newDays <= 0) {
      _showError('Please enter valid duration');
      return;
    }

    try {
      // Update budget
      _budget.totalAmount = newAmount;
      _budget.endDate = _budget.startDate.add(Duration(days: newDays - 1));
      _budget.durationDays = newDays;
      
      // Save budget
      final budgetIndex = HiveService.budgetBox.values
          .toList()
          .indexWhere((b) => b.id == _budget.id);
      if (budgetIndex != -1) {
        await HiveService.budgetBox.putAt(budgetIndex, _budget);
      }
      
      // Clear old envelopes
      await HiveService.envelopeBox.clear();
      
      // Save updated envelopes with new budget info
      for (var envelope in _editedEnvelopes) {
        envelope.updateWithBudget(
          totalBudget: newAmount,
          start: _budget.startDate,
          end: _budget.endDate,
        );
        await HiveService.envelopeBox.add(envelope);
      }
      
      // Log activities
      await _logActivities();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget updated!', style: AppTheme.bodyText1),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onBudgetUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to save: $e');
    }
  }

  Future<void> _logActivities() async {
    // Log added envelopes
    if (_addedEnvelopes.isNotEmpty) {
      if (_addedEnvelopes.length == 1) {
        await HiveService.logActivity(
          Activity.singleEnvelope(
            type: ActivityType.envelopeAdded,
            envelopeName: _addedEnvelopes.first.name,
            envelopeIcon: _addedEnvelopes.first.iconCode,
            timestamp: DateTime.now(),
            envelopeId: _addedEnvelopes.first.id,
          ),
        );
      } else {
        await HiveService.logActivity(
          Activity.multipleEnvelopes(
            type: ActivityType.envelopeAdded,
            envelopeNames: _addedEnvelopes.map((e) => e.name).toList(),
            envelopeIcons: _addedEnvelopes.map((e) => e.iconCode).toList(),
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    
    // Log deleted envelopes
    if (_deletedEnvelopes.isNotEmpty) {
      if (_deletedEnvelopes.length == 1) {
        await HiveService.logActivity(
          Activity.singleEnvelope(
            type: ActivityType.envelopeDeleted,
            envelopeName: _deletedEnvelopes.first.name,
            envelopeIcon: _deletedEnvelopes.first.iconCode,
            timestamp: DateTime.now(),
            envelopeId: _deletedEnvelopes.first.id,
          ),
        );
      } else {
        await HiveService.logActivity(
          Activity.multipleEnvelopes(
            type: ActivityType.envelopeDeleted,
            envelopeNames: _deletedEnvelopes.map((e) => e.name).toList(),
            envelopeIcons: _deletedEnvelopes.map((e) => e.iconCode).toList(),
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    
    // Log edited envelopes
    for (var editedEnvelope in _editedEnvelopes) {
      final originalEnvelope = _envelopes.firstWhere(
        (env) => env.id == editedEnvelope.id,
        orElse: () => editedEnvelope,
      );
      
      if (editedEnvelope.name != originalEnvelope.name ||
          editedEnvelope.iconCode != originalEnvelope.iconCode ||
          editedEnvelope.colorIndex != originalEnvelope.colorIndex ||
          editedEnvelope.percentage != originalEnvelope.percentage) {
        
        await HiveService.logActivity(
          Activity.singleEnvelope(
            type: ActivityType.envelopeEdited,
            envelopeName: editedEnvelope.name,
            envelopeIcon: editedEnvelope.iconCode,
            timestamp: DateTime.now(),
            envelopeId: editedEnvelope.id,
          ),
        );
      }
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

  double get _totalPercentage {
    return _editedEnvelopes.fold(0.0, (sum, env) => sum + env.percentage);
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

  @override
  Widget build(BuildContext context) {
    final totalPercentage = _totalPercentage;
    final isValid = totalPercentage == 100.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                        'Edit Budget',
                        style: AppTheme.headline3,
                      ),
                    ),
                    IconButton(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add New Envelope Section
                            _buildAddEnvelopeSection(),
                            const SizedBox(height: 25),
                            
                            // Current Budget
                            _buildBudgetSection(),
                            const SizedBox(height: 25),
                            
                            // Envelopes List
                            _buildEnvelopesList(),
                            const SizedBox(height: 25),
                            
                            // Total Percentage
                            _buildTotalPercentageIndicator(isValid, totalPercentage),
                            const SizedBox(height: 30),
                            
                            // Save Button
                            _buildSaveButton(isValid),
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

  Widget _buildAddEnvelopeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADD NEW ENVELOPE',
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
              TextField(
                controller: _newNameController,
                style: AppTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: 'New envelope name...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Icon Selection
              Text('CHOOSE ICON:', style: AppTheme.captionText),
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
              
              // Color Selection
              Text('CHOOSE COLOR:', style: AppTheme.captionText),
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
              
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addNewEnvelope,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Add Envelope'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET SETTINGS',
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
              TextField(
                controller: _budgetAmountController,
                style: AppTheme.bodyText1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Total Budget (₱)', // PHP symbol
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Padding(
  padding: EdgeInsets.only(top: 12, left: 19, right: 8),
  child: Text('₱', style: TextStyle(color: Colors.white70, fontSize: 18)),
),
                ),
                onChanged: (_) => _updateAllocatedAmounts(),
              ),
              const SizedBox(height: 12),
              
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnvelopesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENVELOPES (${_editedEnvelopes.length})',
          style: AppTheme.bodyText2.copyWith(
            letterSpacing: 1,
            fontSize: AppTheme.fontSizeXSmall,
          ),
        ),
        const SizedBox(height: 12),
        
        ..._editedEnvelopes.asMap().entries.map((entry) {
          final index = entry.key;
          final envelope = entry.value;
          
          return Column(
            children: [
              GlassCard(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: Column(
                  children: [
                    // Header with edit/delete
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
                            size: 20,
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
                                '₱${envelope.allocatedAmount.toStringAsFixed(2)}', // PHP symbol
                                style: AppTheme.bodyText2,
                              ),
                            ],
                          ),
                        ),
                        
                        IconButton(
                          onPressed: () => _editEnvelope(index),
                          icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                        ),
                        IconButton(
                          onPressed: () => _deleteEnvelope(index),
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Percentage slider
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
                          _updatePercentage(index, value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (index < _editedEnvelopes.length - 1) const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalPercentageIndicator(bool isValid, double totalPercentage) {
    return GlassCard(
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Allocation',
                style: AppTheme.bodyText1,
              ),
              Text(
                'Must equal 100% to save',
                style: AppTheme.captionText,
              ),
            ],
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
    );
  }

  Widget _buildSaveButton(bool isValid) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _saveChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppTheme.saveButtonColor : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Save Changes',
          style: AppTheme.buttonText,
        ),
      ),
    );
  }

  Widget _buildEditEnvelopeModal(int index, CustomEnvelope envelope) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit ${envelope.name}',
            style: AppTheme.headline4,
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _newNameController,
            style: AppTheme.bodyText1,
            decoration: InputDecoration(
              hintText: 'New name...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                borderSide: BorderSide(color: const Color(0x33FFFFFF)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _newNameController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = _newNameController.text.trim();
                  if (newName.isNotEmpty) {
                    setState(() {
                      _editedEnvelopes[index].name = newName;
                      _editedEnvelopes[index].iconCode = 
                          _availableIcons[_selectedIconIndex].codePoint.toString();
                      _editedEnvelopes[index].colorIndex = _selectedColorIndex;
                    });
                    Navigator.pop(context);
                    _newNameController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.saveButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}