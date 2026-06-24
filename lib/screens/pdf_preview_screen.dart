import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final project = appState.currentProject;
    final company = appState.companyInfo;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Aperçu PDF")),
        body: const Center(child: Text("Aucun projet sélectionné.")),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.logActivity("Aperçu/Export PDF DQE", "Projet: ${project.name}, Lignes: ${project.items.length}");
    });

    final sanitizedFileName = "DQE_${project.name.replaceAll(RegExp(r'[^\w]'), '_')}.pdf";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          "Export DQE PDF : ${project.name}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: PdfPreview(
          build: (format) => PdfService.generatePdfBytes(project, company),
          canChangeOrientation: false,
          canChangePageFormat: false,
          pdfFileName: sanitizedFileName,
          loadingWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2A44))),
                SizedBox(height: 12),
                Text("Génération du devis PDF...", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2A44))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
