import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class SteelStructureScreen extends StatelessWidget {
  const SteelStructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'reinforcement',
      title: 'Charpente Métallique',
      moduleIds: ['treillis_soude'],
    );
  }
}
