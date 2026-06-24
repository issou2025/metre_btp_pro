import 'package:flutter/material.dart';
import '../services/formatter_service.dart';

class ResultCard extends StatelessWidget {
  final double quantity;
  final String unit;
  final double amount;
  final String currency;
  final String formula;
  final Map<String, double> additionalInfo;
  final VoidCallback? onAddToProject;
  final String buttonText;

  const ResultCard({
    super.key,
    required this.quantity,
    required this.unit,
    required this.amount,
    required this.currency,
    required this.formula,
    this.additionalInfo = const {},
    this.onAddToProject,
    this.buttonText = "Ajouter au récapitulatif",
  });

  @override
  Widget build(BuildContext context) {
    final hasAdditionalInfo = additionalInfo.isNotEmpty;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFF1E8E5A),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            const Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF1E8E5A), size: 20),
                SizedBox(width: 8),
                Text(
                  "RÉSULTATS DU CALCUL",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF1E8E5A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quantity Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  "Quantité calculée :",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      FormatterService.formatQuantity(quantity),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2A44),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E8E5A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Amount Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Montant estimé :",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  FormatterService.formatCurrency(amount, currency),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E8E5A),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Formula
            if (formula.isNotEmpty) ...[
              const Text(
                "Formule appliquée :",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formula,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Additional Info
            if (hasAdditionalInfo) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: additionalInfo.entries.map((entry) {
                    final isSacs = entry.key.toLowerCase().contains("sac") ||
                        entry.key.toLowerCase().contains("ciment");
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            isSacs
                                ? "${entry.value.toStringAsFixed(1)} sacs"
                                : FormatterService.formatQuantity(entry.value),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSacs ? Colors.brown.shade700 : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add to Project Button
            if (onAddToProject != null)
              ElevatedButton.icon(
                onPressed: onAddToProject,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                label: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8E5A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
