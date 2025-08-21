import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/roles_view_model.dart';

class RolesListScreen extends StatefulWidget {
  const RolesListScreen({Key? key}) : super(key: key);
  @override
  State<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RolesViewModel>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RolesViewModel>(builder: (context, vm, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('Roles')),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: const Icon(Icons.add),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vm.roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = vm.roles[index];
                  final menus = _extractMenuNames(r);
                  final visibleMenus = menus.take(4).toList();
                  final extraCount = menus.length - visibleMenus.length;
                  return Card(
                      child: ListTile(
                    title: Text(r['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((r['description'] ?? '').toString()),
                        if (menus.isNotEmpty)
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 4),
                          //   child: Text(
                          //     'Menus: ${menus.join(', ')}',
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .bodySmall
                          //         ?.copyWith(color: Colors.black54),
                          //   ),
                          // ),
                          Row(
                            children: [
                              const Icon(Icons.menu,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('Menus',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        if (menus.isNotEmpty) const SizedBox(height: 6),
                        if (menus.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final m in visibleMenus)
                                Chip(
                                  label: Text(
                                    m,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.08),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                ),
                              if (extraCount > 0)
                                ActionChip(
                                  label: Text('+$extraCount more'),
                                  onPressed: () => _showMenusSheet(
                                      menus, (r['name'] ?? 'Role') as String),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                            ],
                          )
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(r['id']),
                        ),
                      ],
                    ),
                  ));
                },
              ),
      );
    });
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final prioCtrl = TextEditingController(text: '1');
    final vm = context.read<RolesViewModel>();
    vm.fetchMenusOnly();
    vm.setSelectedMenusByNames(const []);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<RolesViewModel>(builder: (c, vmDialog, __) {
          return AlertDialog(
            title: const Text('Create Role'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name')),
                  TextField(
                      controller: descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Description')),
                  TextField(
                      controller: prioCtrl,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _MenusMultiSelect(onChanged: () => setState(() {})),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: vmDialog.isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: vmDialog.isSubmitting
                    ? null
                    : () async {
                        await dialogContext.read<RolesViewModel>().create(
                            nameCtrl.text.trim(),
                            descCtrl.text.trim(),
                            int.tryParse(prioCtrl.text) ?? 1);
                        if (mounted) Navigator.pop(dialogContext);
                      },
                child: vmDialog.isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Saving...',
                              style: TextStyle(color: Colors.black)),
                        ],
                      )
                    : const Text('Save', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> role) {
    final nameCtrl =
        TextEditingController(text: role['name']?.toString() ?? '');
    final descCtrl =
        TextEditingController(text: role['description']?.toString() ?? '');
    final prioCtrl =
        TextEditingController(text: role['priority']?.toString() ?? '1');
    final vm = context.read<RolesViewModel>();
    vm.fetchMenusOnly();
    vm.setSelectedMenusByNames(_extractMenuNames(role));
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<RolesViewModel>(builder: (c, vmDialog, __) {
          return AlertDialog(
            title: const Text('Edit Role'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name')),
                  TextField(
                      controller: descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Description')),
                  TextField(
                      controller: prioCtrl,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _MenusMultiSelect(onChanged: () => setState(() {})),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: vmDialog.isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: vmDialog.isSubmitting
                    ? null
                    : () async {
                        await dialogContext.read<RolesViewModel>().update(
                            role['id'],
                            nameCtrl.text.trim(),
                            descCtrl.text.trim(),
                            int.tryParse(prioCtrl.text) ?? 1);
                        if (mounted) Navigator.pop(dialogContext);
                      },
                child: vmDialog.isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Saving...',
                              style: TextStyle(color: Colors.black)),
                        ],
                      )
                    : const Text('Save', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showMenusSheet(List<String> menus, String roleName) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$roleName menus',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in menus)
                      Chip(
                        label: Text(
                          m,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Role'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<RolesViewModel>().delete(id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  List<String> _extractMenuNames(Map<String, dynamic> r) {
    final raw = r['menus'];
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((e) => e is String ? e : _readMenuName(e))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw is String) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _readMenuName(dynamic menu) {
    if (menu == null) return '';
    if (menu is String) return menu;
    if (menu is Map) {
      return (menu['name'] ??
              menu['menuName'] ??
              menu['title'] ??
              menu['menu'] ??
              menu['label'] ??
              menu['screenName'] ??
              menu['display_name'] ??
              '')
          .toString();
    }
    return menu.toString();
  }
}

class _MenusMultiSelect extends StatelessWidget {
  final VoidCallback onChanged;
  const _MenusMultiSelect({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RolesViewModel>();

    if (vm.isMenusLoading) {
      return Row(
        children: const [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Loading menus...')
        ],
      );
    }

    final menuNames = vm.menus
        .map((m) => m is Map<String, dynamic>
            ? (m['moduleName'] ?? '').toString()
            : m.toString())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child:
                Text('Menus', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        if (menuNames.isEmpty)
          const Text('No menus found')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in menuNames)
                FilterChip(
                  label: Text(name),
                  selected: vm.selectedMenus.contains(name),
                  onSelected: vm.isSubmitting
                      ? null
                      : (sel) {
                          vm.toggleMenuSelection(name, sel);
                          onChanged();
                        },
                ),
            ],
          ),
      ],
    );
  }
}
