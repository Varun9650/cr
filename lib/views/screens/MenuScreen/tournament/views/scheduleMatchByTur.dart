// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../Utils/size_utils.dart';
import '../../../Login Screen/view/CustomButton.dart';
import '../../../ReuseableWidgets/BottomAppBarWidget.dart';
import '../viewmodel/schedule_match_view_model.dart';
import '../../../../../Entity/BadmintonCourt/models/court_model.dart';
import '../../../../../Entity/UmpireManagement/models/umpire_model.dart';

class ScheduleMatchByTur extends StatefulWidget {
  final int tourId;
  final String? groupName;

  const ScheduleMatchByTur({
    super.key,
    required this.tourId,
    this.groupName,
  });

  @override
  _ScheduleMatchByTurState createState() => _ScheduleMatchByTurState();
}

class _ScheduleMatchByTurState extends State<ScheduleMatchByTur> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateTimeController = TextEditingController();

  Future<void> _selectDateTime(
      BuildContext context, ScheduleMatchViewModel provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(provider.selectedDateTime),
      );
      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        provider.setDateTime(selectedDateTime);
        dateTimeController.text =
            DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ScheduleMatchViewModel>(context, listen: false);
      provider.initializeData(widget.tourId, groupName: widget.groupName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleMatchViewModel>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            forceMaterialTransparency: true,
            backgroundColor: Colors.grey[200],
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF219ebc),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            title: Text(
              widget.groupName != null
                  ? "Schedule Match - ${widget.groupName}"
                  : "Schedule Match",
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 20, color: Colors.black),
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Team 1 Selection
                          Hero(
                            tag: 'team1_selection',
                            child: IconButton(
                              iconSize: 60,
                              onPressed: () => _showTeamSelectionDialog(
                                  context, provider, 1),
                              icon: const Icon(Icons.add_circle),
                            ),
                          ),
                          Text(
                            provider.selectedTeam1Name.isNotEmpty
                                ? "Selected: ${provider.selectedTeam1Name}"
                                : "Select Team 1 *",
                            style: GoogleFonts.getFont('Poppins',
                                color: provider.selectedTeam1Name.isNotEmpty
                                    ? Colors.black
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight:
                                    provider.selectedTeam1Name.isNotEmpty
                                        ? FontWeight.normal
                                        : FontWeight.w600),
                          ),
                          const SizedBox(height: 20),

                          // Team 2 Selection
                          Hero(
                            tag: 'team2_selection',
                            child: IconButton(
                              iconSize: 60,
                              onPressed: () => _showTeamSelectionDialog(
                                  context, provider, 2),
                              icon: const Icon(Icons.add_circle),
                            ),
                          ),
                          Text(
                            provider.selectedTeam2Name.isNotEmpty
                                ? "Selected: ${provider.selectedTeam2Name}"
                                : "Select Team 2 *",
                            style: GoogleFonts.getFont('Poppins',
                                color: provider.selectedTeam2Name.isNotEmpty
                                    ? Colors.black
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight:
                                    provider.selectedTeam2Name.isNotEmpty
                                        ? FontWeight.normal
                                        : FontWeight.w600),
                          ),
                          const SizedBox(height: 20),

                          // Badminton Match Type Dropdown
                          if (provider.isBadmintonSport) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: provider.selectedBadmintonMatchType,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Match Type',
                                    style: GoogleFonts.getFont('Poppins',
                                        color: Colors.grey),
                                  ),
                                  items: provider.badmintonMatchTypes
                                      .map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: GoogleFonts.getFont('Poppins',
                                            color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      provider.setBadmintonMatchType(newValue);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Court Selection
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: provider.selectedCourtId.isNotEmpty
                                    ? provider.selectedCourtId
                                    : null,
                                isExpanded: true,
                                hint: Text(
                                  'Select Court *',
                                  style: GoogleFonts.getFont('Poppins',
                                      color: Colors.grey),
                                ),
                                items: provider.courts
                                    .cast<Court>()
                                    .map((Court court) {
                                  return DropdownMenuItem<String>(
                                    value: court.id.toString(),
                                    child: Text(
                                      court.courtName,
                                      style: GoogleFonts.getFont('Poppins',
                                          color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    final court = provider.courts
                                        .cast<Court>()
                                        .firstWhere(
                                            (c) => c.id.toString() == newValue);
                                    provider.setCourt(
                                        newValue, court.courtName);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Umpire Selection
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: provider.selectedUmpireId.isNotEmpty
                                    ? provider.selectedUmpireId
                                    : null,
                                isExpanded: true,
                                hint: Text(
                                  'Select Umpire *',
                                  style: GoogleFonts.getFont('Poppins',
                                      color: Colors.grey),
                                ),
                                items: provider.umpires
                                    .cast<Umpire>()
                                    .map((Umpire umpire) {
                                  return DropdownMenuItem<String>(
                                    value: umpire.id.toString(),
                                    child: Text(
                                      umpire.userName ?? 'Unknown',
                                      style: GoogleFonts.getFont('Poppins',
                                          color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    final umpire = provider.umpires
                                        .cast<Umpire>()
                                        .firstWhere(
                                            (u) => u.id.toString() == newValue);
                                    provider.setUmpire(
                                      newValue,
                                      umpire.userName ?? 'Unknown',
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Location Field
                          Padding(
                            padding: getPadding(top: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextFormField(
                                  focusNode: FocusNode(),
                                  decoration: InputDecoration(
                                    labelText: 'Location *',
                                    hintText: "Enter location",
                                    labelStyle: TextStyle(
                                      color: provider.errorMessage
                                                  ?.contains('Location') ==
                                              true
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                  ),
                                  onSaved: (value) =>
                                      provider.setLocation(value ?? ''),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Date Time Field
                          TextFormField(
                            controller: dateTimeController,
                            decoration: InputDecoration(
                              labelText: 'Date And Time *',
                              suffixIcon: const Icon(Icons.calendar_today),
                              labelStyle: TextStyle(
                                color: dateTimeController.text.isEmpty
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFC0FE53), width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                            ),
                            readOnly: true,
                            onTap: () => _selectDateTime(context, provider),
                          ),

                          const SizedBox(height: 16),

                          // Description Field
                          TextFormField(
                            focusNode: FocusNode(),
                            decoration: InputDecoration(
                              labelText: 'Description *',
                              hintText: "Enter Description",
                              labelStyle: TextStyle(
                                color: provider.errorMessage
                                            ?.contains('Description') ==
                                        true
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                            ),
                            onSaved: (value) =>
                                provider.setDescription(value ?? ''),
                            style: const TextStyle(color: Colors.black),
                          ),

                          const SizedBox(height: 16),

                          // Active Switch
                          Row(
                            children: [
                              Switch(
                                value: provider.isActive,
                                onChanged: (newValue) =>
                                    provider.setActive(newValue),
                              ),
                              const SizedBox(width: 8),
                              const Text('Active',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Submit Button
                          CustomButton(
                            color: const Color(0xFF264653),
                            height: getVerticalSize(50),
                            text: provider.isSubmitting
                                ? "Creating..."
                                : "Submit",
                            onTap: provider.isSubmitting
                                ? null
                                : () => _handleSubmit(context, provider),
                          ),

                          // Error/Success Messages
                          if (provider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                provider.errorMessage!,
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ),
                          ],

                          if (provider.successMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                provider.successMessage!,
                                style: GoogleFonts.poppins(color: Colors.green),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
          bottomNavigationBar: BottomAppBarWidget(),
        );
      },
    );
  }

  void _showTeamSelectionDialog(
      BuildContext context, ScheduleMatchViewModel provider, int teamNumber) {
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

  Future<void> _handleSubmit(
      BuildContext context, ScheduleMatchViewModel provider) async {
    _formKey.currentState!.save();

    final success = await provider.createMatch();

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Match scheduled successfully!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      Navigator.pop(context);
    } else if (!success && mounted) {
      // Show error message
      final errorMsg = provider.errorMessage ?? 'Failed to schedule match.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
