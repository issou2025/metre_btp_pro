import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class ConcreteScreen extends StatelessWidget {
  const ConcreteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'concrete',
      title: 'Béton',
    );
  }
}
