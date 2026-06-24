import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class DoorsWindowsScreen extends StatelessWidget {
  const DoorsWindowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'doors_windows',
      title: 'Menuiseries',
      moduleIds: ['portes', 'fenetres'],
    );
  }
}
