// // ignore_for_file: use_build_context_synchronously
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../repository/Absent_hurt_api_service.dart';
// import 'Absent_hurt_create_entity_screen.dart';
// import 'Absent_hurt_update_entity_screen.dart';
import 'package:cricyard/Entity/absent_hurt/Absent_hurt/model/Absent_hurt_model.dart';

import '/providers/token_manager.dart';
// import 'package:flutter/services.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import '../../../../theme/app_style.dart';
// import '../../../../utils/size_utils.dart';
// import '../../../../Utils/image_constant.dart';
// import '../../../../views/widgets/app_bar/appbar_image.dart';
// import '../../../../views/widgets/app_bar/appbar_title.dart';
// import '../../../../views/widgets/app_bar/custom_app_bar.dart';
// import '../../../../theme/app_decoration.dart';

// class absent_hurt_entity_list_screen extends StatefulWidget {
//   static const String routeName = '/entity-list';

//   @override
//   _absent_hurt_entity_list_screenState createState() =>
//       _absent_hurt_entity_list_screenState();
// }

// class _absent_hurt_entity_list_screenState
//     extends State<absent_hurt_entity_list_screen> {
//   final AbsentHurtApiService apiService = AbsentHurtApiService();
//   List<Map<String, dynamic>> entities = [];
//   List<Map<String, dynamic>> filteredEntities = [];
//   List<Map<String, dynamic>> serachEntities = [];

//   bool showCardView = true; // Add this variable to control the view mode
//   TextEditingController searchController = TextEditingController();
//   late stt.SpeechToText _speech;

//   bool isLoading = false; // Add this variable to track loading state
//   int currentPage = 0;
//   int pageSize = 10; // Adjust this based on your backend API

//   final ScrollController _scrollController = ScrollController();
//   @override
//   void initState() {
//     _speech = stt.SpeechToText();
//     super.initState();
//     fetchEntities();
//     _scrollController.addListener(_scrollListener);
//     fetchwithoutpaging();
//   }

//   Future<void> fetchwithoutpaging() async {
//     try {
//       final token = await TokenManager.getToken();
//       if (token != null) {
//         final fetchedEntities = await apiService.getEntities(token!);
//         print('data is $fetchedEntities');
//         setState(() {
//           serachEntities = fetchedEntities; // Update only filteredEntities
//         });
//         print('Absent_hurt entity is .. $serachEntities');
//       }
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: Text('Failed to fetch Absent_hurt: $e'),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   Future<void> fetchEntities() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       final token = await TokenManager.getToken();
//       if (token != null) {
//         final fetchedEntities =
//             await apiService.getAllWithPagination(token, currentPage, pageSize);
//         print(' data is $fetchedEntities');
//         setState(() {
//           entities.addAll(fetchedEntities); // Add new data to the existing list
//           filteredEntities = entities.toList(); // Update only filteredEntities
//           currentPage++;
//         });

//         print(' entity is .. $filteredEntities');
//       }
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: Text('Failed to fetch Absent_hurt data: $e'),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       fetchEntities();
//     }
//   }

//   Future<void> deleteEntity(Map<String, dynamic> entity) async {
//     try {
//       final token = await TokenManager.getToken();
//       await apiService.deleteEntity(token!, entity['id']);
//       setState(() {
//         entities.remove(entity);
//       });
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: Text('Failed to delete entity: $e'),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _searchEntities(String keyword) {
//     setState(() {
//       filteredEntities = serachEntities
//           .where((entity) =>
//               entity['description']
//                   .toString()
//                   .toLowerCase()
//                   .contains(keyword.toLowerCase()) ||
//               entity['active']
//                   .toString()
//                   .toLowerCase()
//                   .contains(keyword.toLowerCase()) ||
//               entity['player_name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(keyword.toLowerCase()))
//           .toList();
//     });
//   }

//   void _startListening() async {
//     if (!_speech.isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (status) {
//           print('Speech recognition status: $status');
//         },
//         onError: (error) {
//           print('Speech recognition error: $error');
//         },
//       );

//       if (available) {
//         _speech.listen(
//           onResult: (result) {
//             if (result.finalResult) {
//               searchController.text = result.recognizedWords;
//               _searchEntities(result.recognizedWords);
//             }
//           },
//         );
//       }
//     }
//   }

//   void _stopListening() {
//     if (_speech.isListening) {
//       _speech.stop();
//     }
//   }

//   @override
//   void dispose() {
//     _speech.cancel();
//     super.dispose();
//   }

//   onTapArrowleft1(BuildContext context) {
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       appBar: CustomAppBar(
//         height: getVerticalSize(49),
//         leadingWidth: 40,
//         leading: AppbarImage(
//             height: getSize(24),
//             width: getSize(24),
//             svgPath: ImageConstant.imgArrowleft,
//             margin: getMargin(left: 16, top: 12, bottom: 13),
//             onTap: () {
//               onTapArrowleft1(context);
//             }),
//         centerTitle: true,
//         title: AppbarTitle(text: " Absent_hurt"),
//         actions: [
//           Switch(
//             activeColor: Colors.greenAccent,
//             inactiveThumbColor: Colors.white,
//             value: showCardView,
//             onChanged: (value) {
//               setState(() {
//                 showCardView = value;
//               });
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           currentPage = 1;
//           entities.clear();
//           await fetchEntities();
//         },
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: searchController,
//                 onChanged: (value) {
//                   _searchEntities(value);
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search...',
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.mic),
//                     onPressed: () {
//                       _startListening();
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredEntities.length + (isLoading ? 1 : 0),
//                 itemBuilder: (BuildContext context, int index) {
//                   if (index < filteredEntities.length) {
//                     final entity = filteredEntities[index];
//                     return _buildListItem(entity);
//                   } else {
//                     // Display the loading indicator at the bottom when new data is loading
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   }
//                 },
//                 controller: _scrollController,
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AbsentHurtCreateEntityScreen(),
//             ),
//           ).then((_) {
//             fetchEntities();
//           });
//         },
//         child: const Icon(Icons.add),
//       ),
//     ));
//   }

