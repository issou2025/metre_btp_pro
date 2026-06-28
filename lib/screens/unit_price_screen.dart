import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unit_price_model.dart';
import '../providers/app_state.dart';
import '../services/formatter_service.dart';

class UnitPriceScreen extends StatelessWidget {
  const UnitPriceScreen({super.key});

  /// Confirm and reset prices
  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Réinitialiser les prix ?"),
        content: const Text("Voulez-vous réinitialiser tous les prix unitaires aux valeurs moyennes par défaut ? Vos modifications personnalisées seront perdues."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.resetPricesToDefaults();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Prix unitaires réinitialisés !"), backgroundColor: Color(0xFF16A34A)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2A44)),
            child: const Text("Confirmer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Show Dialog to Add or Edit a Unit Price
  void _showPriceFormDialog(BuildContext context, {UnitPrice? existingPrice}) {
    final formKey = GlobalKey<FormState>();
    final designationController = TextEditingController(text: existingPrice?.designation ?? '');
    final unitController = TextEditingController(text: existingPrice?.unit ?? 'm³');
    final priceController = TextEditingController(text: existingPrice?.price.toString() ?? '0');
    
    final appState = Provider.of<AppState>(context, listen: false);
    String selectedCategory = existingPrice?.category ?? 'Terrassements';
    String currency = appState.currentProject?.currency ?? appState.defaultCurrency;

    final List<String> categories = [
      "Terrassements", "Béton", "Ferraillage", "Coffrage", 
      "Maçonnerie", "Finitions", "Toiture", "Menuiseries", 
      "Plomberie", "Électricité", "VRD", "Divers"
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existingPrice == null ? "Ajouter un prix unitaire" : "Modifier le prix"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: designationController,
                        decoration: const InputDecoration(labelText: "Désignation (Nom du travail/matériau)"),
                        validator: (value) => (value == null || value.trim().isEmpty) ? "Nom requis" : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: "Catégorie"),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setStateDialog(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: "Unité (ex: m³, m², kg, u, ml)"),
                        validator: (value) => (value == null || value.trim().isEmpty) ? "Unité requise" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: "Prix unitaire ($currency)"),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null) return "Nombre invalide";
                          if (double.parse(value) < 0) return "Doit être positif";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annuler", style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newPrice = UnitPrice(
                        id: existingPrice?.id ?? '',
                        designation: designationController.text.trim(),
                        category: selectedCategory,
                        unit: unitController.text.trim(),
                        price: double.parse(priceController.text),
                        currency: currency,
                      );
                      await appState.updateUnitPrice(newPrice);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(existingPrice == null ? "Prix ajouté !" : "Prix modifié !"),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2A44)),
                  child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final prices = appState.unitPrices;

    // Group prices by category
    final Map<String, List<UnitPrice>> groupedPrices = {};
    for (var price in prices) {
      groupedPrices.putIfAbsent(price.category, () => []).add(price);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Prix Unitaires",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: "Réinitialiser",
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: SafeArea(
        child: prices.isEmpty
            ? const Center(child: Text("Aucun prix unitaire enregistré."))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: groupedPrices.length,
                itemBuilder: (context, index) {
                  final category = groupedPrices.keys.elementAt(index);
                  final categoryPrices = groupedPrices[category]!;

                  return Card(
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2A44),
                            ),
                          ),
                          const Divider(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryPrices.length,
                            separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            itemBuilder: (context, i) {
                              final price = categoryPrices[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            price.designation,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Unité : ${price.unit}",
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          FormatterService.formatCurrency(price.price, price.currency),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E8E5A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 16, color: Colors.amber),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () => _showPriceFormDialog(context, existingPrice: price),
                                        ),
                                        if (price.id.startsWith('custom_') || !price.id.startsWith('p_'))
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 16, color: Color(0xFFDC2626)),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(4),
                                            onPressed: () async {
                                              await appState.deleteUnitPrice(price.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Prix supprimé")),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPriceFormDialog(context),
        backgroundColor: const Color(0xFF1E8E5A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
