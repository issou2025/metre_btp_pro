import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/primary_button.dart';
import '../services/formatter_service.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _locationController = TextEditingController();
  final _observationsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Maison individuelle';
  String _selectedCurrency = 'FCFA';

  final List<String> _typeOptions = [
    "Maison individuelle",
    "Villa",
    "Immeuble",
    "Mur de clôture",
    "Boutique",
    "École",
    "Latrines",
    "Magasin",
    "Bâtiment administratif",
    "Autre"
  ];

  final List<String> _currencyOptions = ["FCFA", "EUR", "USD", "MGA", "Ar"];

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _locationController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onCreateProject() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);
    
    await appState.createProject(
      name: _nameController.text.trim(),
      client: _clientController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate,
      type: _selectedType,
      currency: _selectedCurrency,
      observations: _observationsController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Projet créé avec succès !"),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context); // back to previous (home or list)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Créer un Projet",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form Card
                Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomInputField(
                          controller: _nameController,
                          label: "Nom du projet",
                          hint: "Ex: Maison R+0 3 chambres",
                          isRequired: true,
                        ),
                        const SizedBox(height: 14),
                        CustomInputField(
                          controller: _clientController,
                          label: "Client",
                          hint: "Ex: M. Soumaïla Ouédraogo",
                        ),
                        const SizedBox(height: 14),
                        CustomInputField(
                          controller: _locationController,
                          label: "Localité / Ville",
                          hint: "Ex: Ouagadougou, Zone 1",
                        ),
                        const SizedBox(height: 14),

                        // Date Picker Field
                        const Text(
                          "Date du projet",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F2A44),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  FormatterService.formatDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const Icon(Icons.calendar_month, color: Color(0xFF0F2A44), size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Type of project dropdown
                        const Text(
                          "Type de projet",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F2A44),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF0F2A44), width: 1.5),
                            ),
                          ),
                          items: _typeOptions.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedType = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Currency dropdown
                        const Text(
                          "Devise",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F2A44),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF0F2A44), width: 1.5),
                            ),
                          ),
                          items: _currencyOptions.map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCurrency = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        CustomInputField(
                          controller: _observationsController,
                          label: "Observations / Détails supplémentaires",
                          hint: "Ex: Fondations renforcées, murs extérieurs enduits 2 passes...",
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  text: "Créer le projet",
                  onPressed: _onCreateProject,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
