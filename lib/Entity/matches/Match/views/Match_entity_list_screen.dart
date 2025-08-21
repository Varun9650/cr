// ignore_for_file: use_build_context_synchronously
import 'package:cricyard/Entity/matches/Match/viewmodel/Match_viewmodel.dart';
import 'package:cricyard/Entity/matches/Match/views/Match_update_entity_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../Utils/image_constant.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../../../../utils/size_utils.dart';
import '../../../../views/widgets/app_bar/appbar_image.dart';
import '../../../../views/widgets/app_bar/appbar_title.dart';
import '../../../../views/widgets/app_bar/custom_app_bar.dart';
import '../repository/Match_api_service.dart';
import 'Match_create_entity_screen.dart';

class match_entity_list_screen extends StatefulWidget {
  static const String routeName = '/entity-list';

  @override
  _match_entity_list_screenState createState() =>
      _match_entity_list_screenState();
}

class _match_entity_list_screenState extends State<match_entity_list_screen> {
  final MatchApiService apiService = MatchApiService();
  List<Map<String, dynamic>> entities = [];
  List<Map<String, dynamic>> filteredEntities = [];
  List<Map<String, dynamic>> serachEntities = [];

  bool showCardView = true; // Add this variable to control the view mode
  TextEditingController searchController = TextEditingController();
  late stt.SpeechToText _speech;

