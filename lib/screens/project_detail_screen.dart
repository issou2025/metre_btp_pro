import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../models/measurement_item_model.dart';
import '../providers/app_state.dart';
import '../widgets/quantity_table.dart';
import '../widgets/primary_button.dart';
import '../services/formatter_service.dart';
import 'module_category_screen.dart';
import 'summary_screen.dart';
import 'pdf_preview_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

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
        title: const Text("Modifier la ligne de métré"),
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
                  const SnackBar(content: Text("Ligne de métré mise à jour"), backgroundColor: Color(0xFF16A34A)),
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
        appBar: AppBar(title: const Text("Détails du Projet")),
        body: const Center(child: Text("Aucun projet sélectionné.")),
      );
    }

    final double totalAmount = project.items.fold(0.0, (sum, item) => sum + item.amount);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDarkMode ? const Color(0xFF0A1929) : const Color(0xFFF7F8FA);
    final cardBgColor = isDarkMode ? const Color(0xFF0E2238) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmallScreen = width < 360;
            
            // Adjust buttons spacing and height dynamically
            final btnGridRatio = isSmallScreen ? 1.35 : 1.1;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. INFO CARD (Custom Container with borders and soft shadows)
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isDarkMode ? Colors.white : const Color(0xFF0F2A44)).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                project.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF0F2A44),
                                ),
                              ),
                            ),
                            Text(
                              FormatterService.formatDate(project.date),
                              style: TextStyle(fontSize: 12, color: textMutedColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (project.client.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 14, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Client : ${project.client}",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF111827)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (project.location.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Localité : ${project.location}",
                                    style: TextStyle(fontSize: 13, color: textMutedColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (project.observations.isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(
                            "Observations :",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMutedColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.observations,
                            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey.shade300 : const Color(0xFF374151)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. BIG COST BANNER (Gradient styled)
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E8E5A), Color(0xFF16A34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E8E5A).withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TOTAL ESTIMÉ HT",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Devis Quantitatif Estimatif",
                              style: TextStyle(fontSize: 11, color: Colors.white60, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        Text(
                          FormatterService.formatCurrency(totalAmount, project.currency),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. ACTION BUTTONS GRID (Responsive ratio)
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    childAspectRatio: btnGridRatio,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDetailActionButton(
                        icon: Icons.add_circle,
                        label: "Ajouter\nMétré",
                        color: const Color(0xFF1E8E5A),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ModuleCategoryScreen(isStandalone: false)),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                      _buildDetailActionButton(
                        icon: Icons.summarize,
                        label: "Récap.\nComplet",
                        color: const Color(0xFF0F2A44),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SummaryScreen()),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                      _buildDetailActionButton(
                        icon: Icons.picture_as_pdf,
                        label: "Exporter\nPDF",
                        color: const Color(0xFFDC2626),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PdfPreviewScreen()),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  // 3.5. COST BREAKDOWN VISUAL CHART (Only if project has items)
                  if (project.items.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildCostBreakdownCard(context, project.items, project.currency, isDarkMode),
                  ],

                  const SizedBox(height: 20),

                  // 4. EMBEDDED DQE TABLE
                  Row(
                    children: [
                      Icon(Icons.table_rows, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "LIGNES DE MÉTRÉ ENREGISTRÉES",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  QuantityTable(
                    items: project.items,
                    currency: project.currency,
                    onEdit: (item) => _showEditItemDialog(context, project.id, item),
                    onDelete: (item) => _confirmDeleteItem(context, project.id, item),
                    onDuplicate: (item) {
                      appState.duplicateMeasurementItem(project.id, item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ligne dupliquée !"), backgroundColor: Color(0xFF16A34A)),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCostBreakdownCard(BuildContext context, List<MeasurementItem> items, String currency, bool isDarkMode) {
    final Map<String, double> categoryCosts = {};
    double total = 0.0;
    for (var item in items) {
      categoryCosts[item.category] = (categoryCosts[item.category] ?? 0.0) + item.amount;
      total += item.amount;
    }

    final sortedCategories = categoryCosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colorsList = [
      const Color(0xFF0F2A44),
      const Color(0xFF1E8E5A),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];

    final cardBgColor = isDarkMode ? const Color(0xFF0E2238) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final labelColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: isDarkMode ? Colors.white70 : const Color(0xFF0F2A44), size: 16),
              const SizedBox(width: 8),
              Text(
                "RÉPARTITION DES COÛTS PAR LOT",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: sortedCategories.map((entry) {
                  final fraction = entry.value / total;
                  final index = sortedCategories.indexOf(entry) % colorsList.length;
                  final color = colorsList[index];
                  
                  return Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Container(
                      color: color,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: sortedCategories.take(4).map((entry) {
              final index = sortedCategories.indexOf(entry) % colorsList.length;
              final color = colorsList[index];
              final cost = entry.value;
              final percent = (cost / total) * 100;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${percent.toStringAsFixed(1)}% (${FormatterService.formatCurrency(cost, currency)})",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cost / total,
                        color: color,
                        backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade100,
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (sortedCategories.length > 4)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "+ ${sortedCategories.length - 4} autres lots de travaux",
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final baseBgColor = isDarkMode ? const Color(0xFF0E2238) : Colors.white;
    final cardBgColor = Color.alphaBlend(color.withOpacity(isDarkMode ? 0.08 : 0.04), baseBgColor);
    final borderColor = isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.12);
    
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F2A44),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
