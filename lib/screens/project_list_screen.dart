import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_state.dart';
import '../widgets/project_card.dart';
import 'project_create_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  /// Confirm and delete a project
  void _confirmDelete(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer le projet ?"),
        content: Text("Êtes-vous sûr de vouloir supprimer définitivement le projet \"${project.name}\" ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).deleteProject(project.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Projet supprimé"), backgroundColor: Color(0xFFDC2626)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Show dialog to edit project metadata
  void _showEditDialog(BuildContext context, Project project) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: project.name);
    final clientController = TextEditingController(text: project.client);
    final locationController = TextEditingController(text: project.location);
    final obsController = TextEditingController(text: project.observations);
    String selectedType = project.type;
    String selectedCurrency = project.currency;

    final List<String> types = [
      "Maison individuelle", "Villa", "Immeuble", "Mur de clôture", 
      "Boutique", "École", "Latrines", "Magasin", "Bâtiment administratif", "Autre"
    ];
    final List<String> currencies = ["FCFA", "EUR", "USD", "MGA", "Ar"];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Modifier le projet"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Nom du projet"),
                        validator: (value) => (value == null || value.trim().isEmpty) ? "Nom requis" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: clientController,
                        decoration: const InputDecoration(labelText: "Client"),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(labelText: "Localisation"),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: "Type de projet"),
                        items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          if (val != null) setStateDialog(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        decoration: const InputDecoration(labelText: "Devise"),
                        items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setStateDialog(() => selectedCurrency = val);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: obsController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: "Observations"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annuler", style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updated = project.copyWith(
                        name: nameController.text.trim(),
                        client: clientController.text.trim(),
                        location: locationController.text.trim(),
                        type: selectedType,
                        currency: selectedCurrency,
                        observations: obsController.text.trim(),
                      );
                      Provider.of<AppState>(context, listen: false).updateProject(updated);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Projet mis à jour !"), backgroundColor: Color(0xFF16A34A)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2A44)),
                  child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final projects = appState.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Projets",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: projects.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "Aucun projet pour le moment.",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Appuyez sur le bouton '+' pour créer votre premier projet.",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      appState.selectProject(project);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProjectDetailScreen()),
                      );
                    },
                    onEdit: () => _showEditDialog(context, project),
                    onDelete: () => _confirmDelete(context, project),
                    onDuplicate: () {
                      appState.duplicateProject(project);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Projet dupliqué avec succès"), backgroundColor: Color(0xFF16A34A)),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectCreateScreen()),
          );
        },
        backgroundColor: const Color(0xFF1E8E5A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
