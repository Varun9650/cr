import '../../../../../resources/api_constants.dart';

class TeamAppUrl {
  static const baseUrl = ApiConstants.baseUrl;

  static const getEntities = '$baseUrl/Teams/Teams';
  static const getMyTeam = '$baseUrl/Teams/Teams/myTeam';
  static const enrollInTeam = '$baseUrl/team/Register_team';

  // Team management endpoints
  static const getEnrolledTeam = '$baseUrl/team/Register_team/enrolled/getAll';
  static const getMyTeamByTourId = '$baseUrl/teams/getMyTeamByTourId/{tourId}';
  static const getAllMembers = '$baseUrl/team/Register_team/member/{teamId}';
  static const updateTag =
      '$baseUrl/team/Register_team/updatetag?data={playerTag}&id={id}';

  // Invitation endpoints
  static const getAllInvitedPlayers =
      '$baseUrl/Invitation_member/Invitation_member/myplayer';
  static const invitePlayer = '$baseUrl/Teams/Teams/invite';
}
