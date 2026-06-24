import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class PlasterScreen extends StatelessWidget {
  const PlasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'finishes',
      title: 'Enduits',
      moduleIds: ['enduit_interieur', 'enduit_exterieur'],
    );
  }
}
