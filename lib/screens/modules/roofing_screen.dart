import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class RoofingScreen extends StatelessWidget {
  const RoofingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'roofing',
      title: 'Toiture',
      moduleIds: ['toiture_simple_pente', 'toiture_double_pente', 'gouttieres'],
    );
  }
}
