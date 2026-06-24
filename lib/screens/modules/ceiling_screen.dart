import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class CeilingScreen extends StatelessWidget {
  const CeilingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'finishes',
      title: 'Faux Plafond',
      moduleIds: ['faux_plafond'],
    );
  }
}
