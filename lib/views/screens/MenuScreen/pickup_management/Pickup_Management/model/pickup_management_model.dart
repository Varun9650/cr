import 'package:flutter/material.dart';

class PickupManagementModel {
  List<Map<String, dynamic>> entities = [];
  List<Map<String, dynamic>> filteredEntities = [];
  List<Map<String, dynamic>> searchEntities = [];
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedUser;

  bool isLoading = false;
  bool showCardView = true;
  int currentPage = 0;
  int pageSize = 10;

  // Form data
  Map<String, dynamic> formData = {};
  TextEditingController searchController = TextEditingController();

  // Pickup specific fields
  String? pickupAddress;
  double? pickupLatitude;
  double? pickupLongitude;
  bool isMapLocationSelected = false;

  // Status fields (matching table fields)
  bool pickUp = false; // pick_up field
  bool tshirtReceived = false; // tshirt_received field
  bool certificate = false; // certificate field
  bool paymentReceived = false; // payment_received field

  // Payment details
  String modeOfPayment = ''; // modeofpayment field
  String transactionId = ''; // transcation_id field
  List<Map<String, dynamic>> paymentScreenshots =
      []; // payment_screenshots field

  // Getters
  bool get getIsLoading => isLoading;
  bool get getShowCardView => showCardView;
  int get getCurrentPage => currentPage;
  int get getPageSize => pageSize;

  List<Map<String, dynamic>> get getEntities => entities;
  List<Map<String, dynamic>> get getFilteredEntities => filteredEntities;
  List<Map<String, dynamic>> get getSearchEntities => searchEntities;
  List<Map<String, dynamic>> get getUsers => users;
  Map<String, dynamic>? get getSelectedUser => selectedUser;

  Map<String, dynamic> get getFormData => formData;
  String? get getPickupAddress => pickupAddress;
  double? get getPickupLatitude => pickupLatitude;
  double? get getPickupLongitude => pickupLongitude;
  bool get getIsMapLocationSelected => isMapLocationSelected;

  bool get getPickUp => pickUp;
  bool get getTshirtReceived => tshirtReceived;
  bool get getCertificate => certificate;
  bool get getPaymentReceived => paymentReceived;

  // Payment detail getters
  String get getModeOfPayment => modeOfPayment;
  String get getTransactionId => transactionId;
  List<Map<String, dynamic>> get getPaymentScreenshots => paymentScreenshots;

  // Setters
  set setIsLoading(bool value) {
    isLoading = value;
  }

  set setShowCardView(bool value) {
    showCardView = value;
  }

  set setCurrentPage(int value) {
    currentPage = value;
  }

  set setPageSize(int value) {
    pageSize = value;
  }

  set setEntities(List<Map<String, dynamic>> value) {
    entities = value;
  }

  set setFilteredEntities(List<Map<String, dynamic>> value) {
    filteredEntities = value;
  }

  set setSearchEntities(List<Map<String, dynamic>> value) {
    searchEntities = value;
  }

  set setUsers(List<Map<String, dynamic>> value) {
    users = value;
  }

  set setSelectedUser(Map<String, dynamic>? value) {
    selectedUser = value;
  }

  set setFormData(Map<String, dynamic> value) {
    formData = value;
  }

  set setPickupAddress(String? value) {
    pickupAddress = value;
  }

  set setPickupLatitude(double? value) {
    pickupLatitude = value;
  }

  set setPickupLongitude(double? value) {
    pickupLongitude = value;
  }

  set setIsMapLocationSelected(bool value) {
    isMapLocationSelected = value;
  }

  set setPickUp(bool value) {
    pickUp = value;
  }

  set setPaymentReceived(bool value) {
    paymentReceived = value;
  }

  set setCertificate(bool value) {
    certificate = value;
  }

  set setTshirtReceived(bool value) {
    tshirtReceived = value;
  }

  // Payment detail setters
  set setModeOfPayment(String value) {
    modeOfPayment = value;
  }

  set setTransactionId(String value) {
    transactionId = value;
  }

  set setPaymentScreenshots(List<Map<String, dynamic>> value) {
    paymentScreenshots = value;
  }

  // Methods
  void updateFormField(String key, dynamic value) {
    formData[key] = value;
  }

  void clearFormData() {
    formData.clear();
    pickupAddress = null;
    pickupLatitude = null;
    pickupLongitude = null;
    isMapLocationSelected = false;
    pickUp = false;
    paymentReceived = false;
    certificate = false;
    tshirtReceived = false;
    modeOfPayment = '';
    transactionId = '';
    paymentScreenshots = [];
  }

  void setPickupLocation(String address, double lat, double lng) {
    pickupAddress = address;
    pickupLatitude = lat;
    pickupLongitude = lng;
    isMapLocationSelected = true;
  }
}
