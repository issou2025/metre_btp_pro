import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class VrdScreen extends StatelessWidget {
  const VrdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'vrd',
      title: 'VRD',
      moduleIds: ['caniveaux', 'bordures', 'pavage'],
    );
  }
}
