import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/court_viewmodel.dart';
import '../models/court_model.dart';
import '../../UmpireManagement/repositories/umpire_repository.dart';
import '../../UmpireManagement/models/umpire_model.dart';
import '../../../views/screens/MenuScreen/tournament/my_tournamnet_screen/groups/groupService.dart';
import '../../UmpireManagement/view/umpire_form_screen.dart';
import '../../UmpireManagement/viewmodels/umpire_viewmodel.dart';

class CourtFormScreen extends StatefulWidget {
  final Court? court;

  const CourtFormScreen({Key? key, this.court}) : super(key: key);

  @override
  State<CourtFormScreen> createState() => _CourtFormScreenState();
}

class _CourtFormScreenState extends State<CourtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  // Dropdown state
  final UmpireRepository _umpireRepository = UmpireRepository();
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> _tournaments = [];
  List<String> _groups = [];
  List<Umpire> _umpires = [];

  Map<String, dynamic>? _selectedTournament;
  String? _selectedGroupName; // category
  int? _selectedUmpireId;

  @override
  void initState() {
    super.initState();
    if (widget.court != null) {
      _courtNameController.text = widget.court!.courtName;
      _descriptionController.text = widget.court!.description;
      _isActive = widget.court!.active;
      _selectedGroupName = widget.court!.category;
      _selectedUmpireId = widget.court!.umpireId;
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load tournaments
      final tournaments = await _umpireRepository.getAllTournaments();
      // Preselect tournament if editing
      Map<String, dynamic>? preselectedTournament;
      if (widget.court?.tournamentId != null) {
        final match = tournaments.firstWhere(
          (t) => (t['id'] ?? t['tournament_id']) == widget.court!.tournamentId,
          orElse: () => {},
        );
        if (match.isNotEmpty) preselectedTournament = match;
      }

      setState(() {
        _tournaments = tournaments;
        _selectedTournament = preselectedTournament;
      });

      if (_selectedTournament != null) {
        final tid =
            _selectedTournament!['id'] ?? _selectedTournament!['tournament_id'];
        await _loadGroupsAndUmpiresForTournament(tid);
      }
    } catch (e) {
      // ignore for now, errors will be surfaced via submission
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGroupsAndUmpiresForTournament(int tournamentId) async {
    // Load groups
    try {
      final groupsData = await _groupService.fetchAllGroups(tournamentId);
      final groupNames = (groupsData ?? [])
          .map((g) => (g as Map)['group_name']?.toString())
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toList();
      // Load umpires for tournament
      final umpires =
          await _umpireRepository.getUmpiresByTournamentId(tournamentId);

      setState(() {
        _groups = groupNames;
        _umpires = umpires;
        // set defaults if empty selection
        _selectedGroupName ??= _groups.isNotEmpty ? _groups.first : null;
        if (_selectedUmpireId != null &&
            !_umpires.any((u) => u.id == _selectedUmpireId)) {
          _selectedUmpireId = null;
        }
      });
    } catch (e) {
      setState(() {
        _groups = [];
        _umpires = [];
      });
    }
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.court != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF264653),
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Court' : 'Add New Court',
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
      body: Consumer<CourtViewModel>(
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
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_tennis,
                color: Colors.blue,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.court != null
                        ? 'Edit Court Details'
                        : 'Add New Court',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.court != null
                        ? 'Update court information'
                        : 'Enter court details below',
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

  Widget _buildFormCard(CourtViewModel viewModel) {
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
              'Court Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Court Name Field
            _buildTextField(
              controller: _courtNameController,
              label: 'Court Name',
              hint: 'Enter court name',
              icon: Icons.sports_tennis,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Court name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter court description',
              icon: Icons.description,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Tournament Dropdown
            _buildDropdownField<Map<String, dynamic>>(
              label: 'Tournament',
              hint: 'Select tournament',
              icon: Icons.emoji_events,
              value: _selectedTournament,
              items: _tournaments
                  .map((t) => DropdownMenuItem<Map<String, dynamic>>(
                        value: t,
                        child: Text(
                          t['tournament_name']?.toString() ??
                              t['tournamentName']?.toString() ??
                              'Tournament ${t['id'] ?? t['tournament_id']}',
                          style: GoogleFonts.poppins(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (val) async {
                setState(() {
                  _selectedTournament = val;
                  _selectedGroupName = null;
                  _selectedUmpireId = null;
                  _groups = [];
                  _umpires = [];
                });
                if (val != null) {
                  final tid = val['id'] ?? val['tournament_id'];
                  await _loadGroupsAndUmpiresForTournament(tid);
                }
              },
              validator: (v) => v == null ? 'Select tournament' : null,
            ),

            const SizedBox(height: 16),

            // Group/Category Dropdown
            _buildDropdownField<String>(
              label: 'Category',
              hint: _selectedTournament == null
                  ? 'Select tournament first'
                  : (_groups.isEmpty ? 'No categories' : 'Select category'),
              icon: Icons.category,
              value: _selectedGroupName,
              items: _groups
                  .map((g) => DropdownMenuItem<String>(
                        value: g,
                        child: Text(g,
                            style: GoogleFonts.poppins(color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: _groups.isEmpty
                  ? null
                  : (val) => setState(() {
                        _selectedGroupName = val;
                      }),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select category' : null,
            ),

            const SizedBox(height: 16),

            // Umpire Dropdown with Add action
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDropdownField<int>(
                    label: 'Umpire',
                    hint: _selectedTournament == null
                        ? 'Select tournament first'
                        : (_umpires.isEmpty ? 'No umpires' : 'Select umpire'),
                    icon: Icons.sports,
                    value: _selectedUmpireId,
                    items: _umpires
                        .map((u) => DropdownMenuItem<int>(
                              value: u.id,
                              child: Text(
                                (u.name ?? u.userName ?? 'Umpire ${u.id}') +
                                    (u.tournamentName != null
                                        ? ' - ${u.tournamentName}'
                                        : ''),
                                style: GoogleFonts.poppins(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: _umpires.isEmpty
                        ? null
                        : (val) => setState(() {
                              _selectedUmpireId = val;
                            }),
                    validator: (v) => v == null ? 'Select umpire' : null,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _selectedTournament == null
                        ? null
                        : () async {
                            // Navigate to add umpire screen
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (_) => UmpireViewModel(),
                                  child: const UmpireFormScreen(),
                                ),
                              ),
                            );
                            final tid = _selectedTournament!['id'] ??
                                _selectedTournament!['tournament_id'];
                            await _loadGroupsAndUmpiresForTournament(tid);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF264653),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Active Status Toggle
            _buildActiveToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
          maxLines: maxLines,
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
              borderSide: const BorderSide(color: Colors.blue, width: 2),
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

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
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
          validator: validator,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: const Color(0xFF34495E),
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
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
          iconEnabledColor: Colors.white,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isActive ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isActive ? Icons.check_circle : Icons.cancel,
            color: _isActive ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isActive
                      ? 'Court is active and available'
                      : 'Court is inactive',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CourtViewModel viewModel) {
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
                    widget.court != null ? 'Update' : 'Save',
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

  void _handleSubmit(CourtViewModel viewModel) {
    if (_formKey.currentState!.validate()) {
      final courtName = _courtNameController.text.trim();
      final description = _descriptionController.text.trim();
      final tournamentId = (_selectedTournament != null)
          ? (_selectedTournament!['id'] ??
              _selectedTournament!['tournament_id']) as int
          : null;
      final umpireId = _selectedUmpireId;
      final category = _selectedGroupName; // send group/category name

      if (widget.court != null) {
        // Update existing court
        viewModel
            .updateCourt(
          widget.court!.id!,
          courtName,
          description,
          _isActive,
          tournamentId: tournamentId,
          umpireId: umpireId,
          category: category,
        )
            .then((success) {
          if (success) {
            _showSuccessMessage('Court updated successfully!');
            Navigator.pop(context);
          } else {
            _showErrorMessage('Failed to update court: ${viewModel.error}');
          }
        });
      } else {
        // Add new court
        viewModel
            .addCourt(
          courtName,
          description,
          _isActive,
          tournamentId: tournamentId,
          umpireId: umpireId,
          category: category,
        )
            .then((success) {
          if (success) {
            _showSuccessMessage('Court added successfully!');
            Navigator.pop(context);
          } else {
            _showErrorMessage('Failed to add court: ${viewModel.error}');
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
