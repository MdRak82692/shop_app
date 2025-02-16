import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:intl/intl.dart';

String numberToWords(int number) {
  final units = [
    "",
    "ONE",
    "TWO",
    "THREE",
    "FOUR",
    "FIVE",
    "SIX",
    "SEVEN",
    "EIGHT",
    "NINE"
  ];
  final teens = [
    "TEN",
    "ELEVEN",
    "TWELVE",
    "THIRTEEN",
    "FOURTEEN",
    "FIFTEEN",
    "SIXTEEN",
    "SEVENTEEN",
    "EIGHTEEN",
    "NINETEEN"
  ];
  final tens = [
    "",
    "TEN",
    "TWENTY",
    "THIRTY",
    "FORTY",
    "FIFTY",
    "SIXTY",
    "SEVENTY",
    "EIGHTY",
    "NINETY"
  ];

  if (number < 10) return units[number];
  if (number < 20) return teens[number - 10];
  if (number < 100) return "${tens[number ~/ 10]} ${units[number % 10]}";
  if (number < 1000) {
    return "${units[number ~/ 100]} HUNDRED ${numberToWords(number % 100)}";
  }
  if (number < 100000) {
    return "${numberToWords(number ~/ 1000)} THOUSAND ${numberToWords(number % 1000)}";
  }
  if (number < 10000000) {
    return "${numberToWords(number ~/ 1000)} LAKHS ${numberToWords(number % 1000)}";
  }
  return "NUMBER TOO LARGE";
}

Future<Uint8List> generateSalesPDF(Map<String, dynamic> record) async {
  final pdf = pw.Document();

  final fontData = await rootBundle.load("assets/fonts/times new roman.ttf");
  final ttf = pw.Font.ttf(fontData);

  final fontBold =
      await rootBundle.load("assets/fonts/times new roman bold.ttf");
  final ttfBold = pw.Font.ttf(fontBold);

  final ByteData imageData = await rootBundle.load("assets/icons/logo.png");
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

  final DateTime now = DateTime.now();

  double totalAmount = 0;
  if (record['items'] != null) {
    for (var item in record['items']) {
      totalAmount += item['productPrice'];
    }
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 50, height: 50),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      "Manik Store",
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: PdfColors.red,
                        font: ttfBold,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1.5),
                  ),
                  child: pw.Text(
                    "Invoice/Bill",
                    style: pw.TextStyle(
                      fontSize: 16,
                      font: ttfBold,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "FRUITS & GROCERY SALES & DISTRIBUTION",
                        style: pw.TextStyle(font: ttfBold),
                      ),
                      pw.Text(
                        "SHOP: 19 K.B. Fazlul Kader Road, Opposite Side of Medical Main Gate,\n"
                        "              Panchlashish, Chattogram, Bangladesh\n"
                        "MOBILE: 01864391865, 018198161518\n"
                        "EMAIL: mdrak82692@gmail.com",
                        style: pw.TextStyle(
                          font: ttfBold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Invoice No: ${record['id']}\n"
                        "Sold Date: ${DateFormat('dd MMM yyyy').format((record['time'] as Timestamp).toDate())}\n"
                        "Sold Time: ${DateFormat('hh:mm a').format((record['time'] as Timestamp).toDate())}\n"
                        "Print Date: ${DateFormat('dd MMM yyyy').format(now)}\n"
                        "Print Time: ${DateFormat('hh:mm a').format(now)}",
                        style: pw.TextStyle(
                          font: ttfBold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child:
                            pw.Text("SL", style: pw.TextStyle(font: ttfBold)),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child: pw.Text("Description",
                            style: pw.TextStyle(font: ttfBold)),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child:
                            pw.Text("Qty", style: pw.TextStyle(font: ttfBold)),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child: pw.Text("Unit Price",
                            style: pw.TextStyle(font: ttfBold)),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child: pw.Text("Amount",
                            style: pw.TextStyle(font: ttfBold)),
                      ),
                    ),
                  ],
                ),
                ...(record['items'] != null
                    ? List.generate(
                        record['items'].length,
                        (index) {
                          final item = record['items'][index];
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Center(
                                  child: pw.Text(
                                    (index + 1).toString(),
                                    style: pw.TextStyle(font: ttf),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  item['productName'],
                                  style: pw.TextStyle(font: ttf),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Center(
                                  child: pw.Text(
                                    item['quantity'].toStringAsFixed(0),
                                    style: pw.TextStyle(font: ttf),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Center(
                                  child: pw.Text(
                                    item['pricePerProduct'].toStringAsFixed(2),
                                    style: pw.TextStyle(font: ttf),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  item['productPrice'].toStringAsFixed(2),
                                  style: pw.TextStyle(font: ttf),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : []),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PAID",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        font: ttfBold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(width: 240),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Total Amount",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: ttfBold,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Discount",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: ttfBold,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              "Net Payable Amount",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                font: ttfBold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 30),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              totalAmount.toStringAsFixed(2),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: ttfBold,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              record['discount']?.toStringAsFixed(2) ?? '0.00',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: ttfBold,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              record['sale'].toStringAsFixed(2),
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                font: ttfBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text("TAKA: ${numberToWords(record['sale'].toInt())} TAKA ONLY",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, font: ttfBold)),
            pw.SizedBox(height: 150),
            pw.Container(
              height: 3,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: pw.Container(
                      height: 2,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Positioned(
                    bottom: 0,
                    left: 120,
                    right: 0,
                    child: pw.Container(
                      height: 2,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Positioned(
                    bottom: 0,
                    left: 360,
                    right: 0,
                    child: pw.Container(
                      height: 2,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Customer Signature",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, font: ttfBold)),
                pw.Text("Authorized Signature",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, font: ttfBold)),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                "N.B: Once a product is sold, it becomes your property, and its purchase is considered final. Returns are not accepted under any circumstances, ensuring a seamless transaction for all.",
                style: pw.TextStyle(font: ttfBold),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
      },
    ),
  );
  return pdf.save();
}

Future<String> savePDFToFile(Uint8List pdfBytes) async {
  final directory = await getDownloadsDirectory();
  if (directory == null) {
    throw Exception("Could not get the downloads directory");
  }

  final filePath = '${directory.path}/sales_invoice.pdf';
  final file = File(filePath);

  await file.writeAsBytes(pdfBytes);

  return filePath;
}

void printSalesPDF(Map<String, dynamic> record) async {
  try {
    final pdfBytes = await generateSalesPDF(record);
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes);
  } finally {}
}
