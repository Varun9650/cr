// ignore_for_file: use_build_context_synchronously

// MVVM Structure: View only - No direct API calls
// All API calls are handled through Repository -> ViewModel -> View
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/image_constant.dart';
import '../../../../Utils/size_utils.dart';
import '../../../../views/screens/ReuseableWidgets/BottomAppBarWidget.dart';
import '../../../../views/widgets/custom_button.dart';
import '../../../../views/widgets/custom_icon_button.dart';
import '../../../../views/widgets/custom_image_view.dart';
import '../../../../views/widgets/custom_text_form_field.dart';
import '../viewmodel/My_Tournament_viewmodel.dart';

class MyTournamentUpdateEntityScreen extends StatefulWidget {
  final Map<String, dynamic> entity;

  const MyTournamentUpdateEntityScreen({required this.entity});

  @override
  _MyTournamentUpdateEntityScreenState createState() =>
      _MyTournamentUpdateEntityScreenState();
}

class _MyTournamentUpdateEntityScreenState
    extends State<MyTournamentUpdateEntityScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<MyTournamentProvider>(context, listen: false);
      provider.fetchtournament_nameItems();
      // Initialize form data with entity values
      _initializeFormData();
    });
  }

  void _initializeFormData() {
    formData['description'] = widget.entity['description'] ?? '';
    formData['rules'] = widget.entity['rules'] ?? '';
    formData['venues'] = widget.entity['venues'] ?? '';
    formData['dates'] = widget.entity['dates'] ?? '';
    formData['sponsors'] = widget.entity['sponsors'] ?? '';
    formData['tournament_name'] = widget.entity['tournament_name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTournamentProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 9, bottom: 6),
                  child: CustomIconButton(
                    height: 32,
                    width: 32,
                    decoration: IconButtonStyleHelper.outlineIndigo,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CustomImageView(
                      svgPath: ImageConstant.imgArrowleft,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    "Update Tournament",
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description field
                    _buildFieldSection(
                      "Description",
                      "Enter Description",
                      widget.entity['description'] ?? '',
                      (value) => formData['description'] = value,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 16),

                    // Rules field
                    _buildFieldSection(
                      "Rules",
                      "Enter Rules",
                      widget.entity['rules'] ?? '',
                      (value) => formData['rules'] = value,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 16),

                    // Venues field
                    _buildFieldSection(
                      "Venues",
                      "Please Enter Venues",
                      widget.entity['venues'] ?? '',
                      (value) => formData['venues'] = value,
                    ),

                    const SizedBox(height: 16),

                    // Dates field
                    _buildDateField(provider),

                    const SizedBox(height: 16),

                    // Sponsors field
                    _buildFieldSection(
                      "Sponsors",
                      "Please Enter Sponsors",
                      widget.entity['sponsors'] ?? '',
                      (value) => formData['sponsors'] = value,
                    ),

                    const SizedBox(height: 16),

                    // Tournament Name dropdown
                    _buildTournamentNameDropdown(provider),

                    const SizedBox(height: 24),

                    // Update button
                    _buildUpdateButton(provider),
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

  Widget _buildFieldSection(
    String label,
    String hintText,
    String initialValue,
    Function(String?) onSaved, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.getFont('Poppins',
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          hintText: hintText,
          initialValue: initialValue,
          maxLines: maxLines,
          onsaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDateField(MyTournamentProvider provider) {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateTime.parse(widget.entity['dates'] ?? '');
    } catch (e) {
      // Use current date if parsing fails
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dates",
          style: GoogleFonts.getFont('Poppins',
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(initialDate),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    provider.setSelectedDate(picked);
                    formData['dates'] = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
                onsaved: (value) => formData['dates'] = value,
              ),
            ),
            IconButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  provider.setSelectedDate(picked);
                  formData['dates'] = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
              icon: const Icon(Icons.calendar_today),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTournamentNameDropdown(MyTournamentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tournament Name",
          style: GoogleFonts.getFont('Poppins',
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Tournament Name',
            ),
            value: formData['tournament_name']?.isNotEmpty == true
                ? formData['tournament_name']
                : null,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Select Tournament Name'),
              ),
              ...provider.tournamentNameItems.map((item) {
                return DropdownMenuItem<String>(
                  value: item['tournament_name']?.toString() ?? '',
                  child: Text(item['tournament_name']?.toString() ?? ''),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                formData['tournament_name'] = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a Tournament Name';
              }
              return null;
            },
            onSaved: (value) {
              formData['tournament_name'] = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(MyTournamentProvider provider) {
    return Center(
      child: CustomButton(
        height: getVerticalSize(50),
        text: "Update",
        margin: getMargin(top: 24, bottom: 5),
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            try {
              await provider.updateTournamentEntity(
                widget.entity['id'],
                formData,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            } catch (e) {
              if (mounted) {
                _showErrorDialog(context, 'Failed to update tournament: $e');
              }
            }
          }
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
