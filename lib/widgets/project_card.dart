import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/formatter_service.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final double totalAmount = project.items.fold(0.0, (sum, item) => sum + item.amount);
    final int itemsCount = project.items.length;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Color(0xFF1E8E5A),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line: Title & Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2A44),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6B7280)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      } else if (value == 'duplicate') {
                        onDuplicate();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 16, color: Color(0xFF0F2A44)),
                            SizedBox(width: 8),
                            Text('Dupliquer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Color(0xFFDC2626)),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Color(0xFFDC2626))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Client & Location
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.client.isNotEmpty ? project.client : 'Aucun client',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.location.isNotEmpty ? project.location : 'Non localisé',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date & Type tags
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      project.type,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    FormatterService.formatDate(project.date),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 10),

              // Quantities Count and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_list_bulleted, size: 14, color: Color(0xFF0F2A44)),
                      const SizedBox(width: 4),
                      Text(
                        itemsCount == 0
                            ? 'Aucun élément'
                            : (itemsCount == 1 ? '1 élément' : '$itemsCount éléments'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F2A44),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    FormatterService.formatCurrency(totalAmount, project.currency),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E8E5A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
