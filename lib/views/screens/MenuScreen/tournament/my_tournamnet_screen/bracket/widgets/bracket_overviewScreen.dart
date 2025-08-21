import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../bracket_view_model.dart';

class BracketOverviewScreen extends StatefulWidget {
  const BracketOverviewScreen({Key? key}) : super(key: key);

  @override
  State<BracketOverviewScreen> createState() => _BracketOverviewScreenState();
}

class _BracketOverviewScreenState extends State<BracketOverviewScreen> {
  final GlobalKey _captureKey = GlobalKey();
  OverlayEntry? _exportOverlayEntry;
  bool _isExporting = false;

  static const double _cardWidth = 220;
  static const double _cardHeight = 90;
  static const double _hGap = 60;
  static const double _vGap = 24;
  String _category = 'Category';
  Future<void> _exportAsImage() async {
    if (_isExporting) return;
    _isExporting = true;
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }
    try {
      final pngBytes = await _capturePngViaOverlay();
      if (pngBytes == null) throw Exception('Failed to capture image');

      final Directory dir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${dir.path}/bracket_overview_${DateTime.now().millisecondsSinceEpoch}.png';
      final File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bracket image saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on MissingPluginException catch (_) {
      await _exportAsPdfDirect();
    } catch (_) {
      await _exportAsPdfDirect();
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _isExporting = false;
    }
  }

  Future<void> _exportAsPdf() async {
    if (_isExporting && mounted) {
    } else {
      _isExporting = true;
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }
    }

