import 'package:flutter/material.dart';
import 'base_module_screen.dart';

class MiscellaneousScreen extends StatelessWidget {
  const MiscellaneousScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseModuleScreen(
      categoryId: 'miscellaneous',
      title: 'Divers',
      moduleIds: [
        'installation_chantier',
        'nettoyage_chantier',
        'transport_materiaux',
        'main_oeuvre',
        'marge_imprevus'
      ],
    );
  }
}
