import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class PlumbingScreen extends StatelessWidget {
  const PlumbingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'plumbing',
      title: 'Plomberie',
      moduleIds: ['tuyauterie_eau_froide', 'tuyauterie_eau_chaude', 'appareils_sanitaires'],
    );
  }
}
