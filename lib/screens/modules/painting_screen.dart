import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class PaintingScreen extends StatelessWidget {
  const PaintingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'finishes',
      title: 'Peinture',
      moduleIds: ['peinture_interieure', 'peinture_exterieure'],
    );
  }
}
