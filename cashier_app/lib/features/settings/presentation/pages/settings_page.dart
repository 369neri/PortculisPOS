import 'dart:io';

import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:cashier_app/features/sync/domain/services/backup_service.dart';
import 'package:cashier_app/features/sync/presentation/state/sync_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _taxRateCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _footerCtrl = TextEditingController();
  String _themeMode = 'system';
  bool _autoBackup = false;
  String? _logoPath;
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<SettingsCubit>().state;
    if (state is SettingsReady) {
      _populate(state.settings);
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _taxRateCtrl.dispose();
    _currencyCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  void _populate(AppSettings s) {
    if (_populated) return;
    _populated = true;
    _businessNameCtrl.text = s.businessName;
    _taxRateCtrl.text = s.taxRate == s.taxRate.truncate()
        ? s.taxRate.toStringAsFixed(0)
        : s.taxRate.toString();
    _currencyCtrl.text = s.currencySymbol;
    _footerCtrl.text = s.receiptFooter;
    _themeMode = s.themeMode;
    _autoBackup = s.autoBackupEnabled;
    _logoPath = s.logoPath;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final rawRate = _taxRateCtrl.text.trim().replaceAll(',', '.');
    final taxRate = (double.tryParse(rawRate) ?? 0.0).clamp(0.0, 100.0);
    context.read<SettingsCubit>().update(
          AppSettings(
            businessName: _businessNameCtrl.text.trim(),
            taxRate: taxRate,
            currencySymbol: _currencyCtrl.text.trim(),
            receiptFooter: _footerCtrl.text.trim(),
            themeMode: _themeMode,
            logoPath: _logoPath,
            autoBackupEnabled: _autoBackup,
          ),
        );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  Future<void> _exportBackup() async {
    try {
      await GetIt.instance<BackupService>().exportAndShare();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    if (!File(path).existsSync()) return;

    try {
      final count =
          await GetIt.instance<BackupService>().importBackup(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $count items')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path!);
    final destPath = p.join(appDir.path, 'business_logo$ext');
    await File(picked.path!).copy(destPath);
    setState(() => _logoPath = destPath);
  }

  void _removeLogo() => setState(() => _logoPath = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (prev, curr) =>
            prev is SettingsLoading && curr is SettingsReady,
        listener: (_, state) {
          if (state is SettingsReady) _populate(state.settings);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _businessNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Business name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxRateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tax rate (%)',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n =
                        double.tryParse(v.trim().replaceAll(',', '.'));
                    if (n == null || n < 0 || n > 100) {
                      return 'Enter a rate between 0 and 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currencyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Currency symbol',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 3,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _footerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Receipt footer',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // -- Logo picker --
                Text('Receipt logo',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (_logoPath != null && File(_logoPath!).existsSync())
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_logoPath!),
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: _removeLogo,
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.image),
                    label: const Text('Choose logo'),
                  ),

                const SizedBox(height: 24),
                _ThemeModeSelector(
                  value: _themeMode,
                  onChanged: (mode) => setState(() => _themeMode = mode),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save settings'),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text('Data', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-backup after each sale'),
                  subtitle: const Text(
                    'Saves a local JSON backup automatically',
                  ),
                  value: _autoBackup,
                  onChanged: (v) => setState(() => _autoBackup = v),
                ),
                BlocBuilder<SyncCubit, SyncState>(
                  builder: (context, syncState) {
                    final lastBackup = switch (syncState) {
                      SyncIdle(lastBackupAt: final dt) => dt,
                      SyncError(lastBackupAt: final dt) => dt,
                      _ => null,
                    };
                    final isBacking = syncState is SyncInProgress;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (lastBackup != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Last backup: ${_fmtDateTime(lastBackup)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        if (syncState is SyncError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              syncState.message,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: isBacking
                              ? null
                              : () =>
                                  context.read<SyncCubit>().runBackup(),
                          icon: isBacking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.backup),
                          label: Text(
                            isBacking ? 'Backing up\u2026' : 'Backup now',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _exportBackup,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export & share'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _importBackup,
                  icon: const Icon(Icons.download),
                  label: const Text('Import backup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  final mo = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '${dt.year}-$mo-$d $h:$mi';
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'system',
              icon: Icon(Icons.brightness_auto),
              label: Text('System'),
            ),
            ButtonSegment(
              value: 'light',
              icon: Icon(Icons.light_mode),
              label: Text('Light'),
            ),
            ButtonSegment(
              value: 'dark',
              icon: Icon(Icons.dark_mode),
              label: Text('Dark'),
            ),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}
