import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/court_viewmodel.dart';
import '../models/court_model.dart';
import 'court_form_screen.dart';

class CourtListScreen extends StatefulWidget {
  const CourtListScreen({Key? key}) : super(key: key);

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtViewModel>().loadCourts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF264653),
        elevation: 0,
        title: Text(
          'Court Management',
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CourtViewModel>().loadCourts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<CourtViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (viewModel.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.error}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadCourts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.courts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_tennis,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courts found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first court to get started',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.courts.length,
            itemBuilder: (context, index) {
              final court = viewModel.courts[index];
              return _buildCourtCard(context, court, viewModel);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: const Color(0xFF264653),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCourtCard(
      BuildContext context, Court court, CourtViewModel viewModel) {
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
            color: court.active
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.sports_tennis,
            color: court.active ? Colors.green : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          court.courtName,
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
              court.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[300],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  label: court.tournamentName != null &&
                          court.tournamentName!.isNotEmpty
                      ? court.tournamentName!
                      : (court.tournamentId != null
                          ? 'Tournament #${court.tournamentId}'
                          : 'No tournament'),
                  color: const Color(0xFF3E5A6B),
                ),
                _buildChip(
                  label: court.category == null || court.category!.isEmpty
                      ? 'No category'
                      : court.category!,
                  color: const Color(0xFF3E6B4E),
                ),
                _buildChip(
                  label:
                      court.umpireName != null && court.umpireName!.isNotEmpty
                          ? court.umpireName!
                          : (court.umpireId != null
                              ? 'Umpire #${court.umpireId}'
                              : 'No umpire'),
                  color: const Color(0xFF6B3E3E),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: court.active
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: court.active ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                court.active ? 'Active' : 'Inactive',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: court.active ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value, court, viewModel),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    court.active ? Icons.block : Icons.check_circle,
                    color: court.active ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(court.active ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Court court, CourtViewModel viewModel) {
    switch (action) {
      case 'edit':
        _navigateToForm(context, court: court);
        break;
      case 'toggle':
        _toggleCourtStatus(court, viewModel);
        break;
      case 'delete':
        _showDeleteDialog(court, viewModel);
        break;
    }
  }

  void _navigateToForm(BuildContext context, {Court? court}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourtFormScreen(court: court),
      ),
    );
  }

  void _toggleCourtStatus(Court court, CourtViewModel viewModel) {
    viewModel.toggleCourtStatus(court.id!).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Court ${court.active ? 'deactivated' : 'activated'} successfully!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update court status: ${viewModel.error}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }

  void _showDeleteDialog(Court court, CourtViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: Text(
          'Delete Court',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${court.courtName}"? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[300],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourt(court, viewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCourt(Court court, CourtViewModel viewModel) {
    viewModel.deleteCourt(court.id!).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Court deleted successfully!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete court: ${viewModel.error}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }
}
