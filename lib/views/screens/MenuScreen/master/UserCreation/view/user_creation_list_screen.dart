import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/user_creation_view_model.dart';
import '../models/user_model.dart';
import 'user_creation_form_screen.dart';

class UserCreationListScreen extends StatelessWidget {
  const UserCreationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserCreationViewModel()..loadUsers(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF264653),
          elevation: 0,
          title: Text(
            'User Creation',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Consumer<UserCreationViewModel>(builder: (context, vm, _) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: vm.isLoading ? null : () => vm.loadUsers(),
              );
            })
          ],
        ),
        body: Consumer<UserCreationViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (vm.error != null) {
              return Center(
                child: Text('Error: ${vm.error}',
                    style: GoogleFonts.poppins(color: Colors.red)),
              );
            }
            // if (vm.users.isEmpty) {
            //   return Center(
            //     child: Text('No users found',
            //         style: GoogleFonts.poppins(color: Colors.grey[400])),
            //   );
            // }
            // return ListView.builder(
            //   padding: const EdgeInsets.all(16),
            //   itemCount: vm.users.length,
            //   itemBuilder: (context, index) {
            //     final u = vm.users[index];
            //     return _UserTile(user: u);
            //   },
            // );

            return Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: vm.setSearchQuery,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, mobile, gender...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C3E50),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Results count
                if (vm.searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${vm.filteredUsers.length} results found',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => vm.setSearchQuery(''),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.poppins(
                              color: Colors.blue[300],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Users List
                Expanded(
                  child: vm.filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            vm.searchQuery.isNotEmpty
                                ? 'No users found matching "${vm.searchQuery}"'
                                : 'No users found',
                            style: GoogleFonts.poppins(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.filteredUsers.length,
                          itemBuilder: (context, index) {
                            final u = vm.filteredUsers[index];
                            return _UserTile(user: u);
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => const UserCreationFormScreen()),
              );
              Provider.of<UserCreationViewModel>(ctx, listen: false)
                  .loadUsers();
            },
            backgroundColor: const Color(0xFF264653),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUserMin user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UserCreationViewModel>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (user.isEmailVerified ?? false)
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            (user.isEmailVerified ?? false) ? Icons.verified : Icons.pending,
            color:
                (user.isEmailVerified ?? false) ? Colors.green : Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          user.fullName ?? 'Unnamed',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email ?? '-',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[300],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip((user.gender ?? 'N/A'), const Color(0xFF3E6B4E)),
                _chip(
                    user.mobileNumber == null || user.mobileNumber!.isEmpty
                        ? 'No mob'
                        : user.mobileNumber!,
                    const Color(0xFF3E5A6B)),
                _chip(
                    (user.isEmailVerified ?? false)
                        ? 'Email Verified'
                        : 'Not Verified',
                    const Color(0xFF6B3E3E)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserCreationFormScreen(user: user),
                ),
              );
              vm.loadUsers();
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF2C3E50),
                  title: Text('Delete User',
                      style: GoogleFonts.poppins(color: Colors.white)),
                  content: Text('Delete ${user.fullName ?? user.email}?',
                      style: GoogleFonts.poppins(color: Colors.white70)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        )),
                  ],
                ),
              );
              if (confirm == true) {
                await vm.deleteUser(user.id!);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('User deleted'),
                  backgroundColor: Colors.green,
                ));
              }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
