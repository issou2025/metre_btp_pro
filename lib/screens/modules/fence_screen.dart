import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class FenceScreen extends StatelessWidget {
  const FenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'vrd',
      title: 'Clôture',
      moduleIds: ['mur_cloture'],
    );
  }
}
