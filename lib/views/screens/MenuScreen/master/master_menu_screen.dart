import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Entity/BadmintonCourt/view/court_list_screen.dart';
import '../../../../Entity/UmpireManagement/view/umpire_list_screen.dart';
import 'Roles/view/roles_list_screen.dart';
import 'UserCreation/view/user_creation_list_screen.dart';
import 'UserRoleManagement/view/user_role_management_screen.dart';

class MasterMenuScreen extends StatelessWidget {
  const MasterMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF264653),
        elevation: 0,
        title: Text(
          'Master Management',
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
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  title: 'Badminton Court',
                  subtitle:
                      'Manage badminton courts, add new courts, update existing ones',
                  icon: Icons.sports_tennis,
                  color: Colors.blue,
                  onTap: () => _navigateToBadmintonCourt(context),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  context,
                  title: 'Umpire Management',
                  subtitle:
                      'Manage umpires, add new umpires, update existing ones',
                  icon: Icons.person,
                  color: Colors.green,
                  onTap: () => _navigateToUmpireManagement(context),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  context,
                  title: 'User Creation',
                  subtitle:
                      'Create, edit, and delete users (with email OTP option)',
                  icon: Icons.person_add,
                  color: Colors.teal,
                  onTap: () => _navigateToUserCreation(context),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  context,
                  title: 'Roles',
                  subtitle: 'Create, update, and delete roles',
                  icon: Icons.assignment_ind,
                  color: Colors.deepPurple,
                  onTap: () => _navigateToRoles(context),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  context,
                  title: 'User Role Management',
                  subtitle: 'View users by role and update roles',
                  icon: Icons.group,
                  color: Colors.orange,
                  onTap: () => _navigateToUserRoles(context),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Master Management',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your Courts, Umpires, Role and Users',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBadmintonCourt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourtListScreen(),
      ),
    );
  }

  void _navigateToUmpireManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UmpireListScreen(),
      ),
    );
  }

  void _navigateToRoles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RolesListScreen(),
      ),
    );
  }

  void _navigateToUserRoles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserRoleManagementScreen(),
      ),
    );
  }

  void _navigateToUserCreation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserCreationListScreen()),
    );
  }
}
