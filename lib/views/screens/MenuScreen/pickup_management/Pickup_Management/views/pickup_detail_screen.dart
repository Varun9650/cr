import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/pickup_management_viewmodel.dart';
import '../../../../../../resources/api_constants.dart';
import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List

class PickupDetailScreen extends StatefulWidget {
  final Map<String, dynamic> entity;

  const PickupDetailScreen({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  State<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends State<PickupDetailScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Pickup Details',
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
        actions: [
          Consumer<PickupManagementProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges(provider);
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<PickupManagementProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                SizedBox(height: 24),
                _buildPickupAddress(),
                SizedBox(height: 24),
                _buildStatusSection(provider),
                SizedBox(height: 24),
                if (provider.paymentReceived)
                  _buildPaymentDetailsSection(provider),
                SizedBox(height: 24),
                _buildTimeline(),
                if (_isEditing) ...[
                  SizedBox(height: 32),
                  _buildSaveButton(provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo() {
    final userName = widget.entity['user_name'] ?? 'Unknown User';
    final userId = widget.entity['user_id'] ?? 'N/A';
    final createdAt = _parseDateTime(widget.entity['createdAt']);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'ID: $userId',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Created: ${_formatDate(createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupAddress() {
    return Consumer<PickupManagementProvider>(
      builder: (context, provider, child) {
        final pickupAddress = provider.pickupAddress ??
            widget.entity['pickupAddress']?.toString() ??
            'No address provided';
        final hasCoordinates =
            provider.pickupLatitude != null && provider.pickupLongitude != null;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Pickup Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (hasCoordinates) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Map Location',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  Spacer(),
                  if (_isEditing) ...[
                    TextButton.icon(
                      onPressed: () => _showAddressEditDialog(provider),
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12),
              Text(
                pickupAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              if (hasCoordinates) ...[
                SizedBox(height: 8),
                Text(
                  'Coordinates: ${provider.pickupLatitude ?? widget.entity['pickupLatitude']}, ${provider.pickupLongitude ?? widget.entity['pickupLongitude']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(PickupManagementProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
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
          SizedBox(height: 16),
          _buildStatusItem(
            'Pickup Completed',
            provider.pickUp,
            (value) => provider.togglePickupStatus(value),
            Icons.local_shipping,
            Colors.blue,
          ),
          SizedBox(height: 12),
          _buildStatusItem(
            'Payment Completed',
            provider.paymentReceived,
            (value) => _handlePaymentToggle(provider, value),
            Icons.payment,
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildStatusItem(
            'Certificate Received',
            provider.certificate,
            (value) => provider.toggleCertificateStatus(value),
            Icons.description,
            Colors.orange,
          ),
          SizedBox(height: 12),
          _buildStatusItem(
            'T-Shirt Received',
            provider.tshirtReceived,
            (value) => provider.toggleTshirtStatus(value),
            Icons.checkroom,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? color : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? color : Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value ? color : Colors.grey[700],
              ),
            ),
          ),
          if (_isEditing)
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
            )
          else
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              color: value ? color : Colors.grey[400],
              size: 20,
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
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.paymentScreenshots.length,
                itemBuilder: (context, index) {
                  final screenshot = provider.paymentScreenshots[index];
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 80,
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

  Widget _buildTimeline() {
    final createdAt = _parseDateTime(widget.entity['createdAt']);
    final updatedAt = widget.entity['updatedAt'] != null
        ? _parseDateTime(widget.entity['updatedAt'])
        : null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          _buildTimelineItem(
            'Record Created',
            _formatDateTime(createdAt),
            Icons.add_circle,
            Colors.green,
          ),
          if (updatedAt != null) ...[
            SizedBox(height: 12),
            _buildTimelineItem(
              'Last Updated',
              _formatDateTime(updatedAt),
              Icons.edit,
              Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(PickupManagementProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => _saveChanges(provider),
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
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _saveChanges(PickupManagementProvider provider) async {
    try {
      await provider.updateEntity(widget.entity['id']);
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else {
      return DateTime.now();
    }
  }

  void _showAddressEditDialog(PickupManagementProvider provider) {
    final TextEditingController addressController = TextEditingController(
      text: provider.pickupAddress ??
          widget.entity['pickupAddress']?.toString() ??
          '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Pickup Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showMapPicker(provider);
                      },
                      icon: Icon(Icons.map, size: 16),
                      label: Text('Choose from Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAddress = addressController.text.trim();
                if (newAddress.isNotEmpty) {
                  provider.setPickupAddress(newAddress);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
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
        // For existing records, upload immediately
        if (widget.entity['id'] != null) {
          // Convert XFile to File
          final file = File(image.path);
          await provider.uploadPaymentScreenshot(widget.entity['id'], file);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Screenshot uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // For new records (shouldn't happen in detail screen, but just in case)
          // Read image as bytes for preview
          final imageBytes = await image.readAsBytes();

          provider.addPaymentScreenshot({
            'temp_file': image,
            'temp_name': image.name,
            'temp_path': image.path,
            'imageBytes': imageBytes, // Add bytes for preview
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Screenshot added for preview!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload screenshot: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMapPicker(PickupManagementProvider provider) {
    // For now, we'll show a simple dialog to simulate map selection
    // In a real implementation, you would integrate with a map service
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Map Location Selection'),
          content: Text(
              'Map integration would go here. For now, you can manually enter coordinates.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Simulate setting coordinates
                provider.setPickupLocation(
                    'Selected from Map', 28.6139, 77.2090); // Delhi coordinates
                Navigator.pop(context);
              },
              child: Text('Select Location'),
            ),
          ],
        );
      },
    );
  }
}
