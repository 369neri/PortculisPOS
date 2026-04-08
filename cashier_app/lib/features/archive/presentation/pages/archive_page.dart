import 'dart:io';

import 'package:cashier_app/core/extensions/format_helpers.dart';
import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/archive/domain/entities/archive_kind.dart';
import 'package:cashier_app/features/archive/domain/entities/archived_file.dart';
import 'package:cashier_app/features/archive/presentation/state/archive_cubit.dart';
import 'package:cashier_app/features/archive/presentation/state/archive_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ArchiveCubit>(
      create: (_) => sl<ArchiveCubit>()..load(),
      child: const _ArchiveView(),
    );
  }
}

class _ArchiveView extends StatefulWidget {
  const _ArchiveView();

  @override
  State<_ArchiveView> createState() => _ArchiveViewState();
}

class _ArchiveViewState extends State<_ArchiveView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ArchiveKind get _currentKind =>
      _tabController.index == 0 ? ArchiveKind.receipt : ArchiveKind.report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Receipts'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Reports'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all',
            onPressed: () => _confirmClearAll(context),
          ),
        ],
      ),
      body: BlocBuilder<ArchiveCubit, ArchiveState>(
        builder: (context, state) {
          return switch (state) {
            ArchiveInitial() => const Center(
                child: CircularProgressIndicator(),
              ),
            ArchiveError(:final message) => Center(
                child: Text('Error: $message'),
              ),
            ArchiveLoaded(:final receipts, :final reports) => TabBarView(
                controller: _tabController,
                children: [
                  _FileList(files: receipts, emptyLabel: 'receipts'),
                  _FileList(files: reports, emptyLabel: 'reports'),
                ],
              ),
          };
        },
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text(
          'Delete all files in this tab? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ArchiveCubit>().clearAll(_currentKind);
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File list
// ---------------------------------------------------------------------------

class _FileList extends StatelessWidget {
  const _FileList({required this.files, required this.emptyLabel});

  final List<ArchivedFile> files;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Center(child: Text('No saved $emptyLabel yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: files.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final file = files[index];
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(
            file.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(_formatDate(file.savedAt)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share',
                onPressed: () => _share(file),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, file),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _share(ArchivedFile file) async {
    final bytes = await File(file.path).readAsBytes();
    await Printing.sharePdf(bytes: bytes, filename: file.displayName);
  }

  void _confirmDelete(BuildContext context, ArchivedFile file) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete "${file.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ArchiveCubit>().delete(file);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) => Fmt.dateTime(dt);
}
