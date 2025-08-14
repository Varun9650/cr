import 'package:flutter/material.dart';
import '../model/pickup_management_model.dart';
import '../repository/pickup_management_api_service.dart';

class PickupManagementProvider with ChangeNotifier {
  final PickupManagementModel _model = PickupManagementModel();
  final PickupManagementApiService _apiService = PickupManagementApiService();
  final ScrollController scrollController = ScrollController();

  // Getters
  bool get isLoading => _model.getIsLoading;
  bool get showCardView => _model.getShowCardView;
  int get currentPage => _model.getCurrentPage;
  int get pageSize => _model.getPageSize;

  List<Map<String, dynamic>> get entities => _model.getEntities;
  List<Map<String, dynamic>> get filteredEntities => _model.getFilteredEntities;
  List<Map<String, dynamic>> get searchEntities => _model.getSearchEntities;
  List<Map<String, dynamic>> get users => _model.getUsers;
  Map<String, dynamic>? get selectedUser => _model.getSelectedUser;

  Map<String, dynamic> get formData => _model.getFormData;
  String? get pickupAddress => _model.getPickupAddress;
  double? get pickupLatitude => _model.getPickupLatitude;
  double? get pickupLongitude => _model.getPickupLongitude;
  bool get isMapLocationSelected => _model.getIsMapLocationSelected;

  bool get pickUp => _model.getPickUp;
  bool get paymentReceived => _model.getPaymentReceived;
  bool get certificate => _model.getCertificate;
  bool get tshirtReceived => _model.getTshirtReceived;

  // Payment detail getters
  String get modeOfPayment => _model.getModeOfPayment;
  String get transactionId => _model.getTransactionId;
  List<Map<String, dynamic>> get paymentScreenshots =>
      _model.getPaymentScreenshots;

