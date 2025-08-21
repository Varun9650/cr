import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/umpire_viewmodel.dart';
import '../models/umpire_model.dart';

class UmpireFormScreen extends StatefulWidget {
  final Umpire? umpire;

  const UmpireFormScreen({Key? key, this.umpire}) : super(key: key);

  @override
  State<UmpireFormScreen> createState() => _UmpireFormScreenState();
}

class _UmpireFormScreenState extends State<UmpireFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedUser; // Store only user ID
  Map<String, dynamic>? _selectedTournament;
  String _userTag = 'Umpire';

  @override
  void initState() {
    super.initState();
    if (widget.umpire != null) {
      _userTag = widget.umpire!.userTag!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.umpire != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF264653),
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Umpire' : 'Add New Umpire',
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
      body: Consumer<UmpireViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildFormCard(viewModel),
                  const SizedBox(height: 16),
                  _buildActionButtons(viewModel),
                ],
              ),
            ),
          );
        },
      ),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.green,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.umpire != null
                        ? 'Edit Umpire Details'
                        : 'Add New Umpire',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.umpire != null
                        ? 'Update umpire information'
                        : 'Select user and tournament to assign as umpire',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(UmpireViewModel viewModel) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Umpire Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // User Dropdown
            _buildDropdownField<int>(
              label: 'Select User',
              hint: 'Choose a user to assign as umpire',
              icon: Icons.person,
              items: viewModel.users
                  .map<DropdownMenuItem<int>>((user) => DropdownMenuItem<int>(
                        value: user['userId'],
                        child: Text('${user['fullName']} (${user['email']})'),
                      ))
                  .toList(),
              value: _selectedUser,
              onChanged: (int? userId) {
                setState(() {
                  _selectedUser = userId;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a user';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Tournament Dropdown
            _buildDropdownField(
              label: 'Select Tournament',
              hint: 'Choose a tournament',
              icon: Icons.emoji_events,
              items: viewModel.tournaments
                  .map((tournament) => DropdownMenuItem(
                        value: tournament,
                        child: Text(
                            '${tournament['tournament_name']} (${tournament['dates']})'),
                      ))
                  .toList(),
              value: _selectedTournament,
              onChanged: (Map<String, dynamic>? tournament) {
                setState(() {
                  _selectedTournament = tournament;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a tournament';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required T? value,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF34495E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          dropdownColor: const Color(0xFF34495E),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF34495E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UmpireViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : _handleCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed:
                viewModel.isLoading ? null : () => _handleSubmit(viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF264653),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.umpire != null ? 'Update' : 'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleSubmit(UmpireViewModel viewModel) {
    print(
        'Submitting form with userId: $_selectedUser, tournament: $_selectedTournament, tag: $_userTag');
    if (_formKey.currentState!.validate()) {
      final userTag = _userTag;

      if (widget.umpire != null) {
        // Update existing umpire
        viewModel
            .updateUmpire(
          widget.umpire!.id!,
          _selectedUser!,
          userTag,
          _selectedTournament!['id'],
        )
            .then((success) {
          if (success) {
            _showSuccessMessage('Umpire updated successfully!');
            Navigator.pop(context);
          } else {
            _showErrorMessage(' ${viewModel.updateError}');
          }
        });
      } else {
        // Add new umpire
        viewModel
            .addUmpire(
          _selectedUser!,
          userTag,
          _selectedTournament!['id'],
        )
            .then((success) {
          if (success) {
            _showSuccessMessage('Umpire added successfully!');
            Navigator.pop(context);
          } else {
            print('erro : ${viewModel.addError}');
            final error = viewModel.addError;
            final typeStart = error.indexOf("TypeError:");
            final typeEnd = error.indexOf(" type");
            if (typeStart != -1 && typeEnd != -1 && typeEnd > typeStart) {
              _showErrorMessage(error.substring(typeStart, typeEnd));
            } else {
              _showErrorMessage(error);
            }
          }
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
