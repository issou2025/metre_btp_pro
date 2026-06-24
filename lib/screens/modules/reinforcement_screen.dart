import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class ReinforcementScreen extends StatelessWidget {
  const ReinforcementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'reinforcement',
      title: 'Ferraillage',
    );
  }
}
