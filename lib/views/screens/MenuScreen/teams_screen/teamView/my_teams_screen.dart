import 'dart:async';

import 'package:cricyard/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../teamViewModel/team_viewmodel.dart';
import '../teamModel/team_model.dart';
import '../teamModel/player_model.dart';
import '../utils/sport_images.dart';
import '../utils/sport_categories.dart';
import 'widget/myteam_item_widget.dart';

class MyTeamScreen extends StatefulWidget {
  @override
  _MyTeamScreenState createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen>
    with TickerProviderStateMixin {
  late TeamViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    _viewModel = TeamViewModel();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _tabController.addListener(_handleTabChange);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _viewModel.initialize();
  }

  void _handleTabChange() {
    _viewModel.setCurrentTab(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.status == TeamStatus.error) {
            return _buildErrorState();
          }

          return Column(
            children: [
              _buildTabView(),
              Expanded(
                child: _viewModel.isTeamLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF219ebc)),
                        ),
                      )
                    : _buildTabContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      forceMaterialTransparency: true,
      title: Padding(
        padding: EdgeInsets.only(left: 20.h),
        child: Text(
          "My Team",
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF219ebc),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        _buildEnrolledTabView(true),
        _buildCreatedTabView(),
      ],
    );
  }

  Widget _buildTabView() {
    return Container(
      height: 56.v,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0096c7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: "Enrolled",
              isSelected: _tabController.index == 0,
              onTap: () => _tabController.animateTo(0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: "Created",
              isSelected: _tabController.index == 1,
              onTap: () => _tabController.animateTo(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(4),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.getFont(
              'Poppins',
              color: isSelected ? const Color(0xFF0096c7) : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: isSelected ? 16 : 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatedTabView() {
    if (_viewModel.myTeams.isEmpty) {
      return _buildEmptyState("No Teams Created Yet!", Icons.group_add);
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.refresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          if (isLandscape) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      SizedBox(height: 20.v),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildTeamCardList(_viewModel.myTeams, false),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      SizedBox(height: 20.v),
                      Expanded(
                        child: _buildTeamMembersSection(false),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.v),
                  _buildTeamCardList(_viewModel.myTeams, false),
                  SizedBox(height: 20.v),
                  _buildTeamMembersSection(false),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEnrolledTabView(bool isEnrolled) {
    if (_viewModel.enrolledTeams.isEmpty) {
      return _buildEmptyState("No Teams Enrolled Yet!", Icons.sports_soccer);
    }
    print('enroll ${_viewModel.enrolledTeams}');
    return RefreshIndicator(
      onRefresh: () => _viewModel.refresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          if (isLandscape) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      SizedBox(height: 20.v),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildTeamCardList(
                              _viewModel.enrolledTeams, true),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      SizedBox(height: 20.v),
                      Expanded(
                        child: _buildTeamMembersSection(isEnrolled),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.v),
                  _buildTeamCardList(_viewModel.enrolledTeams, true),
                  SizedBox(height: 20.v),
                  _buildTeamMembersSection(isEnrolled),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start creating or joining teams to see them here",
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _viewModel.errorMessage,
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _viewModel.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF219ebc),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCardList(List<TeamModel> teams, bool isEnrolled) {
    print('teams $teams');
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: isLandscape ? constraints.maxHeight * 0.8 : 210.v,
            child: ListView.separated(
              padding: EdgeInsets.only(left: 20.h),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(width: 12.h),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                return myteam_item_widget(
                  teamData: teams[index].toJson(),
                  onTap: () {
                    _viewModel.selectTeam(index, isEnrolled);
                    // if (isEnrolled) {
                    //   print('Enrolled team selected: ${teams[index].teamId}');
                    //   print('Is index: ${teams[index]}');
                    //   _viewModel.selectTeam(
                    //       teams[index].teamId as int, isEnrolled);
                    // } else {
                    //   _viewModel.selectTeam(index, isEnrolled);
                    // }
                  },
                  isEnrolled: isEnrolled,
                  players: _viewModel.teamMembers.length,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamMembersSection(bool isEnrolled) {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF219ebc)),
        ),
      );
    }

    if (_viewModel.teamMembers.isEmpty) {
      final currentTeam = _viewModel.getCurrentTeam();
      return _buildNoPlayersWidget(currentTeam?.teamName ?? 'Team');
    }

    return _buildTeamMembersUI(isEnrolled);
  }

  Widget _buildNoPlayersWidget(String teamName) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No Players in $teamName",
              style: GoogleFonts.getFont(
                'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add players to your team to see them here",
              style: GoogleFonts.getFont(
                'Poppins',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMembersUI(bool isEnrolled) {
    final sport = _viewModel.preferredSport;
    final playerImage = SportImages.getPlayerImage(sport);
    final sportColor = SportImages.getSportColor(sport);
    final sportAccentColor = SportImages.getSportAccentColor(sport);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: isLandscape
              ? double.infinity
              : MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                sportColor.withOpacity(0.1),
                sportAccentColor.withOpacity(0.05),
                Colors.white.withOpacity(0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: sportColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: sportColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sportColor.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sportAccentColor.withOpacity(0.1),
                  ),
                ),
              ),
              // Subtle pattern overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.5,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header section
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sportColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: sportColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getSportIcon(sport),
                            color: sportColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${sport.toUpperCase()} TEAM',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: sportColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Team members sections
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: _buildAllCategorySections(
                              playerImage, sportColor, isEnrolled),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'badminton':
        return Icons.sports_tennis;
      case 'tennis':
        return Icons.sports_tennis;
      case 'hockey':
        return Icons.sports_hockey;
      default:
        return Icons.sports;
    }
  }

  List<Widget> _buildAllCategorySections(
      String playerImage, Color sportColor, bool isEnrolled) {
    final categories = _viewModel.getCategories();
    final maxPlayers =
        SportCategories.getCategoryMaxPlayers(_viewModel.preferredSport);

    // If no categories (like badminton), show all players in a single section
    if (categories.isEmpty) {
      final totalMaxPlayers =
          maxPlayers.values.isNotEmpty ? maxPlayers.values.first : 8;
      return [
        _buildAllPlayersSection(
            totalMaxPlayers, playerImage, sportColor, isEnrolled)
      ];
    }

    List<Widget> sections = [];
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      sections.add(_buildCategorySection(category, maxPlayers[category] ?? 0,
          playerImage, sportColor, isEnrolled));

      // Add spacing between sections (except for the last one)
      if (i < categories.length - 1) {
        sections.add(const SizedBox(height: 16));
      }
    }

    return sections;
  }

  Widget _buildAllPlayersSection(
      int maxPlayers, String playerImage, Color sportColor, bool isEnrolled) {
    final players = _viewModel.teamMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: sportColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sportColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Team Players (${players.length}/$maxPlayers)',
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: sportColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: maxPlayers,
          itemBuilder: (context, index) {
            if (index < players.length) {
              return _buildPlayerCard(
                  players[index], playerImage, sportColor, isEnrolled);
            } else {
              return _buildEmptyPlayerCard(playerImage, sportColor);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(String category, int maxPlayers,
      String playerImage, Color sportColor, bool isEnrolled) {
    final players = _viewModel.getPlayersByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: sportColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sportColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            category,
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: sportColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(maxPlayers, (index) {
            if (index < players.length) {
              return _buildPlayerCard(
                  players[index], playerImage, sportColor, isEnrolled);
            } else {
              return _buildEmptyPlayerCard(playerImage, sportColor);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerModel player, String playerImage,
      Color sportColor, bool isEnrolled) {
    final sport = _viewModel.preferredSport;
    final isBadminton = sport.toLowerCase() == 'badminton';

    return GestureDetector(
      onTap: () => {if (!isEnrolled) _showPlayerOptions(player)},
      child: Container(
        height: isBadminton ? 80 : 100,
        width: isBadminton ? 70 : 90,
        padding: EdgeInsets.all(isBadminton ? 6 : 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: sportColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: sportColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: isBadminton ? 40 : 50,
              width: isBadminton ? 40 : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sportColor.withOpacity(0.1),
                border: Border.all(
                  color: sportColor.withOpacity(0.2),
                  width: isBadminton ? 1.5 : 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  playerImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                player.playerName,
                style: GoogleFonts.getFont(
                  'Poppins',
                  color: Colors.black87,
                  fontSize: isBadminton ? 9 : 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (player.playerTag.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sportColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sportColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  player.playerTag,
                  style: GoogleFonts.getFont(
                    'Poppins',
                    color: sportColor,
                    fontSize: isBadminton ? 7 : 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlayerCard(String playerImage, Color sportColor) {
    final sport = _viewModel.preferredSport;
    final isBadminton = sport.toLowerCase() == 'badminton';

    return Container(
      height: isBadminton ? 80 : 100,
      width: isBadminton ? 70 : 90,
      padding: EdgeInsets.all(isBadminton ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sportColor.withOpacity(0.2),
          width: 1,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: sportColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sportColor.withOpacity(0.05),
              border: Border.all(
                color: sportColor.withOpacity(0.2),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: sportColor.withOpacity(0.5),
              size: isBadminton ? 20 : 24,
            ),
          ),
          if (sport.toLowerCase() != 'badminton') ...[
            const SizedBox(height: 6),
            Text(
              "Add Player",
              style: GoogleFonts.getFont(
                'Poppins',
                color: sportColor.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showPlayerOptions(PlayerModel player) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Assign Role",
            style: GoogleFonts.getFont('Poppins', color: Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildRoleButtons(player),
          ),
        );
      },
    );
  }

  List<Widget> _buildRoleButtons(PlayerModel player) {
    final roles = _viewModel.getRoles();
    final roleCodes = _viewModel.getRoleCodes();
    final roleIcons = _viewModel.getRoleIcons();
    final roleColors = _viewModel.getRoleColors();

    return roles.map((role) {
      final roleCode = roleCodes[role] ?? role;
      final icon = roleIcons[role] ?? Icons.person;
      final color = roleColors[role] ?? Colors.blue;

      return _buildRoleButton(role, roleCode, icon, color, player);
    }).toList();
  }

  Widget _buildRoleButton(String title, String role, IconData icon, Color color,
      PlayerModel player) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: () async {
          Navigator.pop(context);
          try {
            final playerIndex =
                _viewModel.teamMembers.indexWhere((p) => p.id == player.id);
            if (playerIndex != -1) {
              await _viewModel.assignRole(playerIndex, role);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title role assigned successfully'),
                  backgroundColor: color,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to assign role: $e'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: GoogleFonts.getFont('Poppins',
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
