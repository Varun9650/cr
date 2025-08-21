import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_role_view_model.dart';

class UserRoleManagementScreen extends StatefulWidget {
  const UserRoleManagementScreen({Key? key}) : super(key: key);
  @override
  State<UserRoleManagementScreen> createState() =>
      _UserRoleManagementScreenState();
}

class _UserRoleManagementScreenState extends State<UserRoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserRoleViewModel>().init());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleViewModel>(builder: (context, vm, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Role Management')),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _ScrollChips(
                    roles: [
                      ...vm.roles.map((e) => (e['name'] ?? '').toString()),
                      'Unknown'
                    ],
                    selected: vm.selectedRoleName,
                    onSelect: vm.setSelectedRole,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextField(
                      onChanged: vm.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search users by name, email, username',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final u = vm.users[index];
                        final id = u['userId'];
                        final roles = vm.rolesFor(id);
                        print('User: ${vm.titleFor(u)}, Roles: $roles');
                        return Card(
                          child: ListTile(
                            title: Text(vm.titleFor(u)),
                            subtitle: Text(
                                roles.isEmpty ? 'Unknown' : roles.join(', ')),
                            trailing: TextButton(
                              onPressed: () =>
                                  _showEditRolesDialog(vm, id, roles),
                              child: const Text('Edit Roles'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      );
    });
  }

  void _showEditRolesDialog(
      UserRoleViewModel vm, int userId, List<String> current) {
    final Set<String> selected = current.map((e) => e.trim()).toSet();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            final all = vm.roles;
            return AlertDialog(
              title: const Text('Update Roles'),
              content: SizedBox(
                height: 320,
                width: 360,
                child: all.isEmpty
                    ? const Center(child: Text('No roles available'))
                    : ListView.builder(
                        itemCount: all.length,
                        itemBuilder: (_, i) {
                          final r = all[i];
                          final name =
                              ((r['name'] ?? r['role'] ?? '') as Object)
                                  .toString()
                                  .trim();
                          final checked = selected.contains(name);
                          return CheckboxListTile(
                            title: Text(name.isEmpty ? '(unnamed)' : name),
                            value: checked,
                            onChanged: (v) {
                              setLocalState(() {
                                if (v == true)
                                  selected.add(name);
                                else
                                  selected.remove(name);
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    await vm.updateUserRoles(userId, selected.toList());
                    if (mounted) Navigator.pop(dialogCtx);
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ScrollChips extends StatelessWidget {
  final List<String> roles;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _ScrollChips(
      {required this.roles, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: roles.map((r) {
          final isSel = selected == r;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(r),
              selected: isSel,
              onSelected: (_) => onSelect(r),
            ),
          );
        }).toList(),
      ),
    );
  }
}
