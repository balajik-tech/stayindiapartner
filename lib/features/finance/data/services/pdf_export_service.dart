import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/financial_entities.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<void> exportFinancialReport({
    required String hostelName,
    required FinancialStats stats,
    required List<RevenueTrend> trends,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('STAY INDIA', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Financial Performance Report', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Generated on:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                        pw.Text(dateFormat.format(now), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                
                pw.Text('Property: $hostelName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 30),

                
                pw.Text('Executive Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 15),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    _buildTableRow('Total Revenue', currencyFormat.format(stats.totalRevenue), true),
                    _buildTableRow('This Month Revenue', currencyFormat.format(stats.thisMonthRevenue), false),
                    _buildTableRow('Current Occupancy', '${stats.occupancyRate.toStringAsFixed(1)}%', false),
                    _buildTableRow('Total Capacity', '${stats.totalBeds} Beds', false),
                    _buildTableRow('Pending Payments', currencyFormat.format(stats.pendingPayments), false),
                  ],
                ),
                pw.SizedBox(height: 40),

                
                pw.Text('Recent Revenue Breakdown', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 15),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _buildTableHeader('Date'),
                        _buildTableHeader('Bookings'),
                        _buildTableHeader('Revenue'),
                      ],
                    ),
                    ...trends.take(15).map((t) => pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(t.date)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(t.count.toString())),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(currencyFormat.format(t.revenue))),
                      ],
                    )),
                  ],
                ),

                pw.Spacer(),
                pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('This is a computer-generated report and does not require a signature.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Financial_Report_${hostelName}_${now.millisecondsSinceEpoch}.pdf');
  }

  static pw.TableRow _buildTableRow(String label, String value, bool isHeader) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : null)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }
}
