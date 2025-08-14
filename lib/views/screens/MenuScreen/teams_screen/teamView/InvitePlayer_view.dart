// ignore_for_file: use_build_context_synchronously

// MVVM Structure: View only - No direct API calls
// All API calls are handled through Repository -> ViewModel -> View
import 'package:confetti/confetti.dart';
// import 'package:cricyard/core/app_export.dart'; // Not needed in View
import 'package:cricyard/theme/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../ReuseableWidgets/BottomAppBarWidget.dart';
import '../teamViewModel/invite_player_view_model.dart';
// import '../teamModel/invite_player_model.dart'; // Not needed in View

class InvitePlayerView extends StatefulWidget {
  InvitePlayerView(this.teamId, {super.key});
  final int teamId;

  @override
  _InvitePlayerViewState createState() => _InvitePlayerViewState();
}

class _InvitePlayerViewState extends State<InvitePlayerView> {
  final TextEditingController _controller = TextEditingController();
  late InvitePlayerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = InvitePlayerViewModel();
    _viewModel.initializeData(widget.teamId.toString());
  }

  void _showCustomSnackBar(
      BuildContext context, String message, bool isSuccess) {
    final overlay = Overlay.of(context);
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.white : Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: isSuccess ? Colors.black : Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          if (isSuccess)
            Center(
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                ],
              ),
            ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    if (isSuccess) {
      confettiController.play();
    }

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
      confettiController.dispose();
    });
  }

  Future<void> _handleSendInvite() async {
    if (_controller.text.isEmpty) {
      _showCustomSnackBar(context, 'Please enter a mobile number', false);
      return;
    }

    try {
      final response =
          await _viewModel.sendInvite(_controller.text, widget.teamId);

      if (response == 'Invitation  Sent') {
        _showCustomSnackBar(context, 'Invitation sent successfully!', true);
        _controller.clear();
        _viewModel.resetSearch();
      } else if (response == 'Invitation Already Sent') {
        _showCustomSnackBar(context, 'Invitation Already Sent!', false);
      } else {
        _showCustomSnackBar(context, 'Failed to send invite.', false);
      }
    } catch (e) {
      _showCustomSnackBar(context, 'Error: ${e.toString()}', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<InvitePlayerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              elevation: 0,
              forceMaterialTransparency: true,
              backgroundColor: Colors.grey[200],
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF219ebc),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              title: Text(
                "Invite players",
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // SEARCH BAR START
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.search, color: Colors.black),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: 'Enter mobile number',
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      //search button
                      Container(
                        height: 48.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: const Color(0xFF264653)),
                        child: ElevatedButton(
                          onPressed: viewModel.isSearching
                              ? null
                              : () {
                                  viewModel.searchUser(_controller.text);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: viewModel.isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Search',
                                  style: GoogleFonts.getFont('Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                        ),
                      ),
                    ],
                  ),
                  // SEARCH BAR END
                  const SizedBox(height: 16.0),

                  // Search Results
                  if (viewModel.searchedUser.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          viewModel.searchedUser['found'] == true
                              ? '${viewModel.searchedUser['fullName'] ?? 'Unknown'}'
                              : 'User not found but you can still send invite',
                          style: CustomTextStyles.titleMediumPoppins,
                        ),
                        const SizedBox(height: 16.0),

                        // Invite button
                        SizedBox(
                          height: 50,
                          width: 70,
                          child: viewModel.isInviting
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _handleSendInvite,
                                  style: const ButtonStyle(
                                      elevation: MaterialStatePropertyAll(1),
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color(0xFF264653))),
                                  child: Text(
                                    viewModel.isInvited ? 'ReInvite' : 'Invite',
                                    style: CustomTextStyles
                                        .titleSmallPoppinsBlack900,
                                  ),
                                ),
                        ),
                      ],
                    ),

                  // Error Message
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Invited Players List
                  viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.invitedPlayers.isEmpty
                          ? Text(
                              "No players Invited yet!! ",
                              style: GoogleFonts.getFont('Poppins',
                                  color: Colors.black, fontSize: 20),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: viewModel.invitedPlayers.length,
                                itemBuilder: (context, index) {
                                  final data = viewModel.invitedPlayers[index];

                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          '${index + 1}.',
                                          style: GoogleFonts.getFont('Poppins',
                                              color: Colors.black),
                                        ),
                                        const SizedBox(width: 10),
                                        const CircleAvatar(
                                          radius: 20,
                                          child: Icon(Icons.person),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            data['player_name']?.toString() ??
                                                'Unknown Player',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: (index <
                                                      viewModel.isReInvitingList
                                                          .length &&
                                                  viewModel
                                                      .isReInvitingList[index])
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : ElevatedButton(
                                                  style: const ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStatePropertyAll(
                                                              Color(
                                                                  0xFF264653))),
                                                  onPressed: () {
                                                    viewModel.reInvitePlayer(
                                                      index,
                                                      data['mob_number']
                                                              ?.toString() ??
                                                          '',
                                                      widget.teamId,
                                                    );
                                                  },
                                                  child: Text(
                                                    'Re invite',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBarWidget(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}
