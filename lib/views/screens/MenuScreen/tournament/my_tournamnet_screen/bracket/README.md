# Tournament Bracket Feature

## Overview
The Tournament Bracket feature provides a visual flow chart for managing tournament progression. It allows users to create single-elimination brackets for groups, track match results, and visualize the tournament flow.

## Architecture

### MVVM Pattern
Following the project's MVVM architecture pattern:

1. **BracketService** (`bracket_service.dart`)
   - Handles API calls for bracket operations
   - Manages bracket creation, updates, and deletion
   - Generates bracket structure for teams

2. **BracketViewModel** (`bracket_view_model.dart`)
   - Manages state and business logic
   - Handles data transformation and validation
   - Provides methods for UI interactions

3. **BracketScreen** (`bracket_screen.dart`)
   - Main UI component
   - Displays bracket visualization
   - Handles user interactions

4. **BracketMatchWidget** (`widgets/bracket_match_widget.dart`)
   - Reusable component for individual matches
   - Displays team names, winners, and action buttons

## Features

### 1. Group Selection
- Dropdown to select tournament groups
- Fetches teams for selected group
- Validates group has sufficient teams for bracket

### 2. Bracket Creation
- Automatically generates single-elimination bracket structure
- Handles odd number of teams with byes
- Random team seeding for fair competition

### 3. Visual Bracket Display
- Horizontal scrolling layout
- Rounds displayed as columns
- Matches shown as cards with team names
- Color-coded status indicators:
  - White: Pending matches
  - Blue: Ready to play
  - Green: Completed matches

### 4. Match Management
- Select winners for ready matches
- Automatic progression to next round
- Visual indicators for winners and losers
- Real-time bracket updates

### 5. Bracket Operations
- Delete entire bracket
- Reset match results
- Share bracket (future feature)
- Refresh bracket data

## API Endpoints

The bracket service uses the following endpoints:

- `POST /tournament/bracket/create` - Create new bracket
- `GET /tournament/bracket/{tournamentId}/{groupName}` - Get bracket for group
- `PUT /tournament/bracket/match/{matchId}/result` - Update match result
- `GET /tournament/bracket/all/{tournamentId}` - Get all brackets for tournament
- `DELETE /tournament/bracket/{bracketId}` - Delete bracket

## Usage

### Adding to Tournament Screen
The bracket feature is integrated as a new tab in the `MyMatchById` screen:

```dart
TabBarView(controller: _tabController, children: [
  MatchesScreen(tourId: widget.tournament['id']),
  teamsViewWidget(),
  GroupScreen(tournament: widget.tournament),
  BracketScreen(tournament: widget.tournament), // New tab
]),
```

### Creating a Bracket
1. Navigate to the Bracket tab
2. Select a group from the dropdown
3. Click "Create Bracket" button
4. Bracket structure is automatically generated

### Managing Matches
1. For ready matches, click "Team 1" or "Team 2" to select winner
2. Winners automatically progress to next round
3. Continue until final winner is determined

## Data Structure

### Bracket Structure
```json
{
  "id": 1,
  "tournament_id": 123,
  "group_name": "Group A",
  "teams": [
    {"team_name": "Team 1", "team_id": 1},
    {"team_name": "Team 2", "team_id": 2}
  ],
  "structure": [
    {
      "round": 1,
      "match_id": "match_1_1",
      "team1": "Team 1",
      "team2": "Team 2",
      "winner": "Team 1",
      "status": "completed"
    }
  ]
}
```

### Match Status
- `pending`: Match not ready to play
- `ready`: Both teams assigned, ready for result
- `completed`: Match finished, winner determined

## Future Enhancements

1. **Double Elimination Brackets**
2. **Round Robin Support**
3. **Bracket Templates**
4. **Export/Import Brackets**
5. **Advanced Seeding Options**
6. **Match Scheduling Integration**
7. **Real-time Updates**
8. **Bracket Sharing**

## Dependencies

- `provider: ^6.0.5` - State management
- `google_fonts` - Typography
- `dio` - HTTP client (via existing services)

## Notes

- The bracket feature follows the existing MVVM pattern used in the project
- No unnecessary model classes are created, following the user's preference
- API data is directly used in the repository layer
- The feature is designed to be scalable and maintainable 