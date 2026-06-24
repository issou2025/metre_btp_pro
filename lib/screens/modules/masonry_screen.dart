import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class MasonryScreen extends StatelessWidget {
  const MasonryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'masonry',
      title: 'Maçonnerie',
    );
  }
}
