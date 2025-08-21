import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/umpire_viewmodel.dart';
import '../models/umpire_model.dart';
import 'umpire_form_screen.dart';

class UmpireListScreen extends StatefulWidget {
  const UmpireListScreen({Key? key}) : super(key: key);

  @override
  State<UmpireListScreen> createState() => _UmpireListScreenState();
}

class _UmpireListScreenState extends State<UmpireListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UmpireViewModel>().initializeData();
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
          'Umpire Management',
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
            onPressed: () => context.read<UmpireViewModel>().initializeData(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<UmpireViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (viewModel.listError.isNotEmpty) {
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
                    'Error: ${viewModel.listError}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.initializeData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.umpires.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No umpires found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first umpire to get started',
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
            itemCount: viewModel.umpires.length,
            itemBuilder: (context, index) {
              final umpire = viewModel.umpires[index];
              return _buildUmpireCard(context, umpire, viewModel);
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

  Widget _buildUmpireCard(
      BuildContext context, Umpire umpire, UmpireViewModel viewModel) {
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
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.green,
            size: 24,
          ),
        ),
        title: Text(
          '${umpire.userName}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Tournament: ${umpire.tournamentName}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tag: ${umpire.userTag}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green,
                  width: 1,
                ),
              ),
              child: Text(
                'Umpire',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value, umpire, viewModel),
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

  void _handleMenuAction(
      String action, Umpire umpire, UmpireViewModel viewModel) {
    switch (action) {
      case 'edit':
        _navigateToForm(context, umpire: umpire);
        break;
      case 'delete':
        _showDeleteDialog(umpire, viewModel);
        break;
    }
  }

  void _navigateToForm(BuildContext context, {Umpire? umpire}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UmpireFormScreen(umpire: umpire),
      ),
    );
  }

  void _showDeleteDialog(Umpire umpire, UmpireViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: Text(
          'Delete Umpire',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this umpire? This action cannot be undone.',
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
              _deleteUmpire(umpire, viewModel);
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

  void _deleteUmpire(Umpire umpire, UmpireViewModel viewModel) {
    viewModel.deleteUmpire(umpire.id!).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Umpire removed successfully!',
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
              'Failed to remove umpire: ${viewModel.listError}',
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
