import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/measurement_item_model.dart';
import '../providers/app_state.dart';
import '../services/calculation_service.dart';
import '../services/module_registry.dart';
import '../services/price_service.dart';
import 'custom_input_field.dart';
import 'price_input.dart';
import 'result_card.dart';
import 'error_message.dart';

class DynamicModuleCalculator extends StatefulWidget {
  final ModuleDef moduleDef;

  const DynamicModuleCalculator({
    super.key,
    required this.moduleDef,
  });

  @override
  State<DynamicModuleCalculator> createState() => _DynamicModuleCalculatorState();
}

class _DynamicModuleCalculatorState extends State<DynamicModuleCalculator> {
  final _formKey = GlobalKey<FormState>();
  
  // Input fields controllers
  final Map<String, TextEditingController> _controllers = {};
  
  // Custom designations & notes
  late TextEditingController _designationController;
  late TextEditingController _notesController;

  // Active Price
  double _unitPrice = 0.0;
  
  // Result State
  CalculationResult? _result;
  String _validationError = '';

  @override
  void initState() {
    super.initState();
    
    // Initialize designation and notes
    _designationController = TextEditingController(text: widget.moduleDef.name);
    _notesController = TextEditingController();

    // Fetch currency from context or default
    final appState = Provider.of<AppState>(context, listen: false);
    final currency = appState.currentProject?.currency ?? appState.defaultCurrency;

    // Load initial price from database
    final dbPrice = PriceService.getPriceFor(
      designation: widget.moduleDef.name,
      category: widget.moduleDef.category,
      defaultUnit: widget.moduleDef.unit,
      currency: currency,
    );
    _unitPrice = dbPrice.price;

    // Initialize inputs controllers with default values
    for (var input in widget.moduleDef.inputs) {
      // If the default value is integer, format cleanly
      final isInt = input.defaultValue == input.defaultValue.roundToDouble();
      final valStr = isInt ? input.defaultValue.round().toString() : input.defaultValue.toString();
      _controllers[input.id] = TextEditingController(text: valStr);
    }

    // Perform initial calculation
    _runCalculation();

    // Attach listeners for live calculation
    for (var controller in _controllers.values) {
      controller.addListener(_runCalculation);
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    _notesController.dispose();
    for (var controller in _controllers.values) {
      controller.removeListener(_runCalculation);
      controller.dispose();
    }
    super.dispose();
  }

  /// Gather inputs and run calculation
  void _runCalculation() {
    final Map<String, double> inputs = {};
    
    // Parse double values
    for (var entry in _controllers.entries) {
      final val = double.tryParse(entry.value.text) ?? 0.0;
      inputs[entry.key] = val;
    }

    // Attach current unit price to inputs so CalculationService has access (e.g. for montant)
    inputs['prix_unitaire'] = _unitPrice;
    inputs['prix_kg'] = _unitPrice;
    inputs['prix_m2'] = _unitPrice;
    inputs['prix_ml'] = _unitPrice;
    inputs['prix_bloc'] = _unitPrice; // default overrides
    inputs['prix_brique'] = _unitPrice;
    inputs['prix_m3'] = _unitPrice;
    inputs['prix_voyage'] = _unitPrice;
    inputs['prix_jour'] = _unitPrice;
    inputs['prix_unitaire'] = _unitPrice;

    // Special values like total_travaux for marge_imprevus
    if (widget.moduleDef.id == 'marge_imprevus' && !inputs.containsKey('total_travaux')) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.currentProject != null) {
        final total = appState.currentProject!.items.fold(0.0, (sum, item) => sum + item.amount);
        inputs['total_travaux'] = total;
      }
    }

    final res = CalculationService.calculate(widget.moduleDef.id, inputs);
    
    setState(() {
      _result = res;
      _validationError = res.errorMessage ?? '';
    });
  }

  void _onAddToProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_result == null || _validationError.isNotEmpty) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final activeProject = appState.currentProject;

    if (activeProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner ou créer un projet d'abord.")),
      );
      return;
    }

    final newItem = MeasurementItem(
      id: const Uuid().v4(),
      projectId: activeProject.id,
      category: widget.moduleDef.category,
      designation: _designationController.text.trim(),
      unit: widget.moduleDef.unit,
      quantity: _result!.quantity,
      unitPrice: _unitPrice,
      amount: _result!.amount,
      formulaUsed: _result!.formulaUsed,
      notes: _notesController.text.trim(),
    );

    await appState.addMeasurementItem(activeProject.id, newItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ajouté avec succès : ${newItem.designation}"),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context); // back to project detail
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currency = appState.currentProject?.currency ?? appState.defaultCurrency;
    final hasProject = appState.currentProject != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Basic fields card (Designation, notes)
          Card(
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DESCRIPTION DU MÉTRÉ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2A44),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: _designationController,
                    label: "Désignation",
                    hint: "Ex: Fouilles semelle S1",
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: _notesController,
                    label: "Notes / Localisation",
                    hint: "Ex: Axe A-B, semelles de 1 à 6",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Inputs card
          Card(
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DIMENSIONS & QUANTITATIFS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2A44),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.moduleDef.inputs.map((input) {
                    // Skip prix_unitaire inputs here as we handle it separately
                    if (input.id.startsWith('prix_') || input.id == 'total_travaux') {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CustomInputField(
                        controller: _controllers[input.id]!,
                        label: input.name,
                        suffixText: input.unit != 'ratio' ? input.unit : null,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Obligatoire';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null) {
                            return 'Nombre invalide';
                          }
                          if (parsed < 0) {
                            return 'Doit être positif';
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Price card
          Card(
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PRIX UNITAIRE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2A44),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PriceInput(
                    initialPrice: _unitPrice,
                    currency: currency,
                    unit: widget.moduleDef.unit,
                    onPriceChanged: (newPrice) {
                      setState(() {
                        _unitPrice = newPrice;
                      });
                      _runCalculation();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Validation Error Banner
          if (_validationError.isNotEmpty)
            ErrorMessage(message: _validationError),

          // Result Card
          if (_result != null && _validationError.isEmpty)
            ResultCard(
              quantity: _result!.quantity,
              unit: widget.moduleDef.unit,
              amount: _result!.amount,
              currency: currency,
              formula: _result!.formulaUsed,
              additionalInfo: _result!.additionalInfo,
              onAddToProject: hasProject ? _onAddToProject : null,
              buttonText: "Enregistrer la ligne de métré",
            ),
          
          if (!hasProject)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Amber 50
                border: Border.all(color: const Color(0xFFFDE68A)), // Amber 200
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Mode calcul rapide actif. Pour enregistrer cette ligne, ouvrez ou créez d'abord un projet.",
                      style: TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
