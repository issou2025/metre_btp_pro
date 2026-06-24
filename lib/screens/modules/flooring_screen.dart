import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class FlooringScreen extends StatelessWidget {
  const FlooringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'finishes',
      title: 'Chape et Sols',
      moduleIds: ['chape'],
    );
  }
}
