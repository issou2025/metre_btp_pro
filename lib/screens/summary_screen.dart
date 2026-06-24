import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../models/measurement_item_model.dart';
import '../providers/app_state.dart';
import '../services/formatter_service.dart';
import 'module_category_screen.dart';
import 'pdf_preview_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  double _discountPercent = 0.0;
  double _contingencyPercent = 0.0;

  /// Show quick edit dialog for a measurement item line
  void _showEditItemDialog(BuildContext context, String projectId, MeasurementItem item) {
    final formKey = GlobalKey<FormState>();
    final designationController = TextEditingController(text: item.designation);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.unitPrice.toString());
    final notesController = TextEditingController(text: item.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifier la ligne"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: designationController,
                  decoration: const InputDecoration(labelText: "Désignation"),
                  validator: (value) => (value == null || value.trim().isEmpty) ? "Désignation requise" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: "Quantité (${item.unit})"),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) return "Nombre invalide";
                    if (double.parse(value) < 0) return "Doit être positif";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Prix unitaire"),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) return "Nombre invalide";
                    if (double.parse(value) < 0) return "Doit être positif";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Notes / Obs"),
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final double qty = double.parse(quantityController.text);
                final double price = double.parse(priceController.text);
                
                final updated = item.copyWith(
                  designation: designationController.text.trim(),
                  quantity: qty,
                  unitPrice: price,
                  amount: qty * price,
                  notes: notesController.text.trim(),
                );

                Provider.of<AppState>(context, listen: false).updateMeasurementItem(projectId, updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ligne mise à jour"), backgroundColor: Color(0xFF16A34A)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2A44)),
            child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Confirm and delete item
  void _confirmDeleteItem(BuildContext context, String projectId, MeasurementItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer la ligne ?"),
        content: Text("Voulez-vous vraiment supprimer la ligne \"${item.designation}\" du projet ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).deleteMeasurementItem(projectId, item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ligne supprimée"), backgroundColor: Color(0xFFDC2626)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final project = appState.currentProject;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Récapitulatif")),
        body: const Center(child: Text("Aucun projet sélectionné.")),
      );
    }

    // Group items by category
    final Map<String, List<MeasurementItem>> groupedItems = {};
    for (var item in project.items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    // Calculate totals
    final double totalHT = project.items.fold(0.0, (sum, item) => sum + item.amount);
    final double contingencyAmount = totalHT * _contingencyPercent / 100.0;
    final double discountAmount = (totalHT + contingencyAmount) * _discountPercent / 100.0;
    final double totalGeneral = (totalHT + contingencyAmount) - discountAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Récapitulatif Financier",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Exporter PDF",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PdfPreviewScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. DYNAMIC ESTIMATES PANEL (Contingencies & Discounts)
              _buildEstimationPanel(totalHT, contingencyAmount, discountAmount, totalGeneral, project.currency),
              const SizedBox(height: 16),

              // 2. HEADER ACTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "RÉPARTITION PAR CATÉGORIES",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF6B7280)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModuleCategoryScreen(isStandalone: false)),
                      );
                    },
                    icon: const Icon(Icons.add_circle, size: 16, color: Color(0xFF1E8E5A)),
                    label: const Text(
                      "Ajouter ligne",
                      style: TextStyle(color: Color(0xFF1E8E5A), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. GROUPED LISTS BY CATEGORY
              if (project.items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      "Aucune ligne de travaux dans ce projet.",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...groupedItems.entries.map((entry) {
                  final category = entry.key;
                  final categoryItems = entry.value;
                  final double subTotal = categoryItems.fold(0.0, (sum, i) => sum + i.amount);

                  return Card(
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category Title & Subtotal Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2A44)),
                              ),
                              Text(
                                "Sous-total : ${FormatterService.formatCurrency(subTotal, project.currency)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E8E5A)),
                              ),
                            ],
                          ),
                          const Divider(height: 16),

                          // List of items in this category
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryItems.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            itemBuilder: (context, index) {
                              final item = categoryItems[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.designation,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                          ),
                                          if (item.notes.isNotEmpty)
                                            Text(
                                              item.notes,
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                            ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${FormatterService.formatQuantity(item.quantity)} ${item.unit} × ${FormatterService.formatCurrency(item.unitPrice, project.currency)}",
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        FormatterService.formatCurrency(item.amount, project.currency),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 16, color: Colors.amber),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () => _showEditItemDialog(context, project.id, item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 16, color: Color(0xFFDC2626)),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () => _confirmDeleteItem(context, project.id, item),
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
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstimationPanel(double totalHT, double contingency, double discount, double totalGeneral, String currency) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "RÉCAPITULATIF GENERAL DU DEVIS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F2A44), letterSpacing: 1.1),
              textAlign: TextAlign.left,
            ),
            const Divider(height: 20),

            // Total HT Row
            _buildCostSummaryRow("Total des travaux HT :", totalHT, currency, isBold: false),
            const SizedBox(height: 8),

            // Imprévus configure
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Imprévus :", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          suffixText: "%",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _contingencyPercent = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Text(
                  "+ ${FormatterService.formatCurrency(contingency, currency)}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Remise configure
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Remise / Rabais :", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          suffixText: "%",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _discountPercent = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Text(
                  "- ${FormatterService.formatCurrency(discount, currency)}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Total General Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL GENERAL ESTIMÉ :",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F2A44)),
                ),
                Text(
                  FormatterService.formatCurrency(totalGeneral, currency),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E8E5A)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummaryRow(String label, double amount, String currency, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          FormatterService.formatCurrency(amount, currency),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isBold ? const Color(0xFF1E8E5A) : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
