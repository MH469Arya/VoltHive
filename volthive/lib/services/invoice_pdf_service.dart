import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:volthive/features/billing/data/models/invoice_model.dart';

class InvoicePdfService {
  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  static final _primaryColor = PdfColor.fromHex('#10B981');

  /// Builds the PDF bytes for [invoice].
  static Future<Uint8List> _buildPdfBytes({
    required InvoiceModel invoice,
    required String userName,
    required String userEmail,
  }) async {
    final pdf = pw.Document();

    // Use Google Fonts (downloaded at first use, cached after)
    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final base = pw.TextStyle(font: regularFont, fontSize: 10);
    final bold = pw.TextStyle(font: boldFont, fontSize: 10);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ─── Header ─────────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Brand
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: _primaryColor,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text('⚡ VoltHive',
                          style: bold.copyWith(
                              fontSize: 20, color: PdfColors.white)),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Energy as a Service Platform',
                        style: base.copyWith(color: PdfColors.grey600)),
                    pw.Text('support@volthive.in',
                        style: base.copyWith(color: PdfColors.grey600)),
                  ],
                ),
                // Invoice meta
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE',
                        style: bold.copyWith(
                            fontSize: 22, color: _primaryColor)),
                    pw.SizedBox(height: 4),
                    pw.Text(invoice.id, style: bold),
                    pw.Text(
                        'Date: ${_dateFormat.format(invoice.date)}',
                        style: base),
                    pw.Text(
                        'Due:   ${_dateFormat.format(invoice.dueDate)}',
                        style: base),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // ─── Billed To ──────────────────────────────────────────────
            pw.Text('BILLED TO',
                style: bold.copyWith(color: PdfColors.grey500, fontSize: 9)),
            pw.SizedBox(height: 4),
            pw.Text(userName,
                style: bold.copyWith(fontSize: 13)),
            pw.Text(userEmail, style: base),

            pw.SizedBox(height: 24),

            // ─── Table header ────────────────────────────────────────────
            pw.Container(
              color: PdfColors.grey100,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(children: [
                pw.Expanded(flex: 4, child: pw.Text('Description', style: bold)),
                pw.Expanded(flex: 2, child: pw.Text('Period', style: bold)),
                pw.Expanded(
                    child: pw.Text('Amount',
                        style: bold, textAlign: pw.TextAlign.right)),
              ]),
            ),
            pw.Divider(color: PdfColors.grey400, height: 1),

            // ─── Table row ───────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              '${invoice.planName} Plan — Monthly Subscription',
                              style: bold),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              'Solar + Battery Storage + 24×7 Monitoring',
                              style: base.copyWith(
                                  color: PdfColors.grey600)),
                          pw.SizedBox(height: 6),
                          pw.Text('✓ 24×7 AI monitoring', style: base),
                          pw.Text('✓ Priority fault resolution', style: base),
                          pw.Text('✓ Net-metering ready (DISCOM simulated)', style: base),
                        ]),
                  ),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(invoice.period, style: base)),
                  pw.Expanded(
                    child: pw.Text(
                        _currencyFormat.format(invoice.amount),
                        style: bold,
                        textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
            ),
            pw.Divider(color: PdfColors.grey300),

            pw.SizedBox(height: 16),

            // ─── Energy & Carbon Impact Summary ───────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _primaryColor, width: 1),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColor.fromHex('#F8FAFC'),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                   pw.Text('THIS MONTH\'S IMPACT',
                      style: bold.copyWith(color: _primaryColor)),
                   pw.SizedBox(height: 8),
                   _totalRow('Solar Generation', '1,248 kWh', base, bold.copyWith(color: _primaryColor)),
                   pw.SizedBox(height: 4),
                   _totalRow('Battery Backup Used', '87 hours', base, base),
                   pw.SizedBox(height: 4),
                   _totalRow('Savings This Month', '₹1,248', base, base),
                   pw.SizedBox(height: 4),
                   _totalRow('Carbon Avoided', '87 kg CO₂  (≈ 4 trees planted)', base, bold.copyWith(color: _primaryColor)),
                ]
              )
            ),

            pw.SizedBox(height: 16),

            // ─── Totals and QR Code Section ──────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // QR Code
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      height: 60,
                      width: 60,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'https://volthive.in/dashboard',
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Scan to view real-time\nenergy dashboard',
                        style: base.copyWith(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
                
                // Totals
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _totalRow('Subtotal',
                        _currencyFormat.format(invoice.amount), base, bold),
                    pw.SizedBox(height: 3),
                    _totalRow('GST (18%)', 'Included', base, base),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: pw.BoxDecoration(
                          color: _primaryColor,
                          borderRadius: pw.BorderRadius.circular(4)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                           pw.Text(
                              'TOTAL  ${_currencyFormat.format(invoice.amount)}',
                              style: bold.copyWith(
                                  color: PdfColors.white, fontSize: 12)),
                           if (invoice.status == 'paid') ...[
                              pw.SizedBox(height: 2),
                              pw.Text('PAID IN FULL ✓',
                                style: bold.copyWith(color: PdfColors.white, fontSize: 9)),
                           ]
                        ]
                      )
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Next Billing Date: ${_dateFormat.format(invoice.date.add(const Duration(days: 30)))}', style: base),
                    pw.Text('Auto-renews unless cancelled', style: base.copyWith(color: PdfColors.grey600, fontSize: 8)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ─── Status badge & Gateway Proof ──────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: pw.BoxDecoration(
                color: invoice.status == 'paid'
                    ? _primaryColor
                    : PdfColor.fromHex('#F59E0B'),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                invoice.status == 'paid'
                    ? '✓  PAYMENT RECEIVED'
                    : invoice.status.toUpperCase(),
                style: bold.copyWith(color: PdfColors.white, fontSize: 11),
              ),
            ),
            if (invoice.status == 'paid') ...[
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                     pw.Text('Transaction ID: VH-PAY-${DateFormat('yyyyMMdd').format(invoice.date)}-${(invoice.amount).toInt()}', style: bold.copyWith(fontSize: 9)),
                     pw.SizedBox(height: 2),
                     pw.Text('Paid via VoltHive Secure Gateway • SUCCESS', style: base.copyWith(color: _primaryColor, fontSize: 9)),
                     pw.SizedBox(height: 2),
                     pw.Text('Reference: VH-REF-${invoice.id.replaceAll('INV-', '')} • Processed on ${_dateFormat.format(invoice.date)}', style: base.copyWith(fontSize: 8, color: PdfColors.grey600)),
                  ]
                )
              )
            ],

            pw.Spacer(),

            // ─── Footer ───────────────────────────────────────────────────
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Thank you for choosing VoltHive — powering a greener tomorrow.',
                style: base.copyWith(color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'Your subscription helps India reduce 1,044 kg CO₂ per year.',
                style: bold.copyWith(color: _primaryColor),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'Chat with our AI Advisor anytime | support@volthive.in',
                style: base.copyWith(color: PdfColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _totalRow(
      String label, String value, pw.TextStyle labelStyle, pw.TextStyle valStyle) {
    return pw.Row(children: [
      pw.Text('$label:  ', style: labelStyle),
      pw.Text(value, style: valStyle),
    ]);
  }

  /// Opens system share sheet with the PDF.
  static Future<void> sharePdf({
    required InvoiceModel invoice,
    required String userName,
    required String userEmail,
  }) async {
    final bytes = await _buildPdfBytes(
        invoice: invoice, userName: userName, userEmail: userEmail);
    final fileName = 'VoltHive_Invoice_${invoice.id}_${userName.replaceAll(' ', '')}_${invoice.planName}Plan.pdf';
    await Printing.sharePdf(
        bytes: bytes, filename: fileName);
  }

  /// Opens the native print/preview dialog.
  static Future<void> previewPdf({
    required InvoiceModel invoice,
    required String userName,
    required String userEmail,
  }) async {
    final fileName = 'VoltHive_Invoice_${invoice.id}_${userName.replaceAll(' ', '')}_${invoice.planName}Plan.pdf';
    await Printing.layoutPdf(
      onLayout: (_) => _buildPdfBytes(
          invoice: invoice, userName: userName, userEmail: userEmail),
      name: fileName,
    );
  }
}
