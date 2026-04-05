import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await sl<UserRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.person_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users. Add one to enable login.'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: Icon(
                        user.isAdmin
                            ? Icons.admin_panel_settings
                            : Icons.person,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(
                        '${user.username} • ${user.role}'
                        '${user.isActive ? "" : " (disabled)"}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(context, existing: user),
                      ),
                    );
                  },
                ),
    );
  }

  void _showForm(BuildContext context, {User? existing}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UserFormSheet(
        existing: existing,
        onSaved: _load,
      ),
    );
  }
}

class _UserFormSheet extends StatefulWidget {
  const _UserFormSheet({required this.onSaved, this.existing});

  final User? existing;
  final VoidCallback onSaved;

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _displayCtrl;
  late final TextEditingController _pinCtrl;
  late String _role;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    _usernameCtrl = TextEditingController(text: u?.username ?? '');
    _displayCtrl = TextEditingController(text: u?.displayName ?? '');
    _pinCtrl = TextEditingController(text: u?.pin ?? '');
    _role = u?.role ?? 'cashier';
    _isActive = u?.isActive ?? true;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _displayCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = User(
      id: widget.existing?.id,
      username: _usernameCtrl.text.trim(),
      displayName: _displayCtrl.text.trim(),
      pin: _pinCtrl.text.trim(),
      role: _role,
      isActive: _isActive,
    );
    await sl<UserRepository>().save(user);
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add User' : 'Edit User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayCtrl,
              decoration: const InputDecoration(labelText: 'Display Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinCtrl,
              decoration: const InputDecoration(labelText: 'PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'cashier'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: Text(widget.existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
