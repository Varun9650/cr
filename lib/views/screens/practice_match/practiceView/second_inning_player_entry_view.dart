// import 'package:cricyard/views/screens/practice_match/viewmodel/practice_matchview_model.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:cricyard/views/screens/practice_match/PracticeMatchService.dart';
// import '../PracticeMatchScoreScreen.dart';

// class SecondInningPlayerEntryView extends StatefulWidget {
//   final Map<String, dynamic> lastRecord;
//   final Map<String, dynamic> match;
//   final int battingTeamId;
//   final int bowlingTeamId;

//   const SecondInningPlayerEntryView(
//       {super.key,
//       required this.lastRecord,
//       required this.match,
//       required this.battingTeamId,
//       required this.bowlingTeamId});

//   @override
//   State<SecondInningPlayerEntryView> createState() =>
//       _SecondInningPlayerEntryViewState();
// }

// class _SecondInningPlayerEntryViewState
//     extends State<SecondInningPlayerEntryView> {
//   final TextEditingController _strikerController = TextEditingController();
//   final TextEditingController _nonStrikerController = TextEditingController();
//   final TextEditingController _bowlerController = TextEditingController();

//   final FocusNode _strikerFocusNode = FocusNode();
//   final FocusNode _nonStrikerFocusNode = FocusNode();
//   final FocusNode _bowlerFocusNode = FocusNode();

//   final PracticeMatchService scoreservice = PracticeMatchService();

//   List<String> battingTeamPlayers = [];
//   List<String> bowlingTeamPlayers = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     Provider.of<PracticeMatchviewModel>(context, listen: false)
//         .getAllPlayersInTeam(widget.battingTeamId);
//     Provider.of<PracticeMatchviewModel>(context, listen: false)
//         .getAllPlayersInTeam(widget.bowlingTeamId);
//     // fetchBattingPlayers();
//     // fetchBowlingPlayers();
//     super.initState();
//   }

//   // void fetchBattingPlayers() async {
//   //   final data = await scoreservice.getAllPlayersInTeam(widget.battingTeamId);
//   //   setState(() {
//   //     battingTeamPlayers =
//   //         data.map<String>((team) => team['player_name'] as String).toList();
//   //   });
//   //   print("BATTING--LIST---$battingTeamPlayers");
//   // }

//   // void fetchBowlingPlayers() async {
//   //   final data = await scoreservice.getAllPlayersInTeam(widget.bowlingTeamId);
//   //   setState(() {
//   //     bowlingTeamPlayers =
//   //         data.map<String>((team) => team['player_name'] as String).toList();
//   //   });
//   //   print("BOWLING--LIST---$bowlingTeamPlayers");
//   // }

//   List<String> getFilteredPlayers(String field) {
//     List<String> filteredPlayers = List.from(battingTeamPlayers);
//     if (field == 'striker' && _nonStrikerController.text.isNotEmpty) {
//       filteredPlayers.remove(_nonStrikerController.text);
//     } else if (field == 'nonStriker' && _strikerController.text.isNotEmpty) {
//       filteredPlayers.remove(_strikerController.text);
//     }
//     return filteredPlayers;
//   }

