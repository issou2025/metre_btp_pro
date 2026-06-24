import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class TileScreen extends StatelessWidget {
  const TileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'finishes',
      title: 'Carrelage',
      moduleIds: ['carrelage_sol', 'carrelage_mur'],
    );
  }
}