  bool isLoading = false; // Add this variable to track loading state
  int currentPage = 0;
  int pageSize = 10; // Adjust this based on your backend API

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      _speech = stt.SpeechToText();
      super.initState();
      matchProvider.fetchEntities();
      _scrollController.addListener(_scrollListener);
      matchProvider.fetchWithoutPaging();
    });
  }

  // Future<void> fetchwithoutpaging() async {
  //   try {
  //     final fetchedEntities = await apiService.getEntities();
  //     print('data is $fetchedEntities');
  //     setState(() {
  //       serachEntities = fetchedEntities; // Update only filteredEntities
  //     });
  //     print('Match entity is .. $serachEntities');
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: Text('Failed to fetch Match: $e'),
  //           actions: [
  //             TextButton(
  //               child: const Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  // Future<void> fetchEntities() async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     final token = await TokenManager.getToken();
  //     if (token != null) {
  //       final fetchedEntities =
  //           await apiService.getAllWithPagination(currentPage, pageSize);
  //       print(' data is $fetchedEntities');
  //       setState(() {
  //         entities.addAll(fetchedEntities); // Add new data to the existing list
  //         filteredEntities = entities.toList(); // Update only filteredEntities
  //         currentPage++;
  //       });

  //       print(' entity is .. $filteredEntities');
  //     }
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: Text('Failed to fetch Match data: $e'),
  //           actions: [
  //             TextButton(
  //               child: const Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  void _scrollListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        matchProvider.fetchEntities();
      }
    });
  }

  // Future<void> deleteEntity(Map<String, dynamic> entity) async {
  //   try {
  //     final token = await TokenManager.getToken();
  //     await apiService.deleteEntity(entity['id']);
  //     setState(() {
  //       entities.remove(entity);
  //     });
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: Text('Failed to delete entity: $e'),
  //           actions: [
  //             TextButton(
  //               child: const Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  // void _searchEntities(String keyword) {
  //   setState(() {
  //     filteredEntities = serachEntities
  //         .where((entity) =>
  //             entity['team_1']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['team_2']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['location']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['date_field']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['datetime_field']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['name']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['description']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['active']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()) ||
  //             entity['user_id']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(keyword.toLowerCase()))
  //         .toList();
  //   });
  // }

  // void _startListening() async {
  //   if (!_speech.isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (status) {
  //         print('Speech recognition status: $status');
  //       },
  //       onError: (error) {
  //         print('Speech recognition error: $error');
  //       },
  //     );
  //     if (available) {
  //       _speech.listen(
  //         onResult: (result) {
  //           if (result.finalResult) {
  //             searchController.text = result.recognizedWords;
  //             _searchEntities(result.recognizedWords);
  //           }
  //         },
  //       );
  //     }
  //   }
  // }

  // void _stopListening() {
  //   if (_speech.isListening) {
  //     _speech.stop();
  //   }
  // }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  onTapArrowleft1(BuildContext context) {
    Navigator.pop(context);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //       child: Scaffold(
  //     appBar: CustomAppBar(
  //       height: getVerticalSize(49),
  //       leadingWidth: 40,
  //       leading: AppbarImage(
  //           height: getSize(24),
  //           width: getSize(24),
  //           svgPath: ImageConstant.imgArrowleft,
  //           margin: getMargin(left: 16, top: 12, bottom: 13),
  //           onTap: () {
  //             onTapArrowleft1(context);
  //           }),
  //       centerTitle: true,
  //       title: AppbarTitle(text: " Match"),
  //       actions: [
  //         Switch(
  //           activeColor: Colors.greenAccent,
  //           inactiveThumbColor: Colors.white,
  //           value: showCardView,
  //           onChanged: (value) {
  //             setState(() {
  //               showCardView = value;
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //     body: RefreshIndicator(
  //       onRefresh: () async {
  //         currentPage = 1;
  //         entities.clear();
  //         await fetchEntities();
  //       },
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextField(
  //               controller: searchController,
  //               onChanged: (value) {
  //                 _searchEntities(value);
  //               },
  //               decoration: InputDecoration(
  //                 hintText: 'Search...',
  //                 contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 filled: true,
  //                 fillColor: Colors.grey[200],
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   borderSide: BorderSide.none,
  //                 ),
  //                 suffixIcon: IconButton(
  //                   icon: const Icon(Icons.mic),
  //                   onPressed: () {
  //                     _startListening();
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: filteredEntities.length + (isLoading ? 1 : 0),
  //               itemBuilder: (BuildContext context, int index) {
  //                 if (index < filteredEntities.length) {
  //                   final entity = filteredEntities[index];
  //                   return _buildListItem(entity);
  //                 } else {
  //                   // Display the loading indicator at the bottom when new data is loading
  //                   return const Padding(
  //                     padding: EdgeInsets.all(8.0),
  //                     child: Center(
  //                       child: CircularProgressIndicator(),
  //                     ),
  //                   );
  //                 }
  //               },
  //               controller: _scrollController,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => matchCreateEntityScreen(),
  //           ),
  //         ).then((_) {
  //           fetchEntities();
  //         });
  //       },
  //       child: const Icon(Icons.add),
  //     ),
  //   ));
  // }
  @override
  Widget build(BuildContext context) {
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
              onTapArrowleft1(context);
            },
          ),
          centerTitle: true,
          title: AppbarTitle(text: " Match"),
          actions: [
            Consumer<MatchProvider>(
              builder: (context, provider, child) {
                return Switch(
                  activeColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.white,
                  value: provider.showCardView,
                  onChanged: (value) {
                    provider.toggleViewMode();
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<MatchProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchWithoutPaging();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: provider.searchController,
                      onChanged: (value) {
                        provider.searchEntities(value);
                      },
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
                            provider.startListening();
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.entities.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index < provider.entities.length) {
                          final entity = provider.entities[index];
                          return _buildListItem(entity); // Build your list item
                        } else {
                          // Display the loading indicator at the bottom when new data is loading
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                      controller: provider.scrollController,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => matchCreateEntityScreen(),
              ),
            ).then((_) {
              context.read<MatchProvider>().fetchEntities();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> entity) {
    return showCardView ? _buildCardView(entity) : _buildNormalView(entity);
  }

  // Function to build card view for a list item
  Widget _buildCardView(Map<String, dynamic> entity) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _buildNormalView(entity));
  }

  // Widget _buildNormalView(Map<String, dynamic> entity) {
  //   final values = entity.values.elementAt(21) ?? 'Authsec';
  //   return SizedBox(
  //     width: double.maxFinite,
  //     child: Container(
  //       padding: getPadding(
  //         left: 16,
  //         top: 5,
  //         right: 5,
  //         bottom: 17,
  //       ),
  //       decoration: AppDecoration.outlineGray70011.copyWith(
  //           borderRadius: BorderRadiusStyle.roundedBorder6,
  //           color: Colors.grey[100]),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Padding(
  //             padding: getPadding(
  //                 //right: 13,
  //                 ),
  //             child: Row(
  //               children: [
  //                 Container(
  //                   width: MediaQuery.of(context).size.width * 0.30,
  //                   margin: getMargin(
  //                     left: 8,
  //                     top: 3,
  //                     bottom: 1,
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         entity['id'].toString(),
  //                         overflow: TextOverflow.ellipsis,
  //                         textAlign: TextAlign.left,
  //                         style: AppStyle.txtGreenSemiBold16,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const Spacer(),
  //                 PopupMenuButton<String>(
  //                   icon: const Icon(
  //                     Icons.more_vert,
  //                     color: Colors.black,
  //                     size: 16,
  //                   ),
  //                   itemBuilder: (BuildContext context) {
  //                     return [
  //                       PopupMenuItem<String>(
  //                         value: 'edit',
  //                         child: Row(
  //                           children: [
  //                             const Icon(
  //                               Icons.edit,
  //                               size: 16, // Adjust the icon size as needed
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Text(
  //                               'Edit',
  //                               style: AppStyle
  //                                   .txtGilroySemiBold16, // Adjust the text size as needed
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       PopupMenuItem<String>(
  //                         value: 'delete',
  //                         child: Row(
  //                           children: [
  //                             const Icon(
  //                               Icons.delete,
  //                               size: 16, // Adjust the icon size as needed
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Text(
  //                               'Delete',
  //                               style: AppStyle
  //                                   .txtGilroySemiBold16, // Adjust the text size as needed
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ];
  //                   },
  //                   onSelected: (String value) {
  //                     if (value == 'edit') {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) =>
  //                               matchUpdateEntityScreen(entity: entity),
  //                         ),
  //                       ).then((_) {
  //                         fetchEntities();
  //                       });
  //                     } else if (value == 'delete') {
  //                       showDialog(
  //                         context: context,
  //                         builder: (BuildContext context) {
  //                           return AlertDialog(
  //                             title: const Text('Confirm Deletion'),
  //                             content: const Text(
  //                                 'Are you sure you want to delete?'),
  //                             actions: [
  //                               TextButton(
  //                                 child: const Text('Cancel'),
  //                                 onPressed: () {
  //                                   Navigator.of(context).pop();
  //                                 },
  //                               ),
  //                               TextButton(
  //                                 child: const Text('Delete'),
  //                                 onPressed: () {
  //                                   Navigator.of(context).pop();
  //                                   deleteEntity(entity)
  //                                       .then((value) => {fetchEntities()});
  //                                 },
  //                               ),
  //                             ],
  //                           );
  //                         },
  //                       );
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Team 1 : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['team_1'] ?? 'No Team 1 Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Team 2 : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['team_2'] ?? 'No Team 2 Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Location : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['location'] ?? 'No Location Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Date Field : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['date_field'] ?? 'No Date Field Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Datetime Field : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['datetime_field'] ?? 'No Datetime Field Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Name : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['name'] ?? 'No Name Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Description : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['description'] ?? 'No Description Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Active : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['active'].toString() ?? 'No Active Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: getPadding(
  //               top: 10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "User Id : ",
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16,
  //                 ),
  //                 Text(
  //                   entity['user_id'] ?? 'No User Id Available',
  //                   overflow: TextOverflow.ellipsis,
  //                   textAlign: TextAlign.left,
  //                   style: AppStyle.txtGilroyMedium16Bluegray900,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildNormalView(Map<String, dynamic> entity) {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        final values = entity.values.elementAt(21) ?? 'Authsec';

        return SizedBox(
          width: double.maxFinite,
          child: Container(
            padding: getPadding(
              left: 16,
              top: 5,
              right: 5,
              bottom: 17,
            ),
            decoration: AppDecoration.outlineGray70011.copyWith(
              borderRadius: BorderRadiusStyle.roundedBorder6,
              color: Colors.grey[100],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: getPadding(),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: getMargin(left: 8, top: 3, bottom: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              entity['id'].toString(),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtGreenSemiBold16,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black,
                          size: 16,
                        ),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: AppStyle.txtGilroySemiBold16,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: AppStyle.txtGilroySemiBold16,
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                        onSelected: (String value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MatchUpdateEntityScreen(entity: entity),
                              ),
                            ).then((_) {
                              provider
                                  .fetchEntities(); // Fetch data via provider
                            });
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text(
                                      'Are you sure you want to delete?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        provider
                                            .deleteEntity(
                                                entity) // Use provider
                                            .then((value) =>
                                                provider.fetchEntities());
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
                ..._buildEntityFields(
                    entity), // Factor out repeated rows for readability
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildEntityFields(Map<String, dynamic> entity) {
    return [
      _buildFieldRow("Team 1 : ", entity['team_1'] ?? 'No Team 1 Available'),
      _buildFieldRow("Team 2 : ", entity['team_2'] ?? 'No Team 2 Available'),
      _buildFieldRow(
          "Location : ", entity['location'] ?? 'No Location Available'),
      _buildFieldRow(
          "Date Field : ", entity['date_field'] ?? 'No Date Field Available'),
      _buildFieldRow("Datetime Field : ",
          entity['datetime_field'] ?? 'No Datetime Field Available'),
      _buildFieldRow("Name : ", entity['name'] ?? 'No Name Available'),
      _buildFieldRow("Description : ",
          entity['description'] ?? 'No Description Available'),
      _buildFieldRow(
          "Active : ", entity['active'].toString() ?? 'No Active Available'),
      _buildFieldRow("User Id : ", entity['user_id'] ?? 'No User Id Available'),
    ];
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: getPadding(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle.txtGilroyMedium16,
          ),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle.txtGilroyMedium16Bluegray900,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(String title) {
    return CircleAvatar(
      backgroundColor: Colors.blue,
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : 'NA',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAdditionalFieldsDialog(
    BuildContext context,
    Map<String, dynamic> entity,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Additional Fields'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Created At: ${_formatTimestamp(entity['createdAt'], dateFormat)}'),
              Text('Created By: ${entity['createdBy'] ?? 'N/A'}'),
              Text('Updated By: ${entity['updatedBy'] ?? 'N/A'}'),
              Text(
                  'Updated At: ${_formatTimestamp(entity['updatedAt'], dateFormat)}'),
              Text('Account ID: ${entity['accountId'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp, DateFormat dateFormat) {
    if (timestamp is int) {
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return dateFormat.format(dateTime);
    } else if (timestamp is String) {
      return timestamp;
    } else {
      return 'N/A';
    }
  }
}
