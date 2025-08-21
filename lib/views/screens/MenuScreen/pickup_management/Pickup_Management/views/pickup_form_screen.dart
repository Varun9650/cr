import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/pickup_management_viewmodel.dart';
import '../../../../../../resources/api_constants.dart';
import 'dart:io'; // Added for File
import 'dart:typed_data'; // Added for Uint8List

class PickupFormScreen extends StatefulWidget {
  const PickupFormScreen({Key? key}) : super(key: key);

  @override
  State<PickupFormScreen> createState() => _PickupFormScreenState();
}

class _PickupFormScreenState extends State<PickupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isMapLocationSelected = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Add Pickup Record',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PickupManagementProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserDropdown(provider),
                  SizedBox(height: 24),
                  _buildPickupAddressSection(provider),
                  SizedBox(height: 24),
                  _buildStatusSection(provider),
                  SizedBox(height: 24),
                  if (provider.paymentReceived)
                    _buildPaymentDetailsSection(provider),
                  SizedBox(height: 32),
                  _buildSubmitButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserDropdown(PickupManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select User *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: provider.selectedUser != null
                ? (provider.selectedUser!['id'] ??
                        provider.selectedUser!['userId'] ??
                        provider.selectedUser!['user_id'] ??
                        '')
                    .toString()
                : null,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            hint: Text('Choose a user'),
            items: provider.users.map((user) {
              final userId =
                  user['id'] ?? user['userId'] ?? user['user_id'] ?? 0;
              final userName = user['fullName'] ??
                  user['username'] ??
                  user['name'] ??
                  'Unknown User';

              // Check if there are duplicate names
              final duplicateCount = provider.users.where((u) {
                final otherName = u['fullName'] ??
                    u['username'] ??
                    u['name'] ??
                    'Unknown User';
                return otherName == userName;
              }).length;

              // If there are duplicates, show ID with the name
              final displayName =
                  duplicateCount > 1 ? '$userName (ID: $userId)' : userName;

              return DropdownMenuItem<String>(
                value: userId.toString(),
                child: Text(displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final selectedUser = provider.users.firstWhere(
                  (user) =>
                      (user['id'] ?? user['userId'] ?? user['user_id'] ?? '')
                          .toString() ==
                      value,
                );
                provider.setSelectedUser(selectedUser);
              } else {
                provider.setSelectedUser(null);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a user';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPickupAddressSection(PickupManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showMapPicker(provider),
                icon: Icon(Icons.map, color: Colors.white),
                label: Text('Choose from Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showManualAddressDialog(provider),
                icon: Icon(Icons.edit_location, color: Colors.white),
                label: Text('Manual Entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (provider.pickupAddress != null) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.pickupAddress!,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                if (_isMapLocationSelected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Map',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSection(PickupManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        _buildStatusToggle(
            'Pickup Completed',
            provider.pickUp,
            (value) => provider.togglePickupStatus(value),
            Icons.local_shipping),
        SizedBox(height: 8),
        _buildStatusToggle('Payment Completed', provider.paymentReceived,
            (value) => _handlePaymentToggle(provider, value), Icons.payment),
        SizedBox(height: 8),
        _buildStatusToggle(
            'Certificate Received',
            provider.certificate,
            (value) => provider.toggleCertificateStatus(value),
            Icons.description),
        SizedBox(height: 8),
        _buildStatusToggle('T-Shirt Received', provider.tshirtReceived,
            (value) => provider.toggleTshirtStatus(value), Icons.checkroom),
      ],
    );
  }

  Widget _buildStatusToggle(
      String title, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? Colors.green.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? Colors.green : Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value ? Colors.green[700] : Colors.grey[700],
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsSection(PickupManagementProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (provider.modeOfPayment.isNotEmpty) ...[
            _buildPaymentDetailRow('Mode of Payment', provider.modeOfPayment),
            SizedBox(height: 8),
          ],
          if (provider.transactionId.isNotEmpty) ...[
            _buildPaymentDetailRow('Transaction ID', provider.transactionId),
            SizedBox(height: 8),
          ],
          if (provider.paymentScreenshots.isNotEmpty) ...[
            Text(
              'Screenshots (${provider.paymentScreenshots.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.paymentScreenshots.length,
                itemBuilder: (context, index) {
                  final screenshot = provider.paymentScreenshots[index];
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: screenshot['temp_file'] != null
                          ? Image.memory(
                              screenshot['imageBytes'] ?? Uint8List(0),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              '${ApiConstants.baseUrl}${screenshot['uploadedfile_path']}/${screenshot['uploadedfile_name']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image,
                                      color: Colors.grey[400]),
                                );
                              },
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(PickupManagementProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => _submitForm(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: provider.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Pickup Record',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _showMapPicker(PickupManagementProvider provider) {
    // TODO: Implement map picker
    // For now, we'll simulate map selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Map Picker'),
        content: Text('Map picker functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Simulate map selection
              provider.setPickupLocation(
                '123 Main Street, City, State 12345',
                40.7128,
                -74.0060,
              );
              _isMapLocationSelected = true;
              Navigator.pop(context);
            },
            child: Text('Select'),
          ),
        ],
      ),
    );
  }

  void _showManualAddressDialog(PickupManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Address'),
        content: TextField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter pickup address',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_addressController.text.isNotEmpty) {
                provider.setPickupAddress(_addressController.text);
                _isMapLocationSelected = false;
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentToggle(PickupManagementProvider provider, bool value) {
    if (value) {
      // Show payment details dialog when turning on
      _showPaymentDetailsDialog(provider);
    } else {
      // Turn off payment directly
      provider.togglePaymentStatus(false);
    }
  }

  void _showPaymentDetailsDialog(PickupManagementProvider provider) {
    final TextEditingController transactionController = TextEditingController(
      text: provider.transactionId,
    );

    String selectedPaymentMode =
        provider.modeOfPayment.isNotEmpty ? provider.modeOfPayment : 'Cash';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Payment Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode of Payment Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMode,
                      decoration: InputDecoration(
                        labelText: 'Mode of Payment *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Cash',
                        'Card',
                        'UPI',
                        'Net Banking',
                        'Wallet',
                        'Other'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPaymentMode = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Transaction ID
                    TextField(
                      controller: transactionController,
                      decoration: InputDecoration(
                        labelText: 'Transaction ID',
                        hintText: 'Enter transaction ID (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Screenshot Upload Section
                    Text(
                      'Payment Screenshot',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(provider, ImageSource.gallery),
                            icon: Icon(Icons.photo_library, size: 16),
                            label: Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(provider, ImageSource.camera),
                            icon: Icon(Icons.camera_alt, size: 16),
                            label: Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Show uploaded screenshots
                    if (provider.paymentScreenshots.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        'Uploaded Screenshots:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.paymentScreenshots.length,
                          itemBuilder: (context, index) {
                            final screenshot =
                                provider.paymentScreenshots[index];
                            return Container(
                              margin: EdgeInsets.only(right: 8),
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${ApiConstants.baseUrl}${screenshot['uploadedfile_path']}/${screenshot['uploadedfile_name']}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image,
                                          color: Colors.grey[400]),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Turn off payment if dialog is cancelled
                    provider.togglePaymentStatus(false);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Save payment details
                    provider.setModeOfPayment(selectedPaymentMode);
                    provider
                        .setTransactionId(transactionController.text.trim());
                    provider.togglePaymentStatus(true);
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pickImage(PickupManagementProvider provider, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        // Read image as bytes for preview
        final imageBytes = await image.readAsBytes();

        // For new records, we'll store the image temporarily for preview
        // and upload it after the record is created
        provider.addPaymentScreenshot({
          'temp_file': image,
          'temp_name': image.name,
          'temp_path': image.path,
          'imageBytes': imageBytes, // Add bytes for preview
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot added for preview!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add screenshot: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitForm(PickupManagementProvider provider) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Store temporary screenshots before clearing form
        final tempScreenshots =
            List<Map<String, dynamic>>.from(provider.paymentScreenshots);

        // Create the record first and get the created record ID
        final createdRecordId = await provider.createEntity();

        if (createdRecordId != null && tempScreenshots.isNotEmpty) {
          // Upload screenshots using the created record ID
          for (final screenshot in tempScreenshots) {
            if (screenshot['temp_file'] != null) {
              try {
                // Convert XFile to File
                final xFile = screenshot['temp_file'] as XFile;
                final file = File(xFile.path);
                await provider.uploadPaymentScreenshot(createdRecordId, file);
              } catch (e) {
                print('Failed to upload screenshot: $e');
                // Continue with other screenshots even if one fails
              }
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup record created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating pickup record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
