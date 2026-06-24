import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class StaircaseScreen extends StatelessWidget {
  const StaircaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'concrete',
      title: 'Escaliers',
      moduleIds: ['escalier_beton'],
    );
  }
}
