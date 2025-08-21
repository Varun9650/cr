import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'points_table_view_model.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsTableScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;
  const PointsTableScreen({Key? key, required this.tournament})
      : super(key: key);

  @override
  State<PointsTableScreen> createState() => _PointsTableScreenState();
}

class _PointsTableScreenState extends State<PointsTableScreen> {
  final TextEditingController _thresholdCtrl = TextEditingController(text: '0');
  String? _targetRound;
  bool _isAdvancing = false;

  @override
  void initState() {
    super.initState();
    // Future.microtask(() =>
    //     context.read<PointsTableViewModel>().init(widget.tournament['id']));
    Future.microtask(() async {
      final vm = context.read<PointsTableViewModel>();
      vm.init(widget.tournament['id']);
      // Refresh data when tab is opened to get updated records
      await vm.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsTableViewModel>(
      builder: (context, vm, _) {
        // _targetRound ??= vm.rounds.isNotEmpty ? vm.rounds.last : null;
        final allowedAdvanceRounds = vm.advanceRounds;
        final effectiveTargetRound =
            (allowedAdvanceRounds.contains(_targetRound))
                ? _targetRound
                : (allowedAdvanceRounds.isNotEmpty
                    ? allowedAdvanceRounds.first
                    : null);
        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: Column(
            children: [
              _buildFilters(vm),
              // Expanded(child: _buildContent(vm)),
              // _buildAdvanceBar(vm),
              _buildAdvanceBar(vm, effectiveTargetRound, allowedAdvanceRounds),
              Expanded(child: _buildStandings(vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(PointsTableViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Points Table',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              IconButton(
                onPressed: () async {
                  await vm.refreshData();
                },
                icon: const Icon(Icons.refresh, color: Colors.black),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Dropdown<String>(
                  label: 'Group',
                  value: vm.selectedGroup,
                  items: vm.groups,
                  // onChanged: (v) => v != null ? vm.setGroup(v) : null,
                  onChanged: (v) async {
                    if (v != null) {
                      vm.setGroup(v);
                      // Refresh data when group changes to get updated records
                      await vm.refreshData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Dropdown<String>(
                  // label: 'Round',
                  label: 'Round (view)',
                  value: vm.selectedRound,
                  items: vm.rounds,
                  onChanged: (v) => v != null ? vm.setRound(v) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceBar(PointsTableViewModel vm, String? effectiveTargetRound,
      List<String> allowedAdvanceRounds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _thresholdCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Min points to qualify'),
              onChanged: (v) => vm.setThreshold(int.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Dropdown<String>(
              label: 'Advance to Round',
              value: effectiveTargetRound,
              items: allowedAdvanceRounds,
              onChanged: (v) => setState(() => _targetRound = v),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            // onPressed: (_targetRound == null || vm.filteredStandings.isEmpty)
            onPressed: (effectiveTargetRound == null ||
                    vm.filteredStandings.isEmpty ||
                    _isAdvancing)
                ? null
                //     : () async {
                //         final target = int.tryParse(
                //                 (_targetRound ?? '').replaceAll('Round ', '')) ??
                //             0;
                //         final assigned =
                //             await vm.advanceSelectedToRound(context, target);
                //         if (mounted) {
                //           ScaffoldMessenger.of(context).showSnackBar(
                //             SnackBar(
                //                 content: Text(
                //                     'Assigned $assigned team slots to Round $target')),
                //           );
                //         }
                //       },
                // child: const Text(
                //   'Send to Round',
                //   style: TextStyle(color: Colors.black),
                // ),
                : () async {
                    setState(() => _isAdvancing = true);
                    try {
                      final target = int.tryParse((effectiveTargetRound)
                              .replaceAll('Round ', '')) ??
                          0;
                      final assigned =
                          await vm.advanceSelectedToRound(context, target);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Assigned $assigned team slots to Round $target')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isAdvancing = false);
                    }
                  },
            child: _isAdvancing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sending...',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  )
                : const Text(
                    'Send to Round',
                    style: TextStyle(color: Colors.black),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandings(PointsTableViewModel vm) {
    final items = vm.filteredStandings;
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text('Error: ${vm.error}'));
    if (items.isEmpty) {
      return const Center(child: Text('No teams meet the threshold'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${items.length} teams',
                style: TextStyle(color: Colors.black),
              ),
              const Spacer(),
              TextButton(
                  onPressed: vm.selectAllFiltered,
                  child: const Text(
                    'Select All',
                    style: TextStyle(color: Colors.black),
                  )),
              TextButton(
                  onPressed: vm.clearSelection,
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = items[index];
              final selected = vm.selectedTeamIds.contains(s.teamId);
              return InkWell(
                onTap: () => vm.toggleTeamSelection(s.teamId),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selected ? Colors.blue : Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                          value: selected,
                          onChanged: (_) => vm.toggleTeamSelection(s.teamId)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0096c7),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(s.teamName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                          child: Text(s.teamName,
                              style: GoogleFonts.getFont('Poppins',
                                  fontWeight: FontWeight.w500))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0096c7),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('${s.points} pts',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  const _Dropdown(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items
              .map((e) =>
                  DropdownMenuItem<T>(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

//   Widget _buildContent(PointsTableViewModel vm) {
//     if (vm.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (vm.error != null) {
//       return Center(
//           child: Text('Error: ${vm.error}',
//               style: const TextStyle(color: Colors.red)));
//     }
//     if (vm.entries.isEmpty) {
//       return const Center(
//           child: Text(
//         'No Teams available',
//         style: const TextStyle(color: Colors.black),
//       ));
//     }

//     // Group entries by match id-like key
//     final Map<String, List<Map<String, dynamic>>> byMatch = {};
//     for (final e in vm.entries) {
//       final matchId =
//           _pickAny(e, ['match_id', 'matchId', 'match', 'match_no', 'matchNo']);
//       byMatch.putIfAbsent(matchId, () => []).add(e);
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: byMatch.keys.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final key = byMatch.keys.elementAt(index);
//         final list = byMatch[key]!
//           ..sort((a, b) => _teamName(a).compareTo(_teamName(b)));
//         return _MatchCard(
//           title: 'Match $key',
//           teams: list!
//               .map((e) => _TeamPoints(
//                     teamName: _teamName(e),
//                     points: _points(e),
//                     played: _intField(e, ['played', 'matches_played', 'mp']),
//                     won: _intField(e, ['won', 'wins', 'w']),
//                     lost: _intField(e, ['lost', 'losses', 'l']),
//                     tied: _intField(e, ['tied', 'tie', 't']),
//                     nrr: _doubleField(e, ['nrr', 'net_run_rate']),
//                   ))
//               .toList(),
//         );
//       },
//     );
//   }

//   String _pickAny(Map<String, dynamic> map, List<String> keys,
//       {String fallback = '-'}) {
//     for (final k in keys) {
//       if (map.containsKey(k) && map[k] != null && map[k].toString().isNotEmpty)
//         return map[k].toString();
//     }
//     return fallback;
//   }

//   String _teamName(Map<String, dynamic> e) =>
//       _pickAny(e, ['team_name', 'teamName', 'team']);
//   int _points(Map<String, dynamic> e) =>
//       _intField(e, ['points', 'pts', 'point']);
//   int _intField(Map<String, dynamic> e, List<String> keys) {
//     for (final k in keys) {
//       final v = e[k];
//       if (v == null) continue;
//       final parsed = int.tryParse(v.toString());
//       if (parsed != null) return parsed;
//     }
//     return 0;
//   }

//   double _doubleField(Map<String, dynamic> e, List<String> keys) {
//     for (final k in keys) {
//       final v = e[k];
//       if (v == null) continue;
//       final parsed = double.tryParse(v.toString());
//       if (parsed != null) return parsed;
//     }
//     return 0;
//   }
// }

// class _Dropdown<T> extends StatelessWidget {
//   final String label;
//   final T? value;
//   final List<T> items;
//   final ValueChanged<T?> onChanged;
//   const _Dropdown(
//       {required this.label,
//       required this.value,
//       required this.items,
//       required this.onChanged});
//   @override
//   Widget build(BuildContext context) {
//     return InputDecorator(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<T>(
//           isExpanded: true,
//           value: value,
//           items: items
//               .map((e) =>
//                   DropdownMenuItem<T>(value: e, child: Text(e.toString())))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }

// class _TeamPoints {
//   final String teamName;
//   final int points;
//   final int played;
//   final int won;
//   final int lost;
//   final int tied;
//   final double nrr;
//   _TeamPoints(
//       {required this.teamName,
//       required this.points,
//       required this.played,
//       required this.won,
//       required this.lost,
//       required this.tied,
//       required this.nrr});
// }

// class _MatchCard extends StatelessWidget {
//   final String title;
//   final List<_TeamPoints> teams;
//   const _MatchCard({required this.title, required this.teams});
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.sports_cricket, color: Colors.blueGrey[700]),
//                 const SizedBox(width: 8),
//                 Text(title,
//                     style: const TextStyle(fontWeight: FontWeight.w600)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...teams.map((t) => _teamRow(t)).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _teamRow(_TeamPoints t) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//               child: Text(t.teamName,
//                   style: GoogleFonts.getFont('Poppins',
//                       fontSize: 14, fontWeight: FontWeight.w500))),
//           Row(
//             children: [
//               _stat('P', t.played.toString()),
//               _stat('W', t.won.toString()),
//               _stat('L', t.lost.toString()),
//               _stat('T', t.tied.toString()),
//               _stat('NRR', t.nrr.toStringAsFixed(2)),
//               Container(
//                 margin: const EdgeInsets.only(left: 8),
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                     color: const Color(0xFF0096c7),
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Text('${t.points} pts',
//                     style: const TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stat(String label, String value) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Row(
//         children: [
//           Text('$label: ', style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
