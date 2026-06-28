import 'package:flutter/material.dart';
import '../../services/module_registry.dart';
import '../../widgets/module_card.dart';
import '../../widgets/dynamic_module_calculator.dart';

class BaseModuleScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final List<String>? moduleIds;

  const BaseModuleScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.moduleIds,
  });

  @override
  State<BaseModuleScreen> createState() => _BaseModuleScreenState();
}

class _BaseModuleScreenState extends State<BaseModuleScreen> {
  ModuleDef? _selectedModule;

  @override
  Widget build(BuildContext context) {
    var modules = ModuleRegistry.getModulesByCategory(widget.categoryId);
    if (widget.moduleIds != null) {
      modules = modules.where((m) => widget.moduleIds!.contains(m.id)).toList();
      // fallback search globally
      if (modules.isEmpty) {
        modules = ModuleRegistry.allModules.where((m) => widget.moduleIds!.contains(m.id)).toList();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedModule == null ? widget.title : _selectedModule!.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _selectedModule == null
          ? _buildModuleList(modules)
          : _buildCalculatorView(),
    );
  }

  Widget _buildModuleList(List<ModuleDef> modules) {
    if (modules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Aucun module de calcul disponible dans cette catégorie.",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: ModuleCard(
            title: module.name,
            category: module.category,
            unit: module.unit,
            onTap: () {
              setState(() {
                _selectedModule = module;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCalculatorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Navigation Back Option
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedModule = null;
              });
            },
            icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF0F2A44)),
            label: const Text(
              "Retour aux modules de la catégorie",
              style: TextStyle(color: Color(0xFF0F2A44), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: Color(0xFF0F2A44), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DynamicModuleCalculator(moduleDef: _selectedModule!),
        ],
      ),
    );
  }
}
