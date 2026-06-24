import 'package:flutter/material.dart';
import '../models/measurement_item_model.dart';
import '../services/formatter_service.dart';

class QuantityTable extends StatelessWidget {
  final List<MeasurementItem> items;
  final String currency;
  final void Function(MeasurementItem) onEdit;
  final void Function(MeasurementItem) onDelete;
  final void Function(MeasurementItem) onDuplicate;

  const QuantityTable({
    super.key,
    required this.items,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.content_paste_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "Aucune ligne de métré insérée.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Alternating background colors
    Color getRowColor(int index) {
      return index % 2 == 0 ? Colors.white : const Color(0xFFF9FAFB);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF0F2A44)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: const [
            DataColumn(label: Text('N°')),
            DataColumn(label: Text('Désignation')),
            DataColumn(label: Text('Catégorie')),
            DataColumn(label: Text('Unité')),
            DataColumn(label: Text('Qté')),
            DataColumn(label: Text('Prix U.')),
            DataColumn(label: Text('Montant')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List<DataRow>.generate(items.length, (index) {
            final item = items[index];
            return DataRow(
              color: WidgetStateProperty.all(getRowColor(index)),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.designation,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (item.notes.isNotEmpty)
                        Text(
                          item.notes,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                DataCell(Text(item.unit)),
                DataCell(Text(FormatterService.formatQuantity(item.quantity))),
                DataCell(Text(FormatterService.formatCurrency(item.unitPrice, currency).replaceAll(" $currency", ""))),
                DataCell(
                  Text(
                    FormatterService.formatCurrency(item.amount, currency).replaceAll(" $currency", ""),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E8E5A)),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16, color: Color(0xFF0F2A44)),
                        tooltip: 'Dupliquer',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () => onDuplicate(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: Colors.amber),
                        tooltip: 'Modifier',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () => onEdit(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16, color: Color(0xFFDC2626)),
                        tooltip: 'Supprimer',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () => onDelete(item),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
