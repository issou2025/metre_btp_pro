import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class WaterproofingScreen extends StatelessWidget {
  const WaterproofingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'finishes',
      title: 'Étanchéité',
      moduleIds: ['etancheite'],
    );
  }
}
