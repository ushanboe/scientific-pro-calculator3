import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:scientific_pro_calculator/models/calculation_history.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat _filenameDateFormat = DateFormat('yyyyMMdd_HHmmss');

  // ─── CSV helper ──────────────────────────────────────────────────────────────

  String _rowToCsv(List<dynamic> row) {
    return row.map((cell) {
      final s = cell?.toString() ?? '';
      if (s.contains(',') || s.contains('"') || s.contains('\n')) {
        return '"${s.replaceAll('"', '""')}"';
      }
      return s;
    }).join(',');
  }

  String _toCsvString(List<List<dynamic>> rows) {
    return rows.map(_rowToCsv).join('\n');
  }

  // ─── Clipboard ──────────────────────────────────────────────────────────────

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> copyResultWithFormat(
    String result, {
    String format = 'decimal',
  }) async {
    String textToCopy;
    switch (format) {
      case 'scientific':
        final value = double.tryParse(result);
        if (value != null) {
          textToCopy = value.toStringAsExponential(6);
        } else {
          textToCopy = result;
        }
        break;
      case 'fraction':
        final value = double.tryParse(result);
        if (value != null && value == value.roundToDouble()) {
          textToCopy = result;
        } else if (value != null) {
          textToCopy = _toApproximateFraction(value) ?? result;
        } else {
          textToCopy = result;
        }
        break;
      default:
        textToCopy = result;
    }
    await Clipboard.setData(ClipboardData(text: textToCopy));
  }

  String? _toApproximateFraction(double value, {int maxDenominator = 1000}) {
    if (value == 0) return '0';
    final negative = value < 0;
    final absValue = negative ? -value : value;
    int bestNumerator = 1;
    int bestDenominator = 1;
    double bestError = (absValue - 1.0).abs();
    for (int d = 1; d <= maxDenominator; d++) {
      final n = (absValue * d).round();
      final error = (absValue - n / d).abs();
      if (error < bestError) {
        bestError = error;
        bestNumerator = n;
        bestDenominator = d;
      }
      if (error < 1e-9) break;
    }
    if (bestError > 1e-4) return null;
    final sign = negative ? '-' : '';
    if (bestDenominator == 1) return '$sign$bestNumerator';
    return '$sign$bestNumerator/$bestDenominator';
  }

  String _truncateString(String s, int maxLength) {
    if (s.length <= maxLength) return s;
    return '${s.substring(0, maxLength - 3)}...';
  }

  // ─── Share ───────────────────────────────────────────────────────────────────

  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      print('ExportService.shareFile error: $e');
    }
  }

  Future<void> shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      print('ExportService.shareText error: $e');
    }
  }

  // ─── Graph Image Export ───────────────────────────────────────────────────────

  /// Save PNG bytes (captured from RepaintBoundary) to the documents directory.
  /// Returns the file path.
  Future<String> graphToImage(Uint8List pngBytes) async {
    final timestamp = _filenameDateFormat.format(DateTime.now());
    final filename = 'graph_$timestamp.png';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  // ─── JSON Export ─────────────────────────────────────────────────────────────

  Future<String> exportHistoryAsJson(List<CalculationHistory> history) async {
    final timestamp = _filenameDateFormat.format(DateTime.now());
    final filename = 'calc_history_$timestamp.json';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    final jsonData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'count': history.length,
      'calculations': history.map((h) => h.toJson()).toList(),
    };

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonData),
      flush: true,
    );

    return file.path;
  }

  Future<String> exportAllHistoryAsJson() async {
    final history = await HistoryService.instance.getAllHistory();
    return exportHistoryAsJson(history);
  }

  // ─── CSV Export ──────────────────────────────────────────────────────────────

  Future<String> exportHistoryAsCsv(List<CalculationHistory> history) async {
    final timestamp = _filenameDateFormat.format(DateTime.now());
    final filename = 'calc_history_$timestamp.csv';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    final rows = <List<dynamic>>[
      [
        'ID',
        'Expression',
        'Result',
        'Result Type',
        'Is Complex',
        'Magnitude',
        'Phase',
        'Polar Form',
        'Display Format',
        'Angle Mode',
        'Input Mode',
        'Timestamp',
      ],
      ...history.map((h) => [
            h.id,
            h.expression,
            h.result,
            h.resultType,
            h.isComplex ? 'true' : 'false',
            h.magnitude ?? '',
            h.phase ?? '',
            h.polarForm ?? '',
            h.displayFormat,
            h.angleMode,
            h.inputMode,
            _dateFormat.format(h.timestamp),
          ]),
    ];

    final csvString = _toCsvString(rows);
    await file.writeAsString(csvString, flush: true);

    return file.path;
  }

  Future<String> exportAllHistoryAsCsv() async {
    final history = await HistoryService.instance.getAllHistory();
    return exportHistoryAsCsv(history);
  }

  // ─── PDF Export ──────────────────────────────────────────────────────────────

  Future<String> exportHistoryAsPdf(List<CalculationHistory> history) async {
    final timestamp = _filenameDateFormat.format(DateTime.now());
    final filename = 'calc_history_$timestamp.pdf';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#4C6EF5');
    final darkBg = PdfColor.fromHex('#1E293B');
    final textColor = PdfColor.fromHex('#E2E8F0');
    final secondaryText = PdfColor.fromHex('#94A3B8');
    final borderColor = PdfColor.fromHex('#334155');

    const entriesPerPage = 20;
    final pages = <List<CalculationHistory>>[];
    for (int i = 0; i < history.length; i += entriesPerPage) {
      pages.add(
        history.sublist(
          i,
          i + entriesPerPage > history.length ? history.length : i + entriesPerPage,
        ),
      );
    }

    if (pages.isEmpty) pages.add([]);

    for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      final pageHistory = pages[pageIndex];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: darkBg,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Scientific Pro Calculator',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Calculation History Export',
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('#94A3B8'),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            _dateFormat.format(DateTime.now()),
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('#94A3B8'),
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${history.length} calculations',
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('#94A3B8'),
                              fontSize: 10,
                            ),
                          ),
                          if (pages.length > 1) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Page ${pageIndex + 1} of ${pages.length}',
                              style: pw.TextStyle(
                                color: PdfColor.fromHex('#94A3B8'),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(6),
                      topRight: pw.Radius.circular(6),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'Expression',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'Result',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Mode',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Timestamp',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (pageHistory.isEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(24),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderColor),
                      borderRadius: const pw.BorderRadius.only(
                        bottomLeft: pw.Radius.circular(6),
                        bottomRight: pw.Radius.circular(6),
                      ),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'No calculation history',
                        style: pw.TextStyle(color: secondaryText, fontSize: 12),
                      ),
                    ),
                  )
                else
                  ...pageHistory.asMap().entries.map((entry) {
                    final index = entry.key;
                    final h = entry.value;
                    final isEven = index % 2 == 0;
                    final isLast = index == pageHistory.length - 1;
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: isEven
                            ? PdfColor.fromHex('#0F172A')
                            : PdfColor.fromHex('#1A2436'),
                        border: pw.Border(
                          left: pw.BorderSide(color: borderColor),
                          right: pw.BorderSide(color: borderColor),
                          bottom: pw.BorderSide(color: borderColor),
                        ),
                        borderRadius: isLast
                            ? const pw.BorderRadius.only(
                                bottomLeft: pw.Radius.circular(6),
                                bottomRight: pw.Radius.circular(6),
                              )
                            : null,
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              _truncateString(h.expression, 30),
                              style: pw.TextStyle(color: textColor, fontSize: 10),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              _truncateString(
                                  h.isComplex ? (h.polarForm ?? h.result) : h.result,
                                  30),
                              style: pw.TextStyle(
                                color: h.isComplex
                                    ? PdfColor.fromHex('#14B8A6')
                                    : textColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              '${h.angleMode} / ${h.inputMode}',
                              style: pw.TextStyle(color: secondaryText, fontSize: 9),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              DateFormat('MM/dd HH:mm').format(h.timestamp),
                              style: pw.TextStyle(color: secondaryText, fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                pw.Spacer(),
                pw.Divider(color: borderColor),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated by Scientific Pro Calculator',
                  style: pw.TextStyle(color: secondaryText, fontSize: 9),
                ),
              ],
            );
          },
        ),
      );
    }

    final bytes = await pdf.save();
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String> exportAllHistoryAsPdf() async {
    final history = await HistoryService.instance.getAllHistory();
    return exportHistoryAsPdf(history);
  }

  // ─── Dataset CSV Export ───────────────────────────────────────────────────────

  Future<String> exportDatasetAsCsv(
    List<double> data,
    String name,
  ) async {
    final timestamp = _filenameDateFormat.format(DateTime.now());
    final filename = '${name}_$timestamp.csv';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    final rows = <List<dynamic>>[
      ['Index', 'Value'],
      ...data.asMap().entries.map((e) => [e.key + 1, e.value]),
    ];

    final csvString = _toCsvString(rows);
    await file.writeAsString(csvString, flush: true);

    return file.path;
  }

  // ─── Dataset PDF Export ───────────────────────────────────────────────────────

  Future<String> exportDatasetAsPdf(
    List<double> data,
    String name,
    Map<String, dynamic>? stats,
  ) async {
    final timestamp = _filenameDateFormat.format(DateTime.now());
    final filename = '${name}_$timestamp.pdf';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('#4C6EF5');
    final secondaryText = PdfColor.fromHex('#94A3B8');
    final textColor = PdfColor.fromHex('#E2E8F0');
    final borderColor = PdfColor.fromHex('#334155');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Statistics Dataset: $name',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated: ${_dateFormat.format(DateTime.now())}',
                style: pw.TextStyle(color: secondaryText, fontSize: 10),
              ),
              pw.SizedBox(height: 16),
              if (stats != null) ...[
                pw.Text(
                  'Summary Statistics',
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...stats.entries.take(10).map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              e.key,
                              style: pw.TextStyle(color: secondaryText, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            e.value?.toString() ?? '',
                            style: pw.TextStyle(color: textColor, fontSize: 10),
                          ),
                        ],
                      ),
                    )),
                pw.SizedBox(height: 16),
              ],
              pw.Text(
                'Data Points (${data.length} values)',
                style: pw.TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(6),
                    topRight: pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Index',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Value',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...data.asMap().entries.take(50).map((entry) {
                final isEven = entry.key % 2 == 0;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: isEven
                        ? PdfColor.fromHex('#0F172A')
                        : PdfColor.fromHex('#1A2436'),
                    border: pw.Border(
                      left: pw.BorderSide(color: borderColor),
                      right: pw.BorderSide(color: borderColor),
                      bottom: pw.BorderSide(color: borderColor),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${entry.key + 1}',
                          style: pw.TextStyle(color: secondaryText, fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          entry.value.toString(),
                          style: pw.TextStyle(color: textColor, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (data.length > 50)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '... and ${data.length - 50} more values',
                    style: pw.TextStyle(color: secondaryText, fontSize: 10),
                  ),
                ),
              pw.Spacer(),
              pw.Divider(color: borderColor),
              pw.Text(
                'Generated by Scientific Pro Calculator',
                style: pw.TextStyle(color: secondaryText, fontSize: 9),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }
}
