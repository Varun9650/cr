// MVVM Structure: ViewModel - Business Logic and State Management
// All API calls are handled through Repository -> ViewModel -> View
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../repository/My_Tournament_repo.dart';

class MyTournamentProvider with ChangeNotifier {
  final MyTournamentRepository _repository = MyTournamentRepository();

  // State variables
  final List<Map<String, dynamic>> selectedLogoImages = [];
  DateTime selectedDate = DateTime.now();
  bool isListening = false;
  bool isLoading = false;
  String? errorMessage;

  // Data lists
  List<Map<String, dynamic>> entities = [];
  List<Map<String, dynamic>> filteredEntities = [];
  List<Map<String, dynamic>> searchEntities = [];
  List<Map<String, dynamic>> tournamentNameItems = [];

  // UI state
  bool showCardView = true;
  int currentPage = 0;
  int pageSize = 10;

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late stt.SpeechToText _speech;

  // Getters
  bool get hasSelectedImages => selectedLogoImages.isNotEmpty;
  int get selectedImagesCount => selectedLogoImages.length;

  // Initialize speech recognition
  MyTournamentProvider() {
    _speech = stt.SpeechToText();
  }

  // Create tournament entity
  Future<void> createTournamentEntity(Map<String, dynamic> formData) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Get preferred sport from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';
      formData['preferred_sport'] = preferredSport;

      // Create entity
      Map<String, dynamic> createdEntity =
          await _repository.createEntity(formData);

      // Upload images if any
      if (selectedLogoImages.isNotEmpty) {
        for (var selectedImage in selectedLogoImages) {
          await _repository.uploadLogoImage(
            createdEntity['id'].toString(),
            'My_Tournament',
            selectedImage['imageFileName'],
            selectedImage['imageBytes'],
          );
        }
      }

      print('Tournament entity created successfully: $createdEntity');
    } catch (e) {
      errorMessage = e.toString();
      print('Failed to create tournament entity: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Update tournament entity
  Future<void> updateTournamentEntity(
      int entityId, Map<String, dynamic> formData) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Update entity
      await _repository.updateEntity(entityId, formData);

      print('Tournament entity updated successfully');
    } catch (e) {
      errorMessage = e.toString();
      print('Failed to update tournament entity: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Image handling methods
  Future<void> pickImage(
      ImageSource source, Map<String, dynamic> newImage) async {
    final imagePicker = ImagePicker();

    try {
      final pickedImage = await imagePicker.pickImage(source: source);

      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();

        newImage['imageBytes'] = imageBytes;
        newImage['imageFileName'] = pickedImage.name;

        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  void addlogoUploadRow() {
    Map<String, dynamic> newImage = {};
    selectedLogoImages.add(newImage);
    notifyListeners();
  }

  void removelogoImageUploadRow(int index) {
    if (index < selectedLogoImages.length) {
      selectedLogoImages.removeAt(index);
      notifyListeners();
    }
  }

  // Date handling
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  // Data fetching methods
  Future<void> fetchEntities() async {
    if (isLoading) return; // Prevent duplicate requests

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final fetchedEntities =
          await _repository.getAllWithPagination(currentPage, pageSize);
      entities.addAll(fetchedEntities);
      filteredEntities = List.from(entities);
      currentPage++;
    } catch (e) {
      errorMessage = e.toString();
      print('Failed to fetch paginated entities: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWithoutPaging() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final fetchedEntities = await _repository.getEntities();
      searchEntities = fetchedEntities;
    } catch (e) {
      errorMessage = e.toString();
      print('Failed to fetch entities without paging: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchtournament_nameItems() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final selectTdata = await _repository.getTournamentName();
      if (selectTdata.isNotEmpty) {
        tournamentNameItems = selectTdata;
      } else {
        print('tournament_name data is null or empty');
      }
    } catch (e) {
      errorMessage = e.toString();
      print('Failed to load tournament_name items: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Entity operations
  Future<void> deleteEntity(Map<String, dynamic> entity) async {
    try {
      await _repository.deleteEntity(entity['id']);
      entities.remove(entity);
      filteredEntities = List.from(entities);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      print('Failed to delete entity: $e');
      rethrow;
    }
  }

  // Search and filter methods
  void searchEntitiesByKeyword(String keyword) {
    filteredEntities = searchEntities
        .where((entity) =>
            entity['description']
                    ?.toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true ||
            entity['rules']
                    ?.toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true ||
            entity['venues']
                    ?.toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true ||
            entity['dates']
                    ?.toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true ||
            entity['sponsors']
                    ?.toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true ||
            entity['tournament_name']
                    ?.toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true)
        .toList();
    notifyListeners();
  }

  void filterEntities(String query) {
    if (query.isEmpty) {
      filteredEntities = List.from(entities);
    } else {
      filteredEntities = entities
          .where((entity) => entity.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase())))
          .toList();
    }
    notifyListeners();
  }

  // UI state methods
  void toggleViewMode() {
    showCardView = !showCardView;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Speech recognition methods
  void startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
        onError: (error) {
          print('Speech recognition error: $error');
        },
      );

      if (available) {
        isListening = true;
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              searchController.text = result.recognizedWords;
              searchEntitiesByKeyword(result.recognizedWords);
            }
          },
        );
        notifyListeners();
      }
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
      isListening = false;
      notifyListeners();
    }
  }

  // Scroll listener
  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchEntities();
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
