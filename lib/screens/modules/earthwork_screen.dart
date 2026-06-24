import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class EarthworkScreen extends StatelessWidget {
  const EarthworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'earthworks',
      title: 'Terrassements',
    );
  }
}
