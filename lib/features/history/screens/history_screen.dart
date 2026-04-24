import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scientific_pro_calculator/models/calculation_history.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';
import 'package:scientific_pro_calculator/services/export_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CalculationHistory> historyList = [];
  List<CalculationHistory> filteredList = [];
  bool showSearchBar = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final items = await HistoryService.instance.getAllHistory();
      if (mounted) {
        setState(() {
          historyList = items;
          filteredList = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load history: $e');
      }
    }
  }

  void _filterHistory(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredList = historyList;
      } else {
        final lower = query.toLowerCase();
        filteredList = historyList.where((item) {
          return item.expression.toLowerCase().contains(lower) ||
              item.result.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      showSearchBar = !showSearchBar;
      if (!showSearchBar) {
        searchController.clear();
        searchQuery = '';
        filteredList = historyList;
      }
    });
  }

  void _recallCalculation(CalculationHistory item) {
    Navigator.pop(context, item);
  }

  Future<void> _showHistoryContextMenu(
      BuildContext context, CalculationHistory item) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A2436),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.expression,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'Roboto Mono',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '= ${item.result}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4C6EF5),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF334155), height: 24),
              ListTile(
                leading: const Icon(Icons.content_copy_rounded,
                    color: Color(0xFF94A3B8)),
                title: const Text('Copy expression',
                    style: TextStyle(color: Color(0xFFE2E8F0))),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: item.expression));
                  _showSnackBar('Expression copied to clipboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.numbers_rounded,
                    color: Color(0xFF94A3B8)),
                title: const Text('Copy result',
                    style: TextStyle(color: Color(0xFFE2E8F0))),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: item.result));
                  _showSnackBar('Result copied to clipboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF94A3B8)),
                title: const Text('View details',
                    style: TextStyle(color: Color(0xFFE2E8F0))),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDetailsDialog(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444)),
                title: const Text('Delete entry',
                    style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _deleteEntry(item);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(CalculationHistory item) async {
    try {
      await HistoryService.instance.deleteHistory(item.id);
      setState(() {
        historyList.removeWhere((e) => e.id == item.id);
        filteredList.removeWhere((e) => e.id == item.id);
      });
      _showSnackBar('Entry deleted');
    } catch (e) {
      _showSnackBar('Failed to delete entry: $e');
    }
  }

  void _showDetailsDialog(CalculationHistory item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Calculation Details',
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Expression', item.expression,
                  mono: true, color: const Color(0xFF94A3B8)),
              const SizedBox(height: 10),
              _detailRow('Result', item.result,
                  color: const Color(0xFF4C6EF5), bold: true),
              const SizedBox(height: 10),
              _detailRow('Timestamp', _formatTimestamp(item.timestamp)),
              const SizedBox(height: 10),
              _detailRow('Display Format', item.displayFormat),
              const SizedBox(height: 10),
              _detailRow('Angle Mode', item.angleMode),
              const SizedBox(height: 10),
              _detailRow('Input Mode', item.inputMode),
              if (item.isComplex) ...[
                const SizedBox(height: 10),
                _detailRow('Type', 'Complex Number'),
                if (item.magnitude != null) ...[
                  const SizedBox(height: 10),
                  _detailRow('Magnitude', item.magnitude!),
                ],
                if (item.phase != null) ...[
                  const SizedBox(height: 10),
                  _detailRow('Phase', item.phase!),
                ],
                if (item.polarForm != null) ...[
                  const SizedBox(height: 10),
                  _detailRow('Polar Form', item.polarForm!),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: Color(0xFF4C6EF5))),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool mono = false, Color? color, bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color ?? const Color(0xFFE2E8F0),
            fontFamily: mono ? 'Roboto Mono' : 'Roboto',
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _showClearConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All History?',
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This will permanently delete all calculation history. This action cannot be undone.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete All',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HistoryService.instance.clearHistory();
        setState(() {
          historyList.clear();
          filteredList.clear();
        });
        _showSnackBar('History cleared');
      } catch (e) {
        _showSnackBar('Failed to clear history: $e');
      }
    }
  }

  void _showExportMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A2436),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Export History',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(color: Color(0xFF334155), height: 24),
              ListTile(
                leading: const Icon(Icons.data_object_rounded,
                    color: Color(0xFF4C6EF5)),
                title: const Text('Export as JSON',
                    style: TextStyle(color: Color(0xFFE2E8F0))),
                subtitle: const Text('Structured data format',
                    style:
                        TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportJson();
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded,
                    color: Color(0xFF14B8A6)),
                title: const Text('Export as CSV',
                    style: TextStyle(color: Color(0xFFE2E8F0))),
                subtitle: const Text('Spreadsheet compatible',
                    style:
                        TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportCsv();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFF59E0B)),
                title: const Text('Export as PDF',
                    style: TextStyle(color: Color(0xFFE2E8F0))),
                subtitle: const Text('Formatted document',
                    style:
                        TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportPdf();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportJson() async {
    if (historyList.isEmpty) {
      _showSnackBar('No history to export');
      return;
    }
    try {
      final filePath =
          await ExportService.instance.exportHistoryAsJson(historyList);
      _showExportSuccessSnackBar(filePath);
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  Future<void> _exportCsv() async {
    if (historyList.isEmpty) {
      _showSnackBar('No history to export');
      return;
    }
    try {
      final filePath =
          await ExportService.instance.exportHistoryAsCsv(historyList);
      _showExportSuccessSnackBar(filePath);
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  Future<void> _exportPdf() async {
    if (historyList.isEmpty) {
      _showSnackBar('No history to export');
      return;
    }
    try {
      final filePath =
          await ExportService.instance.exportHistoryAsPdf(historyList);
      _showExportSuccessSnackBar(filePath);
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  void _showExportSuccessSnackBar(String filePath) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported to: $filePath',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF293548),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Share',
          textColor: const Color(0xFF4C6EF5),
          onPressed: () => ExportService.instance.shareFile(filePath),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor:
            isError ? const Color(0xFF9B1C1C) : const Color(0xFF293548),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String _formatTimestampFull(DateTime timestamp) {
    final pad = (int n) => n.toString().padLeft(2, '0');
    return '${timestamp.year}-${pad(timestamp.month)}-${pad(timestamp.day)} '
        '${pad(timestamp.hour)}:${pad(timestamp.minute)}:${pad(timestamp.second)}';
  }

  Widget _buildHistoryItem(CalculationHistory item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFF1A2436),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _recallCalculation(item),
        onLongPress: () => _showHistoryContextMenu(context, item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.expression,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'Roboto Mono',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTimestamp(item.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '= ${item.result}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4C6EF5),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto Mono',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.isComplex && item.polarForm != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.polarForm!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Roboto Mono',
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildTag(item.angleMode),
                  const SizedBox(width: 6),
                  _buildTag(item.inputMode),
                  const SizedBox(width: 6),
                  _buildTag(item.displayFormat),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF293548),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: const Color(0xFF334155),
          ),
          const SizedBox(height: 16),
          const Text(
            'No calculation history',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your calculations will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Color(0xFF334155),
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2436),
        title: showSearchBar
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search history...',
                  hintStyle: TextStyle(color: Color(0xFF64748B)),
                  border: InputBorder.none,
                ),
                onChanged: _filterHistory,
              )
            : const Text(
                'History',
                style: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF94A3B8)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showSearchBar ? Icons.close_rounded : Icons.search_rounded,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: _toggleSearch,
          ),
          if (!showSearchBar) ...[
            IconButton(
              icon: const Icon(Icons.file_download_rounded,
                  color: Color(0xFF94A3B8)),
              tooltip: 'Export',
              onPressed: historyList.isEmpty ? null : _showExportMenu,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Color(0xFF94A3B8)),
              tooltip: 'Clear All',
              onPressed: historyList.isEmpty ? null : _showClearConfirmation,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4C6EF5)),
            )
          : filteredList.isEmpty
              ? (searchQuery.isNotEmpty
                  ? _buildSearchEmptyState()
                  : _buildEmptyState())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${filteredList.length} calculation${filteredList.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _loadHistory,
                            child: const Text(
                              'Refresh',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF4C6EF5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(
                              filteredList[index], theme);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
