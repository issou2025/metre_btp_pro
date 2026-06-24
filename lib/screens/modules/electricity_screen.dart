import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class ElectricityScreen extends StatelessWidget {
  const ElectricityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'electricity',
      title: 'Électricité',
      moduleIds: ['points_lumineux', 'prises', 'interrupteurs', 'cables', 'gaines'],
    );
  }
}
