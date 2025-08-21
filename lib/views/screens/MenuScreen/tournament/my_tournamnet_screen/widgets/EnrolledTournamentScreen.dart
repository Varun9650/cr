import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/my_tournament_view_model.dart';
import 'TournamentGrid.dart';

class EnrolledTournamentScreen extends StatelessWidget {
  const EnrolledTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTournamentViewModel>(
      builder: (context, provider, child) {
        return Scaffold(
          // appBar: AppBar(
          //   title: const Text("Enrolled Tournaments"),
          // ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 👇 yaha sirf grid call karo with isEnrolled = true
                      TournamentGrid(provider: provider, isEnrolled: true),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
