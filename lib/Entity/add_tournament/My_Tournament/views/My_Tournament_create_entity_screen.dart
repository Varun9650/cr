// ignore_for_file: use_build_context_synchronously

// MVVM Structure: View only - No direct API calls
// All API calls are handled through Repository -> ViewModel -> View
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../views/screens/ReuseableWidgets/BottomAppBarWidget.dart';
import '../../../../views/widgets/custom_text_form_field.dart';
import '../viewmodel/My_Tournament_viewmodel.dart';

class MyTournamentCreateEntityScreen extends StatefulWidget {
  const MyTournamentCreateEntityScreen({super.key});

  @override
  _MyTournamentCreateEntityScreenState createState() =>
      _MyTournamentCreateEntityScreenState();
}

class _MyTournamentCreateEntityScreenState
    extends State<MyTournamentCreateEntityScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<MyTournamentProvider>(context, listen: false);
      provider.fetchtournament_nameItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTournamentProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: _buildAppBar(),
          body: _buildBody(provider),
          bottomNavigationBar: BottomAppBarWidget(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        "Create Tournament",
        style: GoogleFonts.getFont('Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A)),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(MyTournamentProvider provider) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 32),

                // Logo upload section
                _buildLogoUploadSection(provider),
                const SizedBox(height: 32),

                // Tournament name field
                _buildFieldSection(
                  "Tournament Name",
                  "Please Enter Tournament Name",
                  Icons.emoji_events,
                  (value) => formData['tournament_name'] = value,
                ),
                const SizedBox(height: 24),

                // Venues field
                _buildFieldSection(
                  "Venues",
                  "Please Enter Venues",
                  Icons.location_on,
                  (value) => formData['venues'] = value,
                ),
                const SizedBox(height: 24),

                // Sponsors field
                _buildFieldSection(
                  "Sponsors",
                  "Please Enter Sponsors",
                  Icons.business,
                  (value) => formData['sponsors'] = value,
                ),
                const SizedBox(height: 24),

                // Dates field
                _buildDateField(provider),
                const SizedBox(height: 24),

                // Description field
                _buildFieldSection(
                  "Description",
                  "Enter Description",
                  Icons.description,
                  (value) => formData['description'] = value,
                  maxLines: 5,
                ),
                const SizedBox(height: 24),

                // Rules field
                _buildFieldSection(
                  "Rules",
                  "Enter Rules",
                  Icons.rule,
                  (value) => formData['rules'] = value,
                  maxLines: 5,
                ),
                const SizedBox(height: 32),

                // Submit button
                _buildSubmitButton(provider),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tournament Details",
          style: GoogleFonts.getFont('Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Text(
          "Fill in the details below to create your tournament",
          style: GoogleFonts.getFont('Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildLogoUploadSection(MyTournamentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: const Color(0xFF219ebc), size: 24),
              const SizedBox(width: 12),
              Text(
                "Tournament Logo",
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Logo upload rows
          Column(
            children: List.generate(
              provider.selectedLogoImages.length,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.pickImage(
                          ImageSource.gallery,
                          provider.selectedLogoImages[index],
                        ),
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF219ebc),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.pickImage(
                          ImageSource.camera,
                          provider.selectedLogoImages[index],
                        ),
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28A745),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.white, size: 20),
                        onPressed: () =>
                            provider.removelogoImageUploadRow(index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Display selected images
          provider.selectedLogoImages.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFE9ECEF),
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 48, color: const Color(0xFFADB5BD)),
                      const SizedBox(height: 12),
                      Text(
                        'No Images Selected',
                        style: GoogleFonts.getFont('Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6C757D)),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.selectedLogoImages.length,
                    itemBuilder: (context, index) {
                      final image = provider.selectedLogoImages[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            image['imageBytes'] ?? Uint8List(0),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 16),

          // Add image button
          Center(
            child: ElevatedButton.icon(
              onPressed: provider.addlogoUploadRow,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: Text(
                'Add Image',
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F42C1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection(
    String label,
    String hintText,
    IconData icon,
    Function(String?) onSaved, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF219ebc), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: CustomTextFormField(
            hintText: hintText,
            maxLines: maxLines,
            onsaved: onSaved,
            hintStyle: GoogleFonts.getFont('Poppins',
                fontSize: 14, color: const Color(0xFFADB5BD)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(MyTournamentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today,
                color: const Color(0xFF219ebc), size: 20),
            const SizedBox(width: 8),
            Text(
              "Dates",
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: TextEditingController(
                    text: provider.selectedDate.toIso8601String().split('T')[0],
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: provider.selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF219ebc),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      provider.setSelectedDate(picked);
                    }
                  },
                  onsaved: (value) => formData['dates'] =
                      provider.selectedDate.toIso8601String(),
                  hintStyle: GoogleFonts.getFont('Poppins',
                      fontSize: 14, color: const Color(0xFFADB5BD)),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF219ebc),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: provider.selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF219ebc),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      provider.setSelectedDate(picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(MyTournamentProvider provider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF219ebc), Color(0xFF1E88E5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF219ebc).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  try {
                    await provider.createTournamentEntity(formData);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      _showErrorDialog(
                          context, 'Failed to create tournament: $e');
                    }
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: provider.isLoading
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
                    "Creating...",
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              )
            : Text(
                "Create Tournament",
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline,
                  color: const Color(0xFFDC3545), size: 24),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.getFont('Poppins',
                fontSize: 16, color: const Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF219ebc)),
              ),
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
