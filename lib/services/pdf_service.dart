import 'package:cotizacion_app/models/qoute.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateQuotePdf(Quote quote) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 24),

            // Info de cotización y cliente
            _buildInfoRow(quote),
            pw.SizedBox(height: 24),

            // Divider
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Tabla de productos
            _buildProductsTable(quote),
            pw.SizedBox(height: 24),

            // Total
            _buildTotal(quote),
            pw.SizedBox(height: 32),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Cotizacion_${quote.clientName}_${quote.createdAt.day}-${quote.createdAt.month}-${quote.createdAt.year}.pdf',
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'COTIZACIÓN',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Cotización App',
                style: pw.TextStyle(
                  color: PdfColors.blue100,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Tu Empresa S.A.',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'info@tuempresa.com',
                style: pw.TextStyle(
                  color: PdfColors.blue100,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                'Tel: +1 (555) 000-0000',
                style: pw.TextStyle(
                  color: PdfColors.blue100,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(Quote quote) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Info del cliente
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CLIENTE',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  quote.clientName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),

        // Info de la cotización
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DETALLES',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                _infoLine('Fecha:',
                    '${quote.createdAt.day}/${quote.createdAt.month}/${quote.createdAt.year}'),
                _infoLine('Estado:', quote.status.toUpperCase()),
                _infoLine('Productos:', '${quote.items.length}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 12, color: PdfColors.grey700)),
          pw.SizedBox(width: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildProductsTable(Quote quote) {
    // Encabezados
    final headers = ['#', 'Producto', 'Precio unit.', 'Cantidad', 'Subtotal'];

    // Filas
    final rows = quote.items.asMap().entries.map((entry) {
      final i    = entry.key + 1;
      final item = entry.value;
      return [
        '$i',
        item.productName,
        '\$${item.price.toStringAsFixed(2)}',
        '${item.quantity}',
        '\$${item.subtotal.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue800),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 8, vertical: 10),
            child: pw.Text(
              h,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
              ),
            ),
          )).toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColors.grey50,
            ),
            children: entry.value.map((cell) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              child: pw.Text(cell, style: const pw.TextStyle(fontSize: 11)),
            )).toList(),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTotal(Quote quote) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                'TOTAL:',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Text(
                '\$${quote.total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Gracias por su preferencia · Esta cotización es válida por 30 días',
            style: const pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}