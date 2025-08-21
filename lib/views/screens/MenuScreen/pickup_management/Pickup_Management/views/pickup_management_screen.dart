import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/pickup_management_viewmodel.dart';
import 'pickup_form_screen.dart';
import 'pickup_detail_screen.dart';

class PickupManagementScreen extends StatefulWidget {
  const PickupManagementScreen({Key? key}) : super(key: key);

  @override
  State<PickupManagementScreen> createState() => _PickupManagementScreenState();
}

class _PickupManagementScreenState extends State<PickupManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final provider =
        Provider.of<PickupManagementProvider>(context, listen: false);
    provider.filterEntities(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          'Pickup Management',
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
                  provider.showCardView ? Icons.list : Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () =>
                    provider.toggleCardView(!provider.showCardView),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCards(),
          Expanded(
            child: _buildPickupList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PickupFormScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by user name or address...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<PickupManagementProvider>(
      builder: (context, provider, child) {
        final totalPickups = provider.entities.length;
        final completedPickups =
            provider.entities.where((e) => e['pick_up'] == true).length;
        final pendingPayments = provider.entities
            .where((e) => e['payment_received'] == false)
            .length;
        final certificatesPending =
            provider.entities.where((e) => e['certificate'] == false).length;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalPickups.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedPickups.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending Payment',
                  pendingPayments.toString(),
                  Icons.payment,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Certificates',
                  certificatesPending.toString(),
                  Icons.description,
                  Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupList() {
    return Consumer<PickupManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.entities.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }

        if (provider.filteredEntities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No pickup records found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: provider.scrollController,
          padding: EdgeInsets.all(16),
          itemCount:
              provider.filteredEntities.length + (provider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.filteredEntities.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              );
            }

            final entity = provider.filteredEntities[index];
            return _buildPickupCard(entity, provider);
          },
        );
      },
    );
  }

  Widget _buildPickupCard(
      Map<String, dynamic> entity, PickupManagementProvider provider) {
    print('entity is $entity');
    final userName = entity['user_name'] ?? 'Unknown User';
    final pickupAddress = entity['pickupAddress'] ?? 'No address';
    final isPickupCompleted = entity['pick_up'] == true;
    final isPaymentCompleted = entity['payment_received'] == true;
    final isCertificateReceived = entity['certificate'] == true;
    final isTshirtReceived = entity['tshirt_received'] == true;
    final createdAt = _parseDateTime(entity['createdAt']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          provider.initializeEntity(entity);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PickupDetailScreen(entity: entity),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        Text(
                          'Created: ${_formatDate(createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIndicator(isPickupCompleted, isPaymentCompleted),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pickupAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildStatusRow(
                isPickupCompleted,
                isPaymentCompleted,
                isCertificateReceived,
                isTshirtReceived,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
      bool isPickupCompleted, bool isPaymentCompleted) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isPickupCompleted && isPaymentCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Completed';
    } else if (isPickupCompleted) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pending Payment';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.schedule;
      statusText = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: statusColor,
          ),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    bool isPickupCompleted,
    bool isPaymentCompleted,
    bool isCertificateReceived,
    bool isTshirtReceived,
  ) {
    return Row(
      children: [
        _buildStatusItem('Pickup', isPickupCompleted, Icons.local_shipping),
        SizedBox(width: 8),
        _buildStatusItem('Payment', isPaymentCompleted, Icons.payment),
        SizedBox(width: 8),
        _buildStatusItem(
            'Certificate', isCertificateReceived, Icons.description),
        SizedBox(width: 8),
        _buildStatusItem('T-Shirt', isTshirtReceived, Icons.checkroom),
      ],
    );
  }

  Widget _buildStatusItem(String label, bool isCompleted, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.green : Colors.grey[500],
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isCompleted ? Colors.green : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}
