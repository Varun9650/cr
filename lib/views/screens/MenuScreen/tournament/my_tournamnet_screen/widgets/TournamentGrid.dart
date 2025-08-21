import 'package:cricyard/core/utils/image_constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../views/inviteTeam_screen.dart';
import '../MyMatchById.dart';
import '../viewmodel/my_tournament_view_model.dart';

class TournamentGrid extends StatelessWidget {
  final MyTournamentViewModel provider;
  final bool isEnrolled;

  const TournamentGrid({
    Key? key,
    required this.provider,
    required this.isEnrolled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // final tournaments = provider.myTournaments.reversed.toList();
    final tournaments = isEnrolled
        ? provider.enrolledTournaments.reversed.toList()
        : provider.myTournaments.reversed.toList();
    print("Tournaments: ${tournaments.length}");

    if (tournaments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            isEnrolled
                ? "No tournaments enrolled yet."
                : "No tournaments created yet.",

            // "No tournaments created yet.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tournaments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8, // Smaller card (more square, less tall)
        ),
        itemBuilder: (context, index) {
          final tournament = tournaments[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyMatchById(
                      tournament: tournament, isEnrolled: isEnrolled),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.18),
                    blurRadius: 5,
                    spreadRadius: 1.5,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Centered image (smaller)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Image.asset(
                      ImageConstant.imgAward,
                      fit: BoxFit.contain,
                      width: 48,
                      height: 48,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tournament name and invite icon

                        // Tournament name and invite icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                tournament['tournament_name'] ?? "No Name",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (!isEnrolled)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          InviteTeamScreen(tournament['id']),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.group_add,
                                      color: Colors.black, size: 18),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          tournament['tournament_name'] ?? "No Name",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Venue
                        Text(
                          tournament['venues'] ?? "No Venue",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Date
                        Text(
                          tournament['dates'] ?? "No Date",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // View Details button-style text
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "View Details",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