//   void _startMatch() async {
//     if (_strikerController.text.isEmpty ||
//         _nonStrikerController.text.isEmpty ||
//         _bowlerController.text.isEmpty) {
//       showSnackBar(context, 'Fields cannot be empty', Colors.red);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     await scoreservice
//         .newPlayerEntryInningend(
//           _strikerController.text,
//           _nonStrikerController.text,
//           _bowlerController.text,
//           widget.lastRecord,
//         )
//         .then(
//           (value) => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   PracticeMatchScoreScreen(entity: widget.match),
//             ),
//           ),
//         );

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void showSnackBar(BuildContext context, String msg, Color color) {
//     final mediaQuery = MediaQuery.of(context);
//     final topPadding = mediaQuery.viewPadding.bottom;
//     const snackBarHeight = 50.0; // Approximate height of SnackBar

//     final topMargin = topPadding + snackBarHeight + 700; // Add some padding

//     SnackBar snackBar = SnackBar(
//       margin: EdgeInsets.only(bottom: topMargin, left: 16.0, right: 16.0),
//       behavior: SnackBarBehavior.floating,
//       backgroundColor: Colors
//           .transparent, // Make background transparent to show custom design
//       elevation: 0, // Remove default elevation to apply custom shadow
//       content: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [color.withOpacity(0.8), color],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12.0),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black26,
//                   offset: Offset(0, 4),
//                   blurRadius: 10.0,
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.info_rounded,
//                   color: Colors.white,
//                   size: 28.0, // Slightly larger icon
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     msg,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       fontSize: 16.0, // Slightly larger text
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             left: -15,
//             top: -15,
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Positioned(
//             right: -10,
//             bottom: -10,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         forceMaterialTransparency: true,
//         backgroundColor: Colors.grey[200],
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: IntrinsicHeight(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                     color: const Color(0xFF219ebc),
//                     borderRadius: BorderRadius.circular(12)),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           "Select players for 2nd Innings",
//           style:
//               GoogleFonts.getFont('Poppins', fontSize: 20, color: Colors.black),
//         ),
//       ),
//       body: _buildTextFieldsAndButton(),
//     );
//   }

//   Widget _buildTextFieldsAndButton() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.grey,
//               offset: Offset(0, 1),
//               blurRadius: 0.5,
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               _buildAutocompleteTextField(
//                   _strikerController, 'Striker', _strikerFocusNode, 'striker'),
//               const SizedBox(height: 10),
//               _buildAutocompleteTextField(_nonStrikerController, 'Non-Striker',
//                   _nonStrikerFocusNode, 'nonStriker'),
//               const SizedBox(height: 10),
//               _buildAutocompleteTextField(
//                   _bowlerController, 'Bowler', _bowlerFocusNode, 'bowler'),
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 40,
//                 width: 150,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _startMatch,
//                   child: _isLoading
//                       ? const CircularProgressIndicator(
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         )
//                       : const Text(
//                           'Start Match',
//                           style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAutocompleteTextField(TextEditingController controller,
//       String label, FocusNode focusNode, String field) {
//     return Consumer<PracticeMatchviewModel>(builder: (context, value, child) {
//       return Autocomplete<String>(
//         optionsBuilder: (TextEditingValue textEditingValue) {
//           List<String> data;
//           if (field == 'bowler') {
//             data = await value.getAllPlayersInTeam(widget.bowlingTeamId);
//           } else {
//             data = getFilteredPlayers(field);
//           }

//           print('all data is ... $data');

//           if (textEditingValue.text.isEmpty) {
//             return data;
//           }
//           return data.where((String option) {
//             return option
//                 .toLowerCase()
//                 .contains(textEditingValue.text.toLowerCase());
//           }).toList();
//         },
//         onSelected: (String selection) {
//           controller.text = selection;
//           setState(() {});
//         },
//         fieldViewBuilder: (BuildContext context,
//             TextEditingController textEditingController,
//             FocusNode fieldFocusNode,
//             VoidCallback onFieldSubmitted) {
//           textEditingController.text = controller.text;
//           textEditingController.addListener(() {
//             controller.text = textEditingController.text;
//           });
//           return TextField(
//             controller: textEditingController,
//             focusNode: fieldFocusNode,
//             decoration: InputDecoration(
//               labelText: label,
//               border: const UnderlineInputBorder(),
//               focusedBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blue, width: 2),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             style: const TextStyle(color: Colors.black),
//             onSubmitted: (_) => onFieldSubmitted(),
//           );
//         },
//         optionsViewBuilder: (BuildContext context,
//             AutocompleteOnSelected<String> onSelected,
//             Iterable<String> options) {
//           return Align(
//             alignment: Alignment.topLeft,
//             child: Material(
//               elevation: 4.0,
//               child: Container(
//                 height: 160,
//                 color: Colors.white,
//                 width: 300.0,
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(0.0),
//                   itemCount: options.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     final String option = options.elementAt(index);
//                     return ListTile(
//                       title: Text(
//                         option,
//                         style: const TextStyle(color: Colors.black),
//                       ),
//                       onTap: () {
//                         onSelected(option);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     });
//   }
// }
import 'package:cricyard/views/screens/practice_match/practiceViewmodel/PracticeMatchViewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'PracticeMatchScoreScreen.dart';
import 'package:cricyard/views/screens/practice_match/practiceRepository/PracticeMatchService.dart';

final PracticeMatchService scoreservice = PracticeMatchService();

class SecondInningPlayerEntryView extends StatefulWidget {
  final Map<String, dynamic> lastRecord;
  final Map<String, dynamic> match;
  final int battingTeamId;
  final int bowlingTeamId;

//   final PracticeMatchService scoreservice = PracticeMatchService();

  const SecondInningPlayerEntryView(
      {super.key,
      required this.lastRecord,
      required this.match,
      required this.battingTeamId,
      required this.bowlingTeamId});

  @override
  State<SecondInningPlayerEntryView> createState() =>
      _SecondInningPlayerEntryViewState();
}

class _SecondInningPlayerEntryViewState
    extends State<SecondInningPlayerEntryView> {
  final TextEditingController _strikerController = TextEditingController();
  final TextEditingController _nonStrikerController = TextEditingController();
  final TextEditingController _bowlerController = TextEditingController();

  final FocusNode _strikerFocusNode = FocusNode();
  final FocusNode _nonStrikerFocusNode = FocusNode();
  final FocusNode _bowlerFocusNode = FocusNode();

  List<String> battingTeamPlayers = [];
  List<String> bowlingTeamPlayers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    final battingPlayers =
        await Provider.of<PracticeMatchviewModel>(context, listen: false)
            .getAllPlayersInTeam(widget.battingTeamId);

    final bowlingPlayers =
        await Provider.of<PracticeMatchviewModel>(context, listen: false)
            .getAllPlayersInTeam(widget.bowlingTeamId);

    setState(() {
      battingTeamPlayers = battingPlayers;
      bowlingTeamPlayers = bowlingPlayers;
    });
  }

  List<String> getFilteredPlayers(String field) {
    List<String> filteredPlayers = List.from(battingTeamPlayers);
    if (field == 'striker' && _nonStrikerController.text.isNotEmpty) {
      filteredPlayers.remove(_nonStrikerController.text);
    } else if (field == 'nonStriker' && _strikerController.text.isNotEmpty) {
      filteredPlayers.remove(_strikerController.text);
    }
    return filteredPlayers;
  }

  void _startMatch() async {
    final striker = _strikerController.text.trim();
    final nonStriker = _nonStrikerController.text.trim();
    final bowler = _bowlerController.text.trim();
    // if (_strikerController.text.isEmpty ||
    //     _nonStrikerController.text.isEmpty ||
    //     _bowlerController.text.isEmpty) {
    //   showSnackBar(context, 'Fields cannot be empty', Colors.red);
    //   return;
    // }
    print("Striker: $striker");
    print("Non-Striker: $nonStriker");
    print("Bowler: $bowler");

    if (striker.isEmpty || nonStriker.isEmpty || bowler.isEmpty) {
      showSnackBar(context, 'Fields cannot be empty', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await scoreservice
          .newPlayerEntryInningend(
            _strikerController.text,
            _nonStrikerController.text,
            _bowlerController.text,
            widget.lastRecord,
          )
          .then(
            (value) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PracticeMatchScoreScreen(entity: widget.match),
              ),
            ),
          );
    } catch (e) {
      // Handle errors (e.g., show a snackbar)
      showSnackBar(context, 'Error starting match: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showSnackBar(BuildContext context, String msg, Color color) {
    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[200],
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF219ebc),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          "Select players for 2nd Innings",
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),
        ),
      ),
      body: _buildTextFieldsAndButton(),
    );
  }

  Widget _buildTextFieldsAndButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 1),
              blurRadius: 0.5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildAutocompleteTextField(
                  _strikerController, 'Striker', _strikerFocusNode, 'striker'),
              const SizedBox(height: 10),
              _buildAutocompleteTextField(_nonStrikerController, 'Non-Striker',
                  _nonStrikerFocusNode, 'nonStriker'),
              const SizedBox(height: 10),
              _buildAutocompleteTextField(
                  _bowlerController, 'Bowler', _bowlerFocusNode, 'bowler'),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: 150,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startMatch,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Start Match',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteTextField(TextEditingController controller,
      String label, FocusNode focusNode, String field) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        List<String> data;
        if (field == 'bowler') {
          data = bowlingTeamPlayers; // Use preloaded data
        } else {
          data = getFilteredPlayers(field);
        }

        if (textEditingValue.text.isEmpty) {
          return data;
        }
        return data.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }).toList();
      },
      onSelected: (String selection) {
        controller.text = selection;
        print('$label selected: $selection');
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
          textEditingController.text = controller.text;
        return TextField(
          controller: textEditingController,
          focusNode: fieldFocusNode,
          onChanged: (value) {
          controller.text = value; // Sync controller when text changes
        },
          decoration: InputDecoration(
            labelText: label,
            border: const UnderlineInputBorder(),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          style: const TextStyle(color: Colors.black),
        );
      },
    );
  }
}