    try {
      final pngBytes = await _capturePngViaOverlay();
      if (pngBytes == null) throw Exception('Failed to capture image for PDF');

      final doc = pw.Document();
      final imageProvider = pw.MemoryImage(pngBytes);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Stack(children: [
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(12),
                child: pw.FittedBox(
                  child: pw.Image(imageProvider),
                  fit: pw.BoxFit.contain,
                ),
              ),
            ]);
          },
        ),
      );

      final filename =
          '${_category}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Printing.sharePdf(bytes: await doc.save(), filename: filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ready for download/share.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _isExporting = false;
    }
  }

  Future<void> _exportAsPdfDirect() async {
    if (_isExporting) return;
    _isExporting = true;
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final vm = Provider.of<BracketViewModel>(context, listen: false);
      final category =
          vm.selectedGroup.isNotEmpty ? vm.selectedGroup : 'Category';
      _category = category.isEmpty ? 'Category' : category;
      final totalRounds = vm.getTotalRounds();
      final firstRoundMatches = vm.getMatchesForRound(1);
      final int baseCount =
          firstRoundMatches.isEmpty ? 0 : firstRoundMatches.length;

      final double canvasWidth =
          totalRounds * _cardWidth + (totalRounds - 1) * _hGap + 80;
      final double canvasHeight = baseCount == 0
          ? 400
          : (baseCount * _cardHeight) + ((baseCount - 1) * _vGap) * 2;

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            final pageW = PdfPageFormat.a4.landscape.availableWidth;
            final pageH = PdfPageFormat.a4.landscape.availableHeight;
            final scale = math
                .min((pageW - 40) / canvasWidth, (pageH - 40) / canvasHeight)
                .clamp(0.3, 1.0);

            final List<_PdfNode> nodes = [];
            final List<_PdfEdge> edges = [];
            final Map<String, PdfPoint> leftCenters = {};
            final Map<String, PdfPoint> rightCenters = {};

            for (int round = 1; round <= totalRounds; round++) {
              final matches = vm.getMatchesForRound(round);
              final int matchesInRound = matches.length;
              final double x = 40 + (round - 1) * (_cardWidth + _hGap);
              final double separation = (round == 1)
                  ? (_cardHeight + _vGap)
                  : (_cardHeight + _vGap) * (1 << (round - 1));
              for (int j = 0; j < matchesInRound; j++) {
                final match = matches[j];
                final int idx1 = j + 1;
                final double y = (idx1 - 1) * separation +
                    (separation - _cardHeight) / 2 +
                    40;
                final rect = PdfRect(x, y, _cardWidth, _cardHeight);
                final id = match['match_id'].toString();
                nodes.add(_PdfNode(id: id, rect: rect, match: match));
                leftCenters[id] =
                    PdfPoint(rect.left, rect.top + rect.height / 2);
                rightCenters[id] = PdfPoint(
                    rect.left + rect.width, rect.top + rect.height / 2);
              }
            }

            for (int round = 1; round < totalRounds; round++) {
              final matches = vm.getMatchesForRound(round);
              for (int j = 0; j < matches.length; j++) {
                final String currentId = matches[j]['match_id'].toString();
                final int currentNumber = _extractMatchNumber(currentId);
                final int nextRound = round + 1;
                final int nextMatchNumber = (currentNumber + 1) ~/ 2;
                final String nextId = 'match_${nextRound}_${nextMatchNumber}';
                final src = rightCenters[currentId];
                final dst = leftCenters[nextId];
                if (src != null && dst != null)
                  edges.add(_PdfEdge(from: src, to: dst));
              }
            }

            return pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Center(
                child: pw.Transform.scale(
                  scale: scale.toDouble(),
                  child: pw.Container(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: pw.Stack(
                      children: [
                        // Edges as L-shaped lines (three segments)
                        for (final e in edges) ...[
                          // horizontal from src to midX
                          pw.Positioned(
                            left: e.from.x,
                            top: e.from.y - 0.5,
                            child: pw.Container(
                              width: ((e.from.x + e.to.x) / 2) - e.from.x,
                              height: 1,
                              color: PdfColors.lightBlue,
                            ),
                          ),
                          // vertical at midX
                          pw.Positioned(
                            left: (e.from.x + e.to.x) / 2 - 0.5,
                            top: math.min(e.from.y, e.to.y),
                            child: pw.Container(
                              width: 1,
                              height: (e.from.y - e.to.y).abs(),
                              color: PdfColors.lightBlue,
                            ),
                          ),
                          // horizontal from midX to dst
                          pw.Positioned(
                            left: (e.from.x + e.to.x) / 2,
                            top: e.to.y - 0.5,
                            child: pw.Container(
                              width: e.to.x - (e.from.x + e.to.x) / 2,
                              height: 1,
                              color: PdfColors.lightBlue,
                            ),
                          ),
                        ],
                        // Round headers
                        for (int round = 1; round <= totalRounds; round++)
                          pw.Positioned(
                            left: 40 + (round - 1) * (_cardWidth + _hGap),
                            top: 0,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFF264653),
                                borderRadius: pw.BorderRadius.circular(20),
                              ),
                              child: pw.Text('Round $round',
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold,
                                  )),
                            ),
                          ),
                        // Match cards
                        for (final n in nodes)
                          pw.Positioned(
                            left: n.rect.left,
                            top: n.rect.top,
                            child: _pdfMatchCard(n.match),
                          ),
                        // Category chip
                        pw.Positioned(
                          right: 8,
                          bottom: 8,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(20),
                              border: pw.Border.all(color: PdfColors.lightBlue),
                            ),
                            child: pw.Text(category,
                                style: pw.TextStyle(
                                    color: PdfColor.fromInt(0xFF1565C0),
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      final filename =
          '${_category}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Printing.sharePdf(bytes: await doc.save(), filename: filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('PDF ready for download/share.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to export PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _isExporting = false;
    }
  }

  Future<void> _exportAsPdfFullSize() async {
    if (_isExporting) return;
    _isExporting = true;
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final vm = Provider.of<BracketViewModel>(context, listen: false);
      final category =
          vm.selectedGroup.isNotEmpty ? vm.selectedGroup : 'Category';
      final totalRounds = vm.getTotalRounds();
      final firstRoundMatches = vm.getMatchesForRound(1);
      final int baseCount =
          firstRoundMatches.isEmpty ? 0 : firstRoundMatches.length;

      final double canvasWidth =
          totalRounds * _cardWidth + (totalRounds - 1) * _hGap + 80;
      final double canvasHeight = baseCount == 0
          ? 400
          : (baseCount * _cardHeight) + ((baseCount - 1) * _vGap) * 2;

      final double margin = 20;
      final doc = pw.Document();

      final pageFormat =
          PdfPageFormat(canvasWidth + margin * 2, canvasHeight + margin * 2);

      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            final List<_PdfNode> nodes = [];
            final List<_PdfEdge> edges = [];
            final Map<String, PdfPoint> leftCenters = {};
            final Map<String, PdfPoint> rightCenters = {};

            for (int round = 1; round <= totalRounds; round++) {
              final matches = vm.getMatchesForRound(round);
              final int matchesInRound = matches.length;
              final double x = margin + 20 + (round - 1) * (_cardWidth + _hGap);
              final double separation = (round == 1)
                  ? (_cardHeight + _vGap)
                  : (_cardHeight + _vGap) * (1 << (round - 1));
              for (int j = 0; j < matchesInRound; j++) {
                final match = matches[j];
                final int idx1 = j + 1;
                final double y = margin +
                    (idx1 - 1) * separation +
                    (separation - _cardHeight) / 2 +
                    40;
                final rect = PdfRect(x, y, _cardWidth, _cardHeight);
                final id = match['match_id'].toString();
                nodes.add(_PdfNode(id: id, rect: rect, match: match));
                leftCenters[id] =
                    PdfPoint(rect.left, rect.top + rect.height / 2);
                rightCenters[id] = PdfPoint(
                    rect.left + rect.width, rect.top + rect.height / 2);
              }
            }

            for (int round = 1; round < totalRounds; round++) {
              final matches = vm.getMatchesForRound(round);
              for (int j = 0; j < matches.length; j++) {
                final String currentId = matches[j]['match_id'].toString();
                final int currentNumber = _extractMatchNumber(currentId);
                final int nextRound = round + 1;
                final int nextMatchNumber = (currentNumber + 1) ~/ 2;
                final String nextId = 'match_${nextRound}_${nextMatchNumber}';
                final src = rightCenters[currentId];
                final dst = leftCenters[nextId];
                if (src != null && dst != null)
                  edges.add(_PdfEdge(from: src, to: dst));
              }
            }

            return pw.Stack(
              children: [
                // Edges
                for (final e in edges) ...[
                  pw.Positioned(
                    left: e.from.x,
                    top: e.from.y - 0.5,
                    child: pw.Container(
                      width: ((e.from.x + e.to.x) / 2) - e.from.x,
                      height: 1,
                      color: PdfColors.lightBlue,
                    ),
                  ),
                  pw.Positioned(
                    left: (e.from.x + e.to.x) / 2 - 0.5,
                    top: math.min(e.from.y, e.to.y),
                    child: pw.Container(
                      width: 1,
                      height: (e.from.y - e.to.y).abs(),
                      color: PdfColors.lightBlue,
                    ),
                  ),
                  pw.Positioned(
                    left: (e.from.x + e.to.x) / 2,
                    top: e.to.y - 0.5,
                    child: pw.Container(
                      width: e.to.x - (e.from.x + e.to.x) / 2,
                      height: 1,
                      color: PdfColors.lightBlue,
                    ),
                  ),
                ],
                // Headers
                for (int round = 1; round <= totalRounds; round++)
                  pw.Positioned(
                    left: margin + 20 + (round - 1) * (_cardWidth + _hGap),
                    top: margin,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF264653),
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text('Round $round',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          )),
                    ),
                  ),
                // Cards
                for (final n in nodes)
                  pw.Positioned(
                    left: n.rect.left,
                    top: n.rect.top,
                    child: _pdfMatchCard(n.match),
                  ),
                // Category chip
                pw.Positioned(
                  right: margin,
                  bottom: margin,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(color: PdfColors.lightBlue),
                    ),
                    child: pw.Text(category,
                        style: pw.TextStyle(
                            color: PdfColor.fromInt(0xFF1565C0),
                            fontWeight: pw.FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final filename =
          '${_category}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Printing.sharePdf(bytes: await doc.save(), filename: filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Full-size PDF ready.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to export full-size PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _isExporting = false;
    }
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Full-size PDF (best detail)'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPdfFullSize();
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('A4 Fit PDF (for printing)'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPdfDirect();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _capturePngViaOverlay() async {
    final vm = Provider.of<BracketViewModel>(context, listen: false);
    final category =
        vm.selectedGroup.isNotEmpty ? vm.selectedGroup : 'Category';

    _exportOverlayEntry = OverlayEntry(
      builder: (_) {
        return IgnorePointer(
          child: Opacity(
            opacity: 0.01,
            child: Material(
              type: MaterialType.transparency,
              child: Align(
                alignment: Alignment.topLeft,
                child: _buildCanvas(vm, category, wrapWithBoundary: true),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true)?.insert(_exportOverlayEntry!);
    await Future.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;

    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      await _waitForBoundaryPaint(boundary);

      final Size logical = boundary.size;
      double pixelRatio = 3.0;
      final double estPixels =
          logical.width * logical.height * pixelRatio * pixelRatio;
      const double maxPixels = 20000000; // ~20MP
      if (estPixels > maxPixels) {
        pixelRatio = math.sqrt(maxPixels / (logical.width * logical.height));
        if (pixelRatio < 1.5) pixelRatio = 1.5;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } finally {
      _exportOverlayEntry?.remove();
      _exportOverlayEntry = null;
    }
  }

  Future<void> _waitForBoundaryPaint(RenderRepaintBoundary boundary) async {
    int attempts = 0;
    while (boundary.debugNeedsPaint && attempts < 10) {
      attempts++;
      await Future.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  pw.Widget _pdfMatchCard(Map<String, dynamic> match) {
    final team1 = match['team1'];
    final team2 = match['team2'];
    final winner = match['winner'];
    final status = match['status'];

    PdfColor border = PdfColors.grey300;
    PdfColor fill = PdfColors.white;

    if (status == 'completed') {
      fill = PdfColor.fromInt(0xE6EDEDED);
      border = PdfColors.green;
    } else if (status == 'ready') {
      fill = PdfColor.fromInt(0xE6E3F2FD);
      border = PdfColors.blue;
    }

    return pw.Container(
      width: _cardWidth,
      height: _cardHeight,
      decoration: pw.BoxDecoration(
        color: fill,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: border, width: 1),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          _pdfTeamLine(team1, isWinner: winner != null && winner == team1),
          pw.SizedBox(height: 6),
          pw.Container(height: 0.6, color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          _pdfTeamLine(team2, isWinner: winner != null && winner == team2),
        ],
      ),
    );
  }

  pw.Widget _pdfTeamLine(dynamic team, {required bool isWinner}) {
    final isDummy = team == 'BYE';
    final isEmpty = team == null || team.toString().trim().isEmpty;
    final text = isEmpty ? 'TBD' : (isDummy ? 'BYE' : team.toString());
    return pw.Row(
      children: [
        if (isWinner && !isEmpty && !isDummy)
          pw.Container(
            width: 10,
            height: 10,
            decoration: pw.BoxDecoration(
              color: PdfColors.green,
              shape: pw.BoxShape.circle,
            ),
          ),
        if (isWinner && !isEmpty && !isDummy) pw.SizedBox(width: 4),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isWinner ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isDummy ? PdfColors.grey700 : PdfColors.black,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BracketViewModel>(
      builder: (context, vm, _) {
        final category =
            vm.selectedGroup.isNotEmpty ? vm.selectedGroup : 'Category';
        _category = category.isEmpty ? 'Category' : category;
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                Text(
                  'Overview',
                  style: GoogleFonts.getFont('Poppins', color: Colors.black),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.getFont('Poppins',
                        color: const Color(0xFF1565C0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Icons.download, color: Colors.black),
                onPressed: _showDownloadOptions,
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildCanvas(vm, category),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCanvas(BracketViewModel vm, String category,
      {bool wrapWithBoundary = false}) {
    final totalRounds = vm.getTotalRounds();
    final firstRoundMatches = vm.getMatchesForRound(1);
    final int baseCount =
        firstRoundMatches.isEmpty ? 0 : firstRoundMatches.length;

    final double canvasWidth =
        totalRounds * _cardWidth + (totalRounds - 1) * _hGap + 80;
    final double canvasHeight = baseCount == 0
        ? 400
        : (baseCount * _cardHeight) + ((baseCount - 1) * _vGap) * 2;

    final Map<String, Offset> leftCenters = {};
    final Map<String, Offset> rightCenters = {};
    final List<_OverviewNode> nodes = [];
    final List<_OverviewEdge> edges = [];

    for (int round = 1; round <= totalRounds; round++) {
      final matches = vm.getMatchesForRound(round);
      final int matchesInRound = matches.length;
      final double x = 40 + (round - 1) * (_cardWidth + _hGap);
      final double separation = (round == 1)
          ? (_cardHeight + _vGap)
          : (_cardHeight + _vGap) * (1 << (round - 1));
      for (int j = 0; j < matchesInRound; j++) {
        final match = matches[j];
        final int index1Based = j + 1;
        final double y = (index1Based - 1) * separation +
            (separation - _cardHeight) / 2 +
            40;
        final Rect rect = Rect.fromLTWH(x, y, _cardWidth, _cardHeight);
        final String id = match['match_id'].toString();
        nodes.add(_OverviewNode(id: id, rect: rect, match: match));
        leftCenters[id] = Offset(rect.left, rect.center.dy);
        rightCenters[id] = Offset(rect.right, rect.center.dy);
      }
    }

    for (int round = 1; round < totalRounds; round++) {
      final matches = vm.getMatchesForRound(round);
      for (int j = 0; j < matches.length; j++) {
        final String currentId = matches[j]['match_id'].toString();
        final int currentNumber = _extractMatchNumber(currentId);
        final int nextRound = round + 1;
        final int nextMatchNumber = (currentNumber + 1) ~/ 2;
        final String nextId = 'match_${nextRound}_${nextMatchNumber}';
        final Offset? src = rightCenters[currentId];
        final Offset? dst = leftCenters[nextId];
        if (src != null && dst != null) {
          edges.add(_OverviewEdge(from: src, to: dst));
        }
      }
    }

    final Widget content = Container(
      color: Colors.grey[100],
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BracketConnectorPainter(edges: edges),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF90CAF9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                category,
                style: GoogleFonts.getFont('Poppins',
                    color: const Color(0xFF1565C0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          for (int round = 1; round <= totalRounds; round++)
            Positioned(
              left: 40 + (round - 1) * (_cardWidth + _hGap),
              top: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF264653),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Round $round',
                  style: GoogleFonts.getFont('Poppins',
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          for (final node in nodes)
            Positioned(
              left: node.rect.left,
              top: node.rect.top,
              width: node.rect.width,
              height: node.rect.height,
              child: _OverviewMatchCard(match: node.match),
            ),
        ],
      ),
    );

    if (wrapWithBoundary) {
      return OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: RepaintBoundary(key: _captureKey, child: content),
      );
    }
    return content;
  }

  int _extractMatchNumber(String matchId) {
    try {
      final parts = matchId.split('_');
      return int.tryParse(parts.last) ?? 1;
    } catch (_) {
      return 1;
    }
  }
}

class _PdfNode {
  final String id;
  final PdfRect rect;
  final Map<String, dynamic> match;
  _PdfNode({required this.id, required this.rect, required this.match});
}

class _PdfEdge {
  final PdfPoint from;
  final PdfPoint to;
  _PdfEdge({required this.from, required this.to});
}

class _OverviewNode {
  final String id;
  final Rect rect;
  final Map<String, dynamic> match;

  _OverviewNode({required this.id, required this.rect, required this.match});
}

class _OverviewEdge {
  final Offset from;
  final Offset to;
  _OverviewEdge({required this.from, required this.to});
}

class _BracketConnectorPainter extends CustomPainter {
  final List<_OverviewEdge> edges;
  _BracketConnectorPainter({required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF90CAF9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final e in edges) {
      final double midX = (e.from.dx + e.to.dx) / 2;
      final path = Path()
        ..moveTo(e.from.dx, e.from.dy)
        ..lineTo(midX, e.from.dy)
        ..lineTo(midX, e.to.dy)
        ..lineTo(e.to.dx, e.to.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BracketConnectorPainter oldDelegate) {
    return oldDelegate.edges != edges;
  }
}

class _OverviewMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _OverviewMatchCard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final team1 = match['team1'];
    final team2 = match['team2'];
    final winner = match['winner'];
    final status = match['status'];

    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    double borderWidth = 1;

    if (status == 'completed') {
      cardColor = Colors.green[50]!;
      borderColor = Colors.green[700]!;
      borderWidth = 1.5;
    } else if (status == 'ready') {
      cardColor = Colors.blue[50]!;
      borderColor = Colors.blue[700]!;
      borderWidth = 1.5;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _teamLine(team1, isWinner: winner != null && winner == team1),
          const Divider(height: 10),
          _teamLine(team2, isWinner: winner != null && winner == team2),
        ],
      ),
    );
  }

  Widget _teamLine(dynamic team, {required bool isWinner}) {
    final isDummy = team == 'BYE';
    final isEmpty = team == null || team.toString().trim().isEmpty;
    return Row(
      children: [
        if (isWinner && !isEmpty && !isDummy)
          const Icon(Icons.check_circle, color: Colors.green, size: 14),
        if (isWinner && !isEmpty && !isDummy) const SizedBox(width: 4),
        Expanded(
          child: Text(
            isEmpty ? 'TBD' : (isDummy ? 'BYE' : team.toString()),
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 12,
              fontWeight: isWinner ? FontWeight.w600 : FontWeight.w400,
              color: isDummy
                  ? Colors.grey[700]
                  : (isEmpty ? Colors.grey[600] : Colors.black),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