  PickupManagementProvider() {
    scrollController.addListener(_scrollListener);
    fetchEntities();
    fetchUsers();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading) {
        fetchEntities();
      }
    }
  }

  void toggleCardView(bool value) {
    _model.setShowCardView = value;
    notifyListeners();
  }

  void setSelectedUser(Map<String, dynamic>? user) {
    _model.setSelectedUser = user;
    notifyListeners();
  }

  void updateFormField(String key, dynamic value) {
    _model.updateFormField(key, value);
    notifyListeners();
  }

  void setPickupLocation(String address, double lat, double lng) {
    _model.setPickupLocation(address, lat, lng);
    notifyListeners();
  }

  void setPickupAddress(String address) {
    _model.setPickupAddress = address;
    notifyListeners();
  }

  void togglePickupStatus(bool value) {
    _model.setPickUp = value;
    notifyListeners();
  }

  void togglePaymentStatus(bool value) {
    _model.setPaymentReceived = value;
    notifyListeners();
  }

  void toggleCertificateStatus(bool value) {
    _model.setCertificate = value;
    notifyListeners();
  }

  void toggleTshirtStatus(bool value) {
    _model.setTshirtReceived = value;
    notifyListeners();
  }

  // Payment detail methods
  void setModeOfPayment(String value) {
    _model.setModeOfPayment = value;
    notifyListeners();
  }

  void setTransactionId(String value) {
    _model.setTransactionId = value;
    notifyListeners();
  }

  void setPaymentScreenshots(List<Map<String, dynamic>> screenshots) {
    _model.setPaymentScreenshots = screenshots;
    notifyListeners();
  }

  void addPaymentScreenshot(Map<String, dynamic> screenshot) {
    final currentScreenshots =
        List<Map<String, dynamic>>.from(_model.getPaymentScreenshots);
    currentScreenshots.add(screenshot);
    _model.setPaymentScreenshots = currentScreenshots;
    notifyListeners();
  }

  // Upload document methods
  Future<void> uploadPaymentScreenshot(int entityId, dynamic file) async {
    try {
      final response = await _apiService.uploadDocument(
        entityId.toString(),
        'Participantlogistics',
        file,
      );

      // Add the uploaded screenshot to the list
      addPaymentScreenshot({
        'uploadedfile_name': response['uploadedfile_name'],
        'uploadedfile_path': response['uploadedfile_path'],
      });

      print('Screenshot uploaded successfully: $response');
    } catch (e) {
      throw Exception('Failed to upload screenshot: $e');
    }
  }

  Future<void> loadPaymentScreenshots(int entityId) async {
    try {
      final screenshots = await _apiService.getDocumentsByRef(
        entityId.toString(),
        'Participantlogistics',
      );

      _model.setPaymentScreenshots = screenshots;
      notifyListeners();
    } catch (e) {
      print('Failed to load screenshots: $e');
      // Don't throw error, just log it
    }
  }

  void clearFormData() {
    _model.clearFormData();
    notifyListeners();
  }

  Future<void> fetchEntities() async {
    try {
      _model.setIsLoading = true;
      notifyListeners();

      final fetchedEntities =
          await _apiService.getAllWithPagination(currentPage, pageSize);

      if (currentPage == 0) {
        _model.setEntities = fetchedEntities;
        _model.setFilteredEntities = fetchedEntities;
      } else {
        _model.setEntities = [...entities, ...fetchedEntities];
        _model.setFilteredEntities = [...filteredEntities, ...fetchedEntities];
      }

      _model.setCurrentPage = currentPage + 1;
    } catch (e) {
      throw Exception('Failed to fetch entities: $e');
    } finally {
      _model.setIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWithoutPaging() async {
    try {
      final fetchedEntities = await _apiService.getEntities();
      _model.setSearchEntities = fetchedEntities;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch entities without paging: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await _apiService.getUsers();
      print('Fetched users: $fetchedUsers');
      if (fetchedUsers.isNotEmpty) {
        print('First user structure: ${fetchedUsers.first}');
      }

      _model.setUsers = fetchedUsers;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<int?> createEntity() async {
    try {
      _model.setIsLoading = true;
      notifyListeners();

      if (selectedUser != null) {
        // Handle different possible field names for user ID
        final userId = selectedUser!['id'] ??
            selectedUser!['userId'] ??
            selectedUser!['user_id'];

        // Handle different possible field names for user name
        final userName = selectedUser!['fullName'] ?? selectedUser!['username'];

        formData['user_id'] = userId;
        formData['user_name'] = userName;

        print('Selected user data: $selectedUser');
        print('Extracted user_id: $userId, user_name: $userName');
      }

      if (isMapLocationSelected) {
        formData['pickupAddress'] = pickupAddress;
        formData['pickupLatitude'] = pickupLatitude;
        formData['pickupLongitude'] = pickupLongitude;
      }

      formData['pick_up'] = pickUp;
      formData['payment_received'] = paymentReceived;
      formData['certificate'] = certificate;
      formData['tshirt_received'] = tshirtReceived;

      // Add payment details if payment is completed
      if (paymentReceived) {
        formData['modeofpayment'] = modeOfPayment;
        formData['transcation_id'] = transactionId;
      }

      formData['createdAt'] = DateTime.now().toIso8601String();

      final response = await _apiService.createEntity(formData);

      // Extract the created record ID from response
      int? createdRecordId;
      if (response != null && response['id'] != null) {
        createdRecordId = response['id'] is int
            ? response['id']
            : int.tryParse(response['id'].toString());
      }

      // Refresh the list
      _model.setCurrentPage = 0;
      await fetchEntities();

      clearFormData();

      return createdRecordId;
    } catch (e) {
      throw Exception('Failed to create entity: $e');
    } finally {
      _model.setIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEntity(int entityId) async {
    try {
      _model.setIsLoading = true;
      notifyListeners();

      Map<String, dynamic> updateData = {
        'pick_up': pickUp,
        'payment_received': paymentReceived,
        'certificate': certificate,
        'tshirt_received': tshirtReceived,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add payment details if payment is completed
      if (paymentReceived) {
        updateData['modeofpayment'] = modeOfPayment;
        updateData['transcation_id'] = transactionId;
      }

      if (pickupAddress != null) {
        updateData['pickupAddress'] = pickupAddress;
        updateData['pickupLatitude'] = pickupLatitude;
        updateData['pickupLongitude'] = pickupLongitude;
      }

      await _apiService.updateEntity(entityId, updateData);

      // Refresh the list
      _model.setCurrentPage = 0;
      await fetchEntities();

      clearFormData();
    } catch (e) {
      throw Exception('Failed to update entity: $e');
    } finally {
      _model.setIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntity(int entityId) async {
    try {
      await _apiService.deleteEntity(entityId);

      // Remove from local lists
      _model.setEntities = entities.where((e) => e['id'] != entityId).toList();
      _model.setFilteredEntities =
          filteredEntities.where((e) => e['id'] != entityId).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete entity: $e');
    }
  }

  Future<void> updatePickupStatus(
      int entityId, Map<String, dynamic> statusData) async {
    try {
      await _apiService.updatePickupStatus(entityId, statusData);

      // Update local entity
      final entityIndex = entities.indexWhere((e) => e['id'] == entityId);
      if (entityIndex != -1) {
        entities[entityIndex].addAll(statusData);
        _model.setEntities = List.from(entities);
        _model.setFilteredEntities = List.from(filteredEntities);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update pickup status: $e');
    }
  }

  void filterEntities(String query) {
    if (query.isEmpty) {
      _model.setFilteredEntities = entities;
    } else {
      final filtered = entities.where((entity) {
        final userName = entity['user_name']?.toString().toLowerCase() ?? '';
        final pickupAddress =
            entity['pickupAddress']?.toString().toLowerCase() ?? '';
        final queryLower = query.toLowerCase();

        return userName.contains(queryLower) ||
            pickupAddress.contains(queryLower);
      }).toList();

      _model.setFilteredEntities = filtered;
    }
    notifyListeners();
  }

  void initializeEntity(Map<String, dynamic> entity) {
    _model.setSelectedUser = {
      'id': entity['user_id'],
      'name': entity['user_name'],
    };
    _model.setPickupAddress = entity['pickupAddress'];
    _model.setPickupLatitude = entity['pickupLatitude']?.toDouble();
    _model.setPickupLongitude = entity['pickupLongitude']?.toDouble();
    _model.setIsMapLocationSelected = entity['pickupLatitude'] != null;
    _model.setPickUp = entity['pick_up'] ?? false;
    _model.setPaymentReceived = entity['payment_received'] ?? false;
    _model.setCertificate = entity['certificate'] ?? false;
    _model.setTshirtReceived = entity['tshirt_received'] ?? false;

    // Initialize payment details
    _model.setModeOfPayment = entity['modeofpayment']?.toString() ?? '';
    _model.setTransactionId = entity['transcation_id']?.toString() ?? '';

    // Copy entity data to form
    _model.setFormData = Map.from(entity);

    // Load payment screenshots if entity has ID
    if (entity['id'] != null) {
      loadPaymentScreenshots(entity['id']);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
