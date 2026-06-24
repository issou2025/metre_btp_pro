import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/company_model.dart';
import '../providers/app_state.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/primary_button.dart';
import 'admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _nifController;
  late TextEditingController _lossController;
  late TextEditingController _serverIpController;

  late String _currency;
  late String _themeMode;

  final List<String> _currencyOptions = ["FCFA", "EUR", "USD"];
  final List<String> _themeOptions = ["Clair", "Sombre", "Système"];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    _companyNameController = TextEditingController(text: appState.companyInfo.name);
    _phoneController = TextEditingController(text: appState.companyInfo.phone);
    _emailController = TextEditingController(text: appState.companyInfo.email);
    _addressController = TextEditingController(text: appState.companyInfo.address);
    _nifController = TextEditingController(text: appState.companyInfo.nif);
    
    _lossController = TextEditingController(
      text: appState.defaultLossPercentage == appState.defaultLossPercentage.roundToDouble()
          ? appState.defaultLossPercentage.round().toString()
          : appState.defaultLossPercentage.toString(),
    );
    _serverIpController = TextEditingController(text: appState.serverIp);

    _currency = appState.defaultCurrency;
    _themeMode = appState.themeMode;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nifController.dispose();
    _lossController.dispose();
    _serverIpController.dispose();
    super.dispose();
  }

  void _onSaveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);

    // Save Company Details
    final company = CompanyInfo(
      name: _companyNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      nif: _nifController.text.trim(),
    );
    await appState.updateCompanyInfo(company);

    // Save Global Settings
    final double loss = double.parse(_lossController.text);
    await appState.updateSettings(
      currency: _currency,
      lossPercentage: loss,
      themeMode: _themeMode,
      serverIp: _serverIpController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paramètres enregistrés avec succès !"),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Paramètres",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
                // 1. COMPANY CARD
                Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.business, color: Color(0xFF0F2A44), size: 18),
                            SizedBox(width: 8),
                            Text(
                              "INFORMATIONS DE L'ENTREPRISE",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F2A44)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomInputField(
                          controller: _companyNameController,
                          label: "Nom de l'entreprise",
                          hint: "Ex: Bâtisseur Pro SARL",
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        CustomInputField(
                          controller: _phoneController,
                          label: "Téléphone",
                          hint: "Ex: +226 25 30 00 00",
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        CustomInputField(
                          controller: _emailController,
                          label: "Email",
                          hint: "Ex: contact@batisseurpro.com",
                        ),
                        const SizedBox(height: 12),
                        CustomInputField(
                          controller: _addressController,
                          label: "Adresse",
                          hint: "Ex: Secteur 15, Ouagadougou",
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        CustomInputField(
                          controller: _nifController,
                          label: "NIF ou RCCM (optionnel)",
                          hint: "Ex: NIF 300456789 A",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. CONFIG CARD
                Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune, color: Color(0xFF0F2A44), size: 18),
                            SizedBox(width: 8),
                            Text(
                              "PRÉFÉRENCES DE CALCUL & AFFICHAGE",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F2A44)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Loss percent
                        CustomInputField(
                          controller: _lossController,
                          label: "Pourcentage de perte par défaut",
                          suffixText: "%",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          isRequired: true,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) return "Nombre invalide";
                            if (double.parse(value) < 0 || double.parse(value) > 100) return "Doit être entre 0 et 100";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Default Currency
                        const Text(
                          "Devise par défaut",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F2A44)),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          items: _currencyOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _currency = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Theme Mode
                        const Text(
                          "Thème de l'application",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F2A44)),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _themeMode,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          items: _themeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _themeMode = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomInputField(
                          controller: _serverIpController,
                          label: "Adresse IP / Serveur (Suivi APK)",
                          hint: "Ex: localhost ou 192.168.1.10",
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. ADMIN SPACE CARD
                Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Color(0xFF0F2A44), size: 18),
                            SizedBox(width: 8),
                            Text(
                              "ADMINISTRATION",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F2A44)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Consultez les statistiques de téléchargement de l'APK de l'application.",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2A44),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminScreen()),
                            );
                          },
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text("Console Administrateur (APK)"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  text: "Enregistrer les modifications",
                  onPressed: _onSaveSettings,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
