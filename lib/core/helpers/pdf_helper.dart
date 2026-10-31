import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class PdfHelper {
  static Future<void> printWidget(GlobalKey boundaryKey, String fileName) async {
    final pdfBytes = await _widgetToPdf(boundaryKey);
    await Printing.layoutPdf(name: fileName, onLayout: (format) async => pdfBytes);
  }

  static Future<void> downloadWidget(GlobalKey boundaryKey, String fileName) async {
    final pdfBytes = await _widgetToPdf(boundaryKey);
    await Printing.sharePdf(bytes: pdfBytes, filename: '$fileName.pdf');
  }

  static Future<Uint8List> _widgetToPdf(GlobalKey boundaryKey) async {
    final pngBytes = await _widgetToPng(boundaryKey);
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build:
            (context) => pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain, alignment: pw.Alignment.topCenter),
      ),
    );
    return document.save();
  }

  static Future<Uint8List> _widgetToPng(GlobalKey boundaryKey) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return Uint8List(0);
    final image = await boundary.toImage(pixelRatio: AppSizes.pdfPixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List() ?? Uint8List(0);
  }
}
