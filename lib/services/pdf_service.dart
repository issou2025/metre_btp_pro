import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/project_model.dart';
import '../models/company_model.dart';
import '../models/measurement_item_model.dart';
import 'formatter_service.dart';

class PdfService {
  /// Generate a PDF document bytes for the project.
  static Future<Uint8List> generatePdfBytes(Project project, CompanyInfo company) async {
    final pdf = await generateDocument(project, company);
    return pdf.save();
  }

  /// Generate the PDF Document object.
  static Future<pw.Document> generateDocument(Project project, CompanyInfo company) async {
    final pdf = pw.Document();

    // Group items by category
    final Map<String, List<MeasurementItem>> groupedItems = {};
    for (var item in project.items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    // Calculate total general
    double totalGeneral = project.items.fold(0.0, (sum, item) => sum + item.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Company Header & Document Title
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Company Details (Left)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        company.name.toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColor.fromHex('#0F2A44')),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text("Adresse : ${company.address}", style: const pw.TextStyle(fontSize: 9)),
                      pw.Text("Tél : ${company.phone}", style: const pw.TextStyle(fontSize: 9)),
                      pw.Text("Email : ${company.email}", style: const pw.TextStyle(fontSize: 9)),
                      if (company.nif.isNotEmpty)
                        pw.Text("NIF : ${company.nif}", style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                // Title (Right)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "DEVIS QUANTITATIF",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColor.fromHex('#1E8E5A')),
                    ),
                    pw.Text(
                      "ESTIMATIF (DQE)",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColor.fromHex('#1E8E5A')),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text("Date : ${FormatterService.formatDate(project.date)}", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("Devise : ${project.currency}", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 15),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 10),

            // Project & Client Info Cards
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Project Details
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("PROJET", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColor.fromHex('#0F2A44'))),
                        pw.SizedBox(height: 4),
                        pw.Text("Nom : ${project.name}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text("Type : ${project.type}", style: const pw.TextStyle(fontSize: 9)),
                        pw.Text("Localité : ${project.location}", style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                // Client Details
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("CLIENT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColor.fromHex('#0F2A44'))),
                        pw.SizedBox(height: 4),
                        pw.Text("Nom : ${project.client.isNotEmpty ? project.client : 'N/A'}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text("Date de création : ${FormatterService.formatDate(project.createdAt)}", style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Quantities Table (DQE)
            if (project.items.isEmpty)
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 20),
                  child: pw.Text("Aucun élément de métré enregistré dans ce projet.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                ),
              )
            else
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _buildDQETables(groupedItems, project.currency),
              ),

            pw.SizedBox(height: 15),

            // Totals Summary
            pw.Row(
              children: [
                pw.Spacer(flex: 1),
                pw.Expanded(
                  flex: 1,
                  child: pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    children: [
                      _buildTotalRow("TOTAL GENERAL HT", totalGeneral, project.currency, isBold: true),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            // Observations Box
            if (project.observations.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Observations :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.SizedBox(height: 4),
                    pw.Text(project.observations, style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            // Signature Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Signature du Client", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.SizedBox(height: 50),
                    pw.Text("......................................", style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Signature de l'Entreprise", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.SizedBox(height: 50),
                    pw.Text("......................................", style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 30),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Document généré par Métré BTP Pro", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                pw.Text("Page ${context.pageNumber} sur ${context.pagesCount}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// Builds a sequence of tables grouped by category with category subtotals.
  static List<pw.Widget> _buildDQETables(Map<String, List<MeasurementItem>> groupedItems, String currency) {
    final List<pw.Widget> widgets = [];
    int itemIndex = 1;

    for (var entry in groupedItems.entries) {
      final category = entry.key;
      final items = entry.value;
      double categorySubtotal = items.fold(0.0, (sum, item) => sum + item.amount);

      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
          child: pw.Text(
            category.toUpperCase(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColor.fromHex('#0F2A44')),
          ),
        ),
      );

      final List<pw.TableRow> rows = [];
      
      // Header row
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#0F2A44'),
          ),
          children: [
            _buildHeaderCell("N°", width: 30),
            _buildHeaderCell("Désignation", alignLeft: true),
            _buildHeaderCell("Unité", width: 45),
            _buildHeaderCell("Qté", width: 60),
            _buildHeaderCell("Prix U.", width: 75),
            _buildHeaderCell("Montant", width: 85),
          ],
        ),
      );

      // Item rows
      for (var item in items) {
        rows.add(
          pw.TableRow(
            children: [
              _buildTableCell(itemIndex.toString(), alignCenter: true),
              _buildTableCell(item.designation, alignLeft: true),
              _buildTableCell(item.unit, alignCenter: true),
              _buildTableCell(FormatterService.formatQuantity(item.quantity)),
              _buildTableCell(FormatterService.formatCurrency(item.unitPrice, currency).replaceAll(" $currency", "")),
              _buildTableCell(FormatterService.formatCurrency(item.amount, currency).replaceAll(" $currency", "")),
            ],
          ),
        );
        itemIndex++;
      }

      // Subtotal row for this category
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell(""),
            _buildTableCell("Sous-total $category", alignLeft: true, isBold: true),
            _buildTableCell(""),
            _buildTableCell(""),
            _buildTableCell(""),
            _buildTableCell(FormatterService.formatCurrency(categorySubtotal, currency).replaceAll(" $currency", ""), isBold: true),
          ],
        ),
      );

      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: const {
            0: pw.FixedColumnWidth(30),
            1: pw.FlexColumnWidth(),
            2: pw.FixedColumnWidth(45),
            3: pw.FixedColumnWidth(60),
            4: pw.FixedColumnWidth(75),
            5: pw.FixedColumnWidth(85),
          },
          children: rows,
        ),
      );

      widgets.add(pw.SizedBox(height: 10));
    }

    return widgets;
  }

  static pw.Widget _buildHeaderCell(String text, {double? width, bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 8,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool alignLeft = false, bool alignCenter = false, bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      alignment: alignLeft 
          ? pw.Alignment.centerLeft 
          : (alignCenter ? pw.Alignment.center : pw.Alignment.centerRight),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.TableRow _buildTotalRow(String label, double amount, String currency, {bool isBold = false}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E8E5A').shade(0.1),
      ),
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F2A44'),
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            FormatterService.formatCurrency(amount, currency),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1E8E5A'),
            ),
          ),
        ),
      ],
    );
  }
}