//   Widget _buildListItem(Map<String, dynamic> entity) {
//     return showCardView ? _buildCardView(entity) : _buildNormalView(entity);
//   }

//   // Function to build card view for a list item
//   Widget _buildCardView(Map<String, dynamic> entity) {
//     return Card(
//         elevation: 2,
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         child: _buildNormalView(entity));
//   }

//   // Function to build normal view for a list item

//   // Function to build normal view for a list item

//   Widget _buildNormalView(Map<String, dynamic> entity) {
//     final values = entity.values.elementAt(21) ?? 'Authsec';
    
//     return SizedBox(
//       width: double.maxFinite,
//       child: Container(
//         padding: getPadding(
//           left: 16,
//           top: 5,
//           right: 5,
//           bottom: 17,
//         ),
//         decoration: AppDecoration.outlineGray70011.copyWith(
//             borderRadius: BorderRadiusStyle.roundedBorder6,
//             color: Colors.grey[100]),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: getPadding(
//                   //right: 13,
//                   ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: MediaQuery.of(context).size.width * 0.30,
//                     margin: getMargin(
//                       left: 8,
//                       top: 3,
//                       bottom: 1,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           entity['id'].toString(),
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.left,
//                           style: AppStyle.txtGreenSemiBold16,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   PopupMenuButton<String>(
//                     icon: const Icon(
//                       Icons.more_vert,
//                       color: Colors.black,
//                       size: 16,
//                     ),
//                     itemBuilder: (BuildContext context) {
//                       return [
//                         PopupMenuItem<String>(
//                           value: 'edit',
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.edit,
//                                 size: 16, // Adjust the icon size as needed
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Edit',
//                                 style: AppStyle
//                                     .txtGilroySemiBold16, // Adjust the text size as needed
//                               ),
//                             ],
//                           ),
//                         ),
//                         PopupMenuItem<String>(
//                           value: 'delete',
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.delete,
//                                 size: 16, // Adjust the icon size as needed
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Delete',
//                                 style: AppStyle
//                                     .txtGilroySemiBold16, // Adjust the text size as needed
//                               ),
//                             ],
//                           ),
//                         ),
//                       ];
//                     },
//                     onSelected: (String value) {
//                       if (value == 'edit') {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 AbsentHurtCreateEntityScreen(entity: entity),
//                           ),
//                         ).then((_) {
//                           fetchEntities();
//                         });
//                       } else if (value == 'delete') {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: const Text('Confirm Deletion'),
//                               content: const Text(
//                                   'Are you sure you want to delete?'),
//                               actions: [
//                                 TextButton(
//                                   child: const Text('Cancel'),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: const Text('Delete'),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                     deleteEntity(entity)
//                                         .then((value) => {fetchEntities()});
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: getPadding(
//                 top: 10,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Description : ",
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: AppStyle.txtGilroyMedium16,
//                   ),
//                   Text(
//                     entity['description'] ?? 'No Description Available',
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: AppStyle.txtGilroyMedium16Bluegray900,
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: getPadding(
//                 top: 10,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Active : ",
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: AppStyle.txtGilroyMedium16,
//                   ),
//                   Text(
//                     entity['active'].toString() ?? 'No Active Available',
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: AppStyle.txtGilroyMedium16Bluegray900,
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: getPadding(
//                 top: 10,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Player Name : ",
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: AppStyle.txtGilroyMedium16,
//                   ),
//                   Text(
//                     entity['player_name'] ?? 'No Player Name Available',
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: AppStyle.txtGilroyMedium16Bluegray900,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLeadingIcon(String title) {
//     return CircleAvatar(
//       backgroundColor: Colors.blue,
//       child: Text(
//         title.isNotEmpty ? title[0].toUpperCase() : 'NA',
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   void _showAdditionalFieldsDialog(
//     BuildContext context,
//     Map<String, dynamic> entity,
//   ) {
//     final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Additional Fields'),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                   'Created At: ${_formatTimestamp(entity['createdAt'], dateFormat)}'),
//               Text('Created By: ${entity['createdBy'] ?? 'N/A'}'),
//               Text('Updated By: ${entity['updatedBy'] ?? 'N/A'}'),
//               Text(
//                   'Updated At: ${_formatTimestamp(entity['updatedAt'], dateFormat)}'),
//               Text('Account ID: ${entity['accountId'] ?? 'N/A'}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String _formatTimestamp(dynamic timestamp, DateFormat dateFormat) {
//     if (timestamp is int) {
//       final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
//       return dateFormat.format(dateTime);
//     } else if (timestamp is String) {
//       return timestamp;
//     } else {
//       return 'N/A';
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/Absent_hurt_api_service.dart';
import 'package:cricyard/Entity/absent_hurt/Absent_hurt/viewmodel/absent_hurt_viewmodel.dart';
// import '../providers/token_manager.dart';
import 'Absent_hurt_create_entity_screen.dart';
import '../../../../theme/app_style.dart';
import '../../../../utils/size_utils.dart';
import '../../../../Utils/image_constant.dart';
import '../../../../views/widgets/app_bar/appbar_image.dart';
import '../../../../views/widgets/app_bar/appbar_title.dart';
import '../../../../views/widgets/app_bar/custom_app_bar.dart';

class AbsentHurtEntityListScreen extends StatefulWidget {
  static const String routeName = '/entity-list';

  @override
  _AbsentHurtEntityListScreenState createState() =>
      _AbsentHurtEntityListScreenState();
}

class _AbsentHurtEntityListScreenState extends State<AbsentHurtEntityListScreen> {
  final AbsentHurtApiService apiService = AbsentHurtApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AbsentHurtProvider>(context, listen: false);
      TokenManager.getToken().then((token) {
        if (token != null) {
          provider.fetchEntities(apiService, );
          provider.fetchWithoutPaging(apiService);
        }
      });
    });
  }

  void onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AbsentHurtProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              height: getVerticalSize(49),
              leadingWidth: 40,
              leading: AppbarImage(
                  height: getSize(24),
                  width: getSize(24),
                  svgPath: ImageConstant.imgArrowleft,
                  margin: getMargin(left: 16, top: 12, bottom: 13),
                  onTap: () {
                    onTapArrowLeft(context);
                  }),
              centerTitle: true,
              title: AppbarTitle(text: " Absent_hurt"),
              actions: [
                Switch(
                  activeColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.white,
                  value: provider.showCardView,
                  onChanged: (value) {
                    provider.toggleCardView(value);
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // final token = await TokenManager.getToken();
                  provider.resetPagination();
                  await provider.fetchEntities(apiService, );
                
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: provider.search_Entities,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: () {
                            // Implement speech-to-text functionality here
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.filteredEntities.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index < provider.filteredEntities.length) {
                          final entity = provider.filteredEntities[index];
                          return _buildListItem(provider, entity);
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AbsentHurtCreateEntityScreen(),
                  ),
                ).then((_) async {
                  // final token = await TokenManager.getToken();
                    provider.fetchEntities(apiService);
                  
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(AbsentHurtProvider provider, AbsentHurtEntity entity) {
    return provider.showCardView
        ? _buildCardView(entity)
        : _buildNormalView(entity);
  }

  Widget _buildCardView(AbsentHurtEntity entity) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _buildNormalView(entity));
  }

  Widget _buildNormalView(AbsentHurtEntity entity) {
    final provider = Provider.of<AbsentHurtProvider>(context);
    return ListTile(
      title: Text(entity.description ?? 'No Description Available'),
      subtitle: Text(entity.playerName ?? 'No Player Name Available'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'delete') {
              provider.deleteEntity(apiService, entity);
            
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
