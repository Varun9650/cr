// ignore_for_file: use_build_context_synchronously
import 'package:cricyard/Entity/event_management/Event_Management/viewmodel/Event_Management_viewmodel.dart';
import 'package:flutter/material.dart';
import '../../../../Utils/image_constant.dart';
import '../../../../Utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../views/widgets/app_bar/appbar_image.dart';
import '../../../../views/widgets/app_bar/appbar_title.dart';
import '../../../../views/widgets/app_bar/custom_app_bar.dart';
import '../../../../views/widgets/custom_button.dart';
import '../../../../views/widgets/custom_text_form_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repository/Event_Management_api_service.dart';
// import '/providers/token_manager.dart';
import '../model/Event_management_model.dart';
import 'package:flutter/services.dart';

class event_managementCreateEntityScreen extends StatefulWidget {
  const event_managementCreateEntityScreen({super.key});

  @override
  _event_managementCreateEntityScreenState createState() =>
      _event_managementCreateEntityScreenState();
}

class _event_managementCreateEntityScreenState
    extends State<event_managementCreateEntityScreen> {
  final EventManagementApiService apiService = EventManagementApiService();
  late EventManagementModel eventModel;
  late EventManagementControllers eventControllers;
  // final formKey = GlobalKey<FormState>();

  // final Map<String, dynamic> formData = {};
  // DateTime selectedDateTime = DateTime.now();
  // Future<void> selectDateTime(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDateTime,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null) {
  //     final TimeOfDay? pickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: TimeOfDay.fromDateTime(selectedDateTime),
  //     );
  //     print(pickedTime);
  //     if (pickedTime != null) {
  //       setState(() {
  //         selectedDateTime = DateTime(
  //           picked.year,
  //           picked.month,
  //           picked.day,
  //           pickedTime.hour,
  //           pickedTime.minute,
  //         );
  //       });
  //     }
  //   }
  // }

  // bool isactive = false;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> performOCR() async {
  //   try {
  //     final ImagePicker _picker = ImagePicker();
  //     // Show options for gallery or camera using a dialog
  //     await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Select Image Source'),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: <Widget>[
  //                 GestureDetector(
  //                   child: const Text('Gallery'),
  //                   onTap: () async {
  //                     Navigator.of(context).pop();
  //                     final XFile? image =
  //                         await _picker.pickImage(source: ImageSource.gallery);
  //                     processImage(image);
  //                   },
  //                 ),
  //                 const SizedBox(height: 20),
  //                 GestureDetector(
  //                   child: const Text('Camera'),
  //                   onTap: () async {
  //                     Navigator.of(context).pop();
  //                     final XFile? image =
  //                         await _picker.pickImage(source: ImageSource.camera);
  //                     processImage(image);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     print("OCR Error: $e");
  //     // Handle OCR errors here
  //   }
  // }
  // final textRecognizer = TextRecognizer();
  // void processImage(XFile? image) async {
  //   if (image == null) return; // User canceled image picking
  //   final file = File(image.path);
  //   final inputImage = InputImage.fromFile(file);
  //   final recognizedText = await textRecognizer.processImage(inputImage);
  //   StringBuffer extractedTextBuffer = StringBuffer();
  //   for (TextBlock block in recognizedText.blocks) {
  //     for (TextLine line in block.lines) {
  //       extractedTextBuffer.write(line.text + ' ');
  //     }
  //   }
  //   textRecognizer.close();
  //   String extractedText = extractedTextBuffer.toString().trim();
  //   setState(() {
  //     formData['description'] = extractedText;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final eventProvider =
        Provider.of<EventManagementProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
          height: getVerticalSize(49),
          leadingWidth: 40,
          leading: AppbarImage(
              height: getSize(24),
              width: getSize(24),
              svgPath: ImageConstant.imgArrowleftBlueGray900,
              margin: getMargin(left: 16, top: 12, bottom: 13),
              onTap: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: AppbarTitle(text: "Create Event_Management")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: eventProvider.formKey,
            child: Column(
              children: [
                Padding(
                  padding: getPadding(top: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Practice Match",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.fieldlabel),
                        CustomTextFormField(
                          focusNode: FocusNode(),
                          hintText: "Please Enter Practice Match",
                          onsaved: (value) =>
                              eventProvider.formData['practice_match'] = value,
                        )
                      ]),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: getPadding(top: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Admin Name",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.fieldlabel),
                        CustomTextFormField(
                          focusNode: FocusNode(),
                          hintText: "Please Enter Admin Name",
                          onsaved: (value) =>
                              eventProvider.formData['admin_name'] = value,
                        )
                      ]),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: getPadding(top: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Ground",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.fieldlabel),
                        CustomTextFormField(
                          focusNode: FocusNode(),
                          hintText: "Please Enter Ground",
                          onsaved: (value) =>
                              eventProvider.formData['ground'] = value,
                        )
                      ]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: DateFormat('yyyy-MM-dd HH:mm')
                      .format(eventProvider.selectedDateTime),
                  decoration: const InputDecoration(
                    labelText: 'datetime',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => eventProvider.selectDateTime(context),
                  onSaved: (value) {
                    eventProvider.formData['datetime'] =
                        DateFormat('yyyy-MM-dd HH:mm')
                            .format(eventProvider.selectedDateTime);
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: getPadding(top: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Name",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.fieldlabel),
                        CustomTextFormField(
                          focusNode: FocusNode(),
                          hintText: "Please Enter Name",
                          onsaved: (value) =>
                              eventProvider.formData['name'] = value,
                        )
                      ]),
                ),
                const SizedBox(height: 16),
                Padding(
                    padding: getPadding(top: 19),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Description",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtGilroyMedium16Bluegray900),
                          CustomTextFormField(
                              maxLines: 5,
                              focusNode: FocusNode(),
                              hintText: "Enter Description",
                              onsaved: (value) =>
                                  eventProvider.formData['description'] = value,
                              margin: getMargin(top: 6))
                        ])),
                Switch(
                  value: eventProvider.isActive,
                  onChanged: (newValue) {
                    context
                        .read<EventManagementProvider>()
                        .toggleActive(newValue);
                  },
                ),
                const SizedBox(width: 8),
                const Text('Active'),
                const SizedBox(width: 8),
                // CustomButton(
                //   height: getVerticalSize(50),
                //   text: "Submit",
                //   margin: getMargin(top: 24, bottom: 5),
                //   onTap: () async {
                //     if (formKey.currentState!.validate()) {
                //       formKey.currentState!.save();
                //       formData['active'] = isactive;
                //       try {
                //         print(formData);
                //         Map<String, dynamic> createdEntity =
                //             await apiService.createEntity(
                //               // token!,
                //             formData);
                //         Navigator.pop(context);
                //       } catch (e) {
                //         showDialog(
                //           context: context,
                //           builder: (BuildContext context) {
                //             return AlertDialog(
                //               title: const Text('Error'),
                //               content:
                //                   Text('Failed to create Event_Management: $e'),
                //               actions: [
                //                 TextButton(
                //                   child: const Text('OK'),
                //                   onPressed: () {
                //                     Navigator.of(context).pop();
                //                   },
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       }
                //     }
                //   },
                // ),
                CustomButton(
                  height: getVerticalSize(50),
                  text: "Submit",
                  margin: getMargin(top: 24, bottom: 5),
                  onTap: () async {
                    await eventProvider.submitForm(
                      context,
                      eventProvider.formKey,
                      eventProvider.formData,
                      eventProvider.isActive,
                      (data) async {
                        return await apiService.createEntity(data);
                      },
                    );
                    // If there's an error, display a dialog.
                    if (eventProvider.errorMessage != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text(eventProvider.errorMessage!),
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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
