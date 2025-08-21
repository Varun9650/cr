// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:cricyard/Entity/team/Teams/model/Teams_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../repository/Teams_api_service.dart'; // Replace with the actual path of your API service

class TeamsProvider extends ChangeNotifier {
  final teamsApiService apiService = teamsApiService();

  List<TeamsModel> entities = [];
  List<TeamsModel> filteredEntities = [];
  List<TeamsModel> searchEntities = [];
  List<Map<String, dynamic>> searchEntitiess = [];

  bool showCardView = true;
  bool isLoading = false;
  int currentPage = 0;
  int pageSize = 10;
  late stt.SpeechToText _speech;
  final TextEditingController searchController = TextEditingController();

  TeamsProvider() {
    _speech = stt.SpeechToText();
    fetchEntities();
    fetchWithoutPaging();
  }

  final formKey = GlobalKey<FormState>();

  TeamsModel formData = TeamsModel(
    id: 0, // Default placeholder ID
    teamName: '',
    description: '',
    members: 0,
    matches: 0,
    active: false,
    addMyself: false,
  );

  Uint8List? logoImageBytes; // Uint8List to store the image data
  String? logoImageFileName; // String to store the image file name
  bool isActive = false;
  bool addMyself = false;

  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();

    try {
      final pickedImage = await imagePicker.pickImage(source: source);

      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();

        logoImageBytes = imageBytes;
        logoImageFileName = pickedImage.name; // Store the file name
        notifyListeners(); // Notify listeners of changes
      }
    } catch (e) {
      print(e);
    }
  }

  void showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.gallery);
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.camera);
              },
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchWithoutPaging() async {
    try {
      final fetchedEntities = await apiService.getEntitiess();
      print("This is fetched--> $fetchedEntities");
      searchEntitiess = fetchedEntities;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch teams: $e');
    }
  }

  Future<void> fetchEntities() async {
    try {
      isLoading = true;
      notifyListeners();

      final fetchedEntities =
          await apiService.getAllWithPagination(currentPage, pageSize);
      entities.addAll(fetchedEntities);
      filteredEntities = List.from(entities);
      currentPage++;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch teams data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntity(TeamsModel entity) async {
    try {
      await apiService.deleteEntity(entity.id);
      entities.remove(entity);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete entity: $e');
    }
  }

  void searchEntitiesByKeyword(String keyword) {
    filteredEntities = searchEntities
        .where((entity) =>
            entity.teamName
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity.description
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity.members
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity.matches
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity.active
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
        onError: (error) {
          debugPrint('Speech recognition error: $error');
        },
      );

      if (available) {
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              searchController.text = result.recognizedWords;
              searchEntitiesByKeyword(result.recognizedWords);
            }
          },
        );
      }
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  // dynamic scrollListener(ScrollController scrollController) {
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
  //       fetchEntities();
  //     }
  //   });
  // }

  Future createEntity(TeamsModel formData, dynamic logoImageFileName,
      Uint8List? logoImageBytes, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      // // Set additional formData properties
      // formData['active'] = isActive;
      // formData['add_myself'] = addMyself;
      //? Uncomment following lines to add preferred sport as field while passing data ------
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport');
      // Add preferredSport to formData if available
      if (preferredSport != null && preferredSport.isNotEmpty) {
        formData = formData.copyWith(preferredSport: preferredSport);
      }
      //   formData = formData.copyWith(preferredSport: preferredSport); // Assuming copyWith exists
      // TeamsModel createdEntity = await apiService.createEntity(formData);
      //? Uncomment above lines to add preferred sport as field while passing data ------

      debugPrint("Before removing preferred_sport: ${formData.toJson()}");
      Map<String, dynamic> jsonData = formData.toJson();

      // jsonData.remove('preferred_sport');
      debugPrint("Final JSON Data (Before API Call): ${jsonEncode(jsonData)}");

      TeamsModel createdEntity = await apiService.createEntity(jsonData);
      // If logo image is provided, upload it
      if (logoImageBytes != null && logoImageFileName != null) {
        await apiService.uploadLogoImage(
          createdEntity.id.toString(),
          'Teams',
          logoImageFileName,
          logoImageBytes,
        );
      }

      // Success, navigate back
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Failed to create Teams: $e");

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create Teams: $e',
                style: const TextStyle(color: Colors.black)),
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEntity(
      TeamsModel entity, bool isActive, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Set the active status in the entity
      entity.active = isActive;

      // Update the entity
      await apiService.updateEntity(entity.id, entity);

      // On successful update, navigate back
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Failed to update Teams: $e");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update Teams: $e',
                style: const TextStyle(color: Colors.black)),
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
