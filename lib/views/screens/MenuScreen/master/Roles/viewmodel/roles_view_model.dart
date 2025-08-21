import 'package:flutter/material.dart';
import '../repository/roles_service.dart';

class RolesViewModel extends ChangeNotifier {
  final RolesService _service = RolesService();
  bool _loading = false;
  String? _error;
  bool _menusLoading = false;
  bool _submitting = false;
  List<Map<String, dynamic>> _roles = [];

  List<Map<String, dynamic>> _menus = [];
  final Set<String> _selectedMenus = {};
  bool get isMenusLoading => _menusLoading;
  bool get isSubmitting => _submitting;
  bool get isLoading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get roles => _roles;
  List<Map<String, dynamic>> get menus => _menus;
  Set<String> get selectedMenus => _selectedMenus;

  Future<void> fetch() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      _roles = await _service.fetchRoles();
      _menusLoading = true;
      notifyListeners();
      _menus = await _service.fetchMenus();
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false;
      _menusLoading = false;

      notifyListeners();
    }
  }

  Future<void> create(String name, String description, int priority) async {
    try {
      _submitting = true;
      notifyListeners();
      await _service.createRole({
        'name': name,
        'description': description,
        'priority': priority,
        'menus': _selectedMenus.join(','),
      });
      await fetch();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> update(
      int id, String name, String description, int priority) async {
    try {
      _submitting = true;
      notifyListeners();
      await _service.updateRole(id, {
        'name': name,
        'description': description,
        'priority': priority,
        'menus': _selectedMenus.join(','),
      });
      await fetch();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    await _service.deleteRole(id);
    await fetch();
  }

  void setSelectedMenusByNames(Iterable<String> names) {
    _selectedMenus
      ..clear()
      ..addAll(names.map((e) => e.trim()).where((e) => e.isNotEmpty));
    notifyListeners();
  }

  void toggleMenuSelection(String menuName, bool selected) {
    if (selected) {
      _selectedMenus.add(menuName);
    } else {
      _selectedMenus.remove(menuName);
    }
    notifyListeners();
  }

  Future<void> fetchMenusOnly() async {
    try {
      _menusLoading = true;
      notifyListeners();
      final fetched = await _service.fetchMenus();
      _menus = fetched;
    } catch (e) {
      _error = '$e';
    } finally {
      _menusLoading = false;
      notifyListeners();
    }
  }
}
