import 'dart:io';

import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:cashier_app/features/sync/domain/services/backup_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
                OutlinedButton.icon(
                  onPressed: _exportBackup,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export backup'),
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
