// ignore_for_file: use_build_context_synchronously
import 'package:cricyard/Entity/matches/Match/viewmodel/Match_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Entity/BadmintonCourt/models/court_model.dart';
import '../../../../Entity/UmpireManagement/models/umpire_model.dart';

class MatchUpdateEntityScreen extends StatefulWidget {
  final Map<String, dynamic> entity;

  const MatchUpdateEntityScreen({Key? key, required this.entity})
      : super(key: key);

  @override
  _MatchUpdateEntityScreenState createState() =>
      _MatchUpdateEntityScreenState();
}

class _MatchUpdateEntityScreenState extends State<MatchUpdateEntityScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDateTime = DateTime.now();
  bool _isActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTeams();
  }

  void _initializeControllers() {
    // Handle null values safely
    _locationController.text = widget.entity['location']?.toString() ?? '';

    // Set match name from team names if available, otherwise use existing name
    final team1Name = widget.entity['team_1_name']?.toString() ?? '';
    final team2Name = widget.entity['team_2_name']?.toString() ?? '';
    final existingName = widget.entity['name']?.toString() ?? '';

    if (team1Name.isNotEmpty && team2Name.isNotEmpty) {
      _nameController.text = '$team1Name vs $team2Name';
    } else {
      _nameController.text = existingName;
    }

    _descriptionController.text =
        widget.entity['description']?.toString() ?? '';

    // Handle date parsing safely
    try {
      if (widget.entity['datetime_field'] != null) {
        _selectedDateTime =
            DateTime.parse(widget.entity['datetime_field'].toString());
        _selectedDate = DateTime(_selectedDateTime.year,
            _selectedDateTime.month, _selectedDateTime.day);
      }
    } catch (e) {
      print('Error parsing date: $e');
      _selectedDateTime = DateTime.now();
      _selectedDate = DateTime.now();
    }

    // Handle boolean safely
    _isActive = widget.entity['isactive'] == true;
  }

  void _initializeTeams() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MatchProvider>(context, listen: false);

      // Check if we have tournament_id and match_category in the entity
      final tournamentId = widget.entity['tournament_id'];
      final matchCategory = widget.entity['match_category'];

      if (tournamentId != null && matchCategory != null) {
        provider.loadTeamsByTourAndGroup(tournamentId, matchCategory);

        // Set initial team selections using the correct field names
        final team1Id = widget.entity['team_1_id']?.toString() ?? '';
        final team2Id = widget.entity['team_2_id']?.toString() ?? '';
        final team1Name = widget.entity['team_1_name']?.toString() ?? '';
        final team2Name = widget.entity['team_2_name']?.toString() ?? '';

        if (team1Name.isNotEmpty) {
          provider.setTeam1(team1Id, team1Name);
        }
        if (team2Name.isNotEmpty) {
          provider.setTeam2(team2Id, team2Name);
        }

        // Update match name after teams are set
        _updateMatchName(provider);
        // Load courts and umpires
        provider.loadCourts();
        provider.loadUmpiresByTournamentId(tournamentId);

        // Set initial court and umpire selections
        final courtId = widget.entity['court_id']?.toString() ?? '';
        final courtName = widget.entity['court_name']?.toString() ?? '';
        final umpireId = widget.entity['umpire_id']?.toString() ?? '';
        final umpireName = widget.entity['umpire_name']?.toString() ?? '';

        if (courtName.isNotEmpty) {
          provider.setCourt(courtId, courtName);
        }
        if (umpireName.isNotEmpty) {
          provider.setUmpire(umpireId, umpireName);
        }
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Update datetime to maintain time
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedDate = DateTime(picked.year, picked.month, picked.day);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF219ebc),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Update Match',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: matchProvider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildTeamSection(),
                  const SizedBox(height: 24),
                  _buildCourtSection(),
                  const SizedBox(height: 24),
                  _buildUmpireSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildDateTimeSection(),
                  const SizedBox(height: 24),
                  _buildDetailsSection(),
                  const SizedBox(height: 24),
                  _buildActiveToggle(),
                  const SizedBox(height: 32),
                  _buildUpdateButton(matchProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF219ebc), Color(0xFF023e8a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF219ebc).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.sports_cricket, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Details',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update match information',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teams',
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTeamDropdown(
                    label: 'Team 1',
                    selectedTeamName: provider.selectedTeam1Name,
                    onTap: () => _showTeamSelectionDialog(context, provider, 1),
                    color: const Color(0xFF219ebc),
                    validator: () {
                      if (provider.selectedTeam1Name.isEmpty) {
                        return 'Team 1 is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTeamDropdown(
                    label: 'Team 2',
                    selectedTeamName: provider.selectedTeam2Name,
                    onTap: () => _showTeamSelectionDialog(context, provider, 2),
                    color: const Color(0xFF023e8a),
                    validator: () {
                      if (provider.selectedTeam2Name.isEmpty) {
                        return 'Team 2 is required';
                      }
                      if (provider.selectedTeam1Name ==
                              provider.selectedTeam2Name &&
                          provider.selectedTeam1Name.isNotEmpty) {
                        return 'Team 1 and Team 2 cannot be the same';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _locationController,
          label: 'Match Location',
          hint: 'Enter match location',
          icon: Icons.location_on,
          color: const Color(0xFF28a745),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Location is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCourtSection() {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Court',
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 16),
            _buildCourtDropdown(
              label: 'Court',
              selectedCourtName: provider.selectedCourtName,
              onTap: () => _showCourtSelectionDialog(context, provider),
              color: const Color(0xFFffc107),
              validator: () {
                if (provider.selectedCourtName.isEmpty) {
                  return 'Court is required';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUmpireSection() {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Umpire',
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 16),
            _buildUmpireDropdown(
              label: 'Umpire',
              selectedUmpireName: provider.selectedUmpireName,
              onTap: () => _showUmpireSelectionDialog(context, provider),
              color: const Color(0xFFdc3545),
              validator: () {
                if (provider.selectedUmpireName.isEmpty) {
                  return 'Umpire is required';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Date',
                value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                onTap: () => _selectDate(context),
                icon: Icons.calendar_today,
                color: const Color(0xFFffc107),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Time',
                value: DateFormat('HH:mm').format(_selectedDateTime),
                onTap: () => _selectDateTime(context),
                icon: Icons.access_time,
                color: const Color(0xFFdc3545),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Details',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _nameController,
          label: 'Match Name',
          hint: 'Enter match name',
          icon: Icons.sports_cricket,
          color: const Color(0xFF6f42c1),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Match name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter match description',
          icon: Icons.description,
          color: const Color(0xFFfd7e14),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF28a745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.toggle_on, color: const Color(0xFF28a745), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Status',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A)),
                ),
                Text(
                  _isActive ? 'Match is active' : 'Match is inactive',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 14,
                      color: _isActive ? Colors.green : Colors.grey),
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
            activeColor: const Color(0xFF28a745),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtDropdown({
    required String label,
    required String selectedCourtName,
    required VoidCallback onTap,
    required Color color,
    required String? Function() validator,
  }) {
    final errorMessage = validator();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorMessage != null
                ? Colors.red
                : Colors.grey.withOpacity(0.2),
            width: errorMessage != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.sports_volleyball, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    selectedCourtName.isNotEmpty
                        ? selectedCourtName
                        : 'Select $label',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selectedCourtName.isNotEmpty
                            ? const Color(0xFF1A1A1A)
                            : Colors.grey),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      errorMessage,
                      style: GoogleFonts.getFont('Poppins',
                          fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUmpireDropdown({
    required String label,
    required String selectedUmpireName,
    required VoidCallback onTap,
    required Color color,
    required String? Function() validator,
  }) {
    final errorMessage = validator();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorMessage != null
                ? Colors.red
                : Colors.grey.withOpacity(0.2),
            width: errorMessage != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    selectedUmpireName.isNotEmpty
                        ? selectedUmpireName
                        : 'Select $label',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selectedUmpireName.isNotEmpty
                            ? const Color(0xFF1A1A1A)
                            : Colors.grey),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      errorMessage,
                      style: GoogleFonts.getFont('Poppins',
                          fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamDropdown({
    required String label,
    required String selectedTeamName,
    required VoidCallback onTap,
    required Color color,
    required String? Function() validator,
  }) {
    final errorMessage = validator();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorMessage != null
                ? Colors.red
                : Colors.grey.withOpacity(0.2),
            width: errorMessage != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.group, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    selectedTeamName.isNotEmpty
                        ? selectedTeamName
                        : 'Select $label',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selectedTeamName.isNotEmpty
                            ? const Color(0xFF1A1A1A)
                            : Colors.grey),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      errorMessage,
                      style: GoogleFonts.getFont('Poppins',
                          fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamSelectionDialog(
      BuildContext context, MatchProvider provider, int teamNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Team $teamNumber"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Debug info
              if (provider.teams.isEmpty)
                const Text('No teams available',
                    style: TextStyle(color: Colors.red))
              else
                Text('Available teams: ${provider.teams.length}'),

              // Team list
              ...provider.teams.where((team) {
                if (teamNumber == 1) {
                  return team['team_name'] != provider.selectedTeam2Name;
                } else {
                  return team['team_name'] != provider.selectedTeam1Name;
                }
              }).map((team) {
                return ListTile(
                  title: Text(team['team_name']?.toString() ?? 'Unknown Team'),
                  subtitle: Text('ID: ${team['team_id']?.toString() ?? 'N/A'}'),
                  onTap: () {
                    if (teamNumber == 1) {
                      provider.setTeam1(
                        team['team_id']?.toString() ?? '',
                        team['team_name']?.toString() ?? '',
                      );
                    } else {
                      provider.setTeam2(
                        team['team_id']?.toString() ?? '',
                        team['team_name']?.toString() ?? '',
                      );
                    }

                    // Update match name automatically
                    _updateMatchName(provider);

                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _updateMatchName(MatchProvider provider) {
    final team1Name = provider.selectedTeam1Name;
    final team2Name = provider.selectedTeam2Name;

    if (team1Name.isNotEmpty && team2Name.isNotEmpty) {
      _nameController.text = '$team1Name vs $team2Name';
    } else if (team1Name.isNotEmpty) {
      _nameController.text = '$team1Name vs TBD';
    } else if (team2Name.isNotEmpty) {
      _nameController.text = 'TBD vs $team2Name';
    }
  }

  void _showCourtSelectionDialog(BuildContext context, MatchProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Court"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.courts.isEmpty)
                const Text('No courts available',
                    style: TextStyle(color: Colors.red))
              else
                Text('Available courts: ${provider.courts.length}'),
              ...provider.courts.map((court) {
                return ListTile(
                  title: Text(court.courtName),
                  subtitle: Text('ID: ${court.id}'),
                  onTap: () {
                    provider.setCourt(
                      court.id.toString(),
                      court.courtName,
                    );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showUmpireSelectionDialog(
      BuildContext context, MatchProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Umpire"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.umpires.isEmpty)
                const Text('No umpires available',
                    style: TextStyle(color: Colors.red))
              else
                Text('Available umpires: ${provider.umpires.length}'),
              ...provider.umpires.map((umpire) {
                return ListTile(
                  title: Text(umpire.userName ?? 'Unknown Umpire'),
                  subtitle: Text('ID: ${umpire.id}'),
                  onTap: () {
                    provider.setUmpire(
                      umpire.id.toString(),
                      umpire.userName ?? 'Unknown',
                    );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // bool _validateTeamSelection(MatchProvider provider) {

  bool _validateForm(MatchProvider provider) {
    if (provider.selectedTeam1Name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select Team 1',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    if (provider.selectedTeam2Name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select Team 2',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    if (provider.selectedTeam1Name == provider.selectedTeam2Name) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Team 1 and Team 2 cannot be the same',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    if (provider.selectedCourtName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a Court',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    if (provider.selectedUmpireName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an Umpire',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    return true;
  }

  Widget _buildUpdateButton(MatchProvider matchProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                if (matchProvider.formKey.currentState!.validate() &&
                    _validateForm(matchProvider)) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    // Validate that entity ID exists
                    if (widget.entity['id'] == null) {
                      throw Exception(
                          'Entity ID is missing. Cannot update match.');
                    }

                    // Update the entity with form data using correct field names
                    widget.entity['team_1_name'] =
                        matchProvider.selectedTeam1Name;
                    widget.entity['team_2_name'] =
                        matchProvider.selectedTeam2Name;

                    // Convert team IDs to integers, handle null values
                    final team1Id = matchProvider.selectedTeam1Id.isNotEmpty
                        ? int.tryParse(matchProvider.selectedTeam1Id)
                        : null;
                    final team2Id = matchProvider.selectedTeam2Id.isNotEmpty
                        ? int.tryParse(matchProvider.selectedTeam2Id)
                        : null;

                    widget.entity['team_1_id'] = team1Id;
                    widget.entity['team_2_id'] = team2Id;
                    widget.entity['location'] = _locationController.text.trim();
                    widget.entity['name'] = _nameController.text.trim();
                    widget.entity['description'] =
                        _descriptionController.text.trim();
                    widget.entity['datetime_field'] =
                        DateFormat('yyyy-MM-dd HH:mm')
                            .format(_selectedDateTime);
                    widget.entity['isactive'] = _isActive;

                    // Add court and umpire data
                    widget.entity['court_id'] =
                        matchProvider.selectedCourtId.isNotEmpty
                            ? int.tryParse(matchProvider.selectedCourtId)
                            : null;
                    widget.entity['court_name'] =
                        matchProvider.selectedCourtName;
                    widget.entity['umpire_id'] =
                        matchProvider.selectedUmpireId.isNotEmpty
                            ? int.tryParse(matchProvider.selectedUmpireId)
                            : null;
                    widget.entity['umpire_name'] =
                        matchProvider.selectedUmpireName;

                    // Get preferred sport from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    final preferredSport = prefs.getString('preferred_sport');
                    widget.entity['preferred_sport'] = preferredSport;

                    // Ensure tournament_id is properly set
                    if (widget.entity['tournament_id'] == null) {
                      throw Exception(
                          'Tournament ID is missing. Cannot update match.');
                    }

                    // Debug logging
                    print('Updating entity with data: ${widget.entity}');

                    await matchProvider.updateEntity(widget.entity);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Match updated successfully!',
                            style: GoogleFonts.getFont('Poppins',
                                fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print('error got $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update match: $e',
                            style: GoogleFonts.getFont('Poppins',
                                fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF219ebc),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF219ebc).withOpacity(0.3),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Updating...",
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              )
            : Text(
                "Update Match",
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
      ),
    );
  }
}
