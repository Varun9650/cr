import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/my_tournament_view_model.dart';
import 'TournamentGrid.dart';

class CreatedTournamentScreen extends StatelessWidget {
  const CreatedTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTournamentViewModel>(
      builder: (context, provider, child) {
        return Scaffold(
          // appBar: AppBar(
          //   title: const Text("Created Tournaments"),
          // ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TournamentGrid(provider: provider, isEnrolled: false),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
