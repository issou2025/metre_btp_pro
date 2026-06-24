import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class SanitationScreen extends StatelessWidget {
  const SanitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'plumbing',
      title: 'Assainissement',
      moduleIds: ['fosse_septique', 'puisard'],
    );
  }
}
