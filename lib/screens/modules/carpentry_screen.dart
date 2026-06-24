import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class CarpentryScreen extends StatelessWidget {
  const CarpentryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'roofing',
      title: 'Charpente Bois',
      moduleIds: ['toiture_simple_pente', 'toiture_double_pente'],
    );
  }
}
