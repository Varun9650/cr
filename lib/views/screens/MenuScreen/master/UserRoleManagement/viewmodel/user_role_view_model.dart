import 'package:flutter/material.dart';
import '../repository/user_role_service.dart';

class UserRoleViewModel extends ChangeNotifier {
  final UserRoleService _service = UserRoleService();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _allRoleDefs = [];
  List<Map<String, dynamic>> _users = [];
  String? _selectedRoleName;
  final Map<int, List<String>> _userIdToRoles = {};

  bool get isLoading => _loading;
  String? get error => _error;
  // Sorted by priority (asc)
  List<Map<String, dynamic>> get roles => _allRoleDefs
    ..sort((a, b) => (a['priority'] ?? 999).compareTo(b['priority'] ?? 999));
  List<Map<String, dynamic>> get users => _filteredUsers();
  String? get selectedRoleName => _selectedRoleName;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      _allRoleDefs = await _service.fetchAllRoles();
      _users = await _service.fetchAllUsers();
      _buildUserRolesFromUsers();
      _selectedRoleName = roles.isNotEmpty
          ? (roles
                ..sort((a, b) =>
                    (a['priority'] ?? 999).compareTo(b['priority'] ?? 999)))
              .first['name']
          : 'Unknown';
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _buildUserRolesFromUsers() {
    _userIdToRoles.clear();
    for (final u in _users) {
      final id = _readUserId(u);
      final roles = u['roles'] as List? ?? [];
      final List<String> roleNames = [];
      for (final r in roles) {
        if (r is String) {
          roleNames.add(r);
        } else if (r is Map) {
          final name = (r['name'] ?? r['role'] ?? '').toString();
          if (name.isNotEmpty) roleNames.add(name);
        }
      }
      _userIdToRoles[id] = roleNames;
    }
  }

  // List<Map<String, dynamic>> _filteredUsers() {
  //   if (_selectedRoleName == null) return [];
  //   final target = _selectedRoleName!;
  //   return _users.where((u) {
  //     final id = _readUserId(u);
  //     final roles = _userIdToRoles[id] ?? [];
  //     if (target == 'Unknown') return roles.isEmpty;
  //     if (roles.isEmpty) return false;
  //     // Highest priority role determines bucket
  //     roles.sort((a, b) => _getPriority(a).compareTo(_getPriority(b)));
  //     return roles.first == target;
  //   }).toList();
  // }
  List<Map<String, dynamic>> _filteredUsers() {
    if (_selectedRoleName == null) return [];
    final target = _selectedRoleName!;
    final base = _users.where((u) {
      final bucket = _bucketRoleForUser(u);
      return bucket == target;
    });

    if (_searchQuery.trim().isEmpty) return base.toList();
    final q = _searchQuery.toLowerCase();
    return base.where((u) {
      final title = titleFor(u).toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final username = (u['username'] ?? '').toString().toLowerCase();
      return title.contains(q) || email.contains(q) || username.contains(q);
    }).toList();
  }

  String _bucketRoleForUser(Map<String, dynamic> u) {
    final id = _readUserId(u);
    final roles = List<String>.from(_userIdToRoles[id] ?? const []);
    if (roles.isEmpty) return 'Unknown';
    // consider only roles present in all-role list
    final allNames =
        _allRoleDefs.map((e) => (e['name'] ?? '').toString()).toSet();
    final matching = roles.where((r) => allNames.contains(r)).toList();
    if (matching.isEmpty) return 'Unknown';
    matching.sort((a, b) => _getPriority(a).compareTo(_getPriority(b)));
    return matching.first;
  }

  int _getPriority(String roleName) {
    final r = _allRoleDefs.firstWhere((e) => (e['name'] ?? '') == roleName,
        orElse: () => {'priority': 999});
    return (r['priority'] ?? 999) is int
        ? r['priority']
        : int.tryParse('${r['priority']}') ?? 999;
  }

  void setSelectedRole(String roleName) {
    _selectedRoleName = roleName;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<void> updateUserRoles(int userId, List<String> roles) async {
    print('Updating roles for user $userId: $roles');
    await _service.updateUserRoles(userId, roles);
    _userIdToRoles[userId] = List.from(roles);
    notifyListeners();
  }

  List<String> rolesFor(int userId) => _userIdToRoles[userId] ?? [];

  int _readUserId(Map<String, dynamic> u) {
    final idRaw = u['id'] ?? u['userId'];
    if (idRaw is int) return idRaw;
    return int.tryParse('$idRaw') ?? -1;
  }

  String titleFor(Map<String, dynamic> u) {
    return (u['fullName'] ??
            u['username'] ??
            u['email'] ??
            'User ${_readUserId(u)}')
        .toString();
  }
}
