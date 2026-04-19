import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'complex_nested_response.g.dart';

@JsonSerializable()
class ComplexNestedResponse {
  const ComplexNestedResponse({
    required this.requestId,
    required this.payload,
    required this.meta,
  });

  @JsonKey(name: 'request_id')
  final String requestId;
  final ComplexNestedPayload payload;
  final ComplexNestedMeta meta;

  factory ComplexNestedResponse.fromJson(Map<String, dynamic> json) =>
      _$ComplexNestedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexNestedResponseToJson(this);
}

@JsonSerializable()
class ComplexNestedPayload {
  const ComplexNestedPayload({
    required this.team,
    required this.recommendation,
  });

  final ComplexNestedTeam team;
  final ComplexNestedRecommendation recommendation;

  factory ComplexNestedPayload.fromJson(Map<String, dynamic> json) =>
      _$ComplexNestedPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexNestedPayloadToJson(this);
}

@JsonSerializable()
class ComplexNestedTeam {
  const ComplexNestedTeam({
    required this.id,
    required this.name,
    required this.owner,
    required this.groups,
  });

  final int id;
  final String name;
  final User owner;
  final ComplexNestedGroups groups;

  factory ComplexNestedTeam.fromJson(Map<String, dynamic> json) =>
      _$ComplexNestedTeamFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexNestedTeamToJson(this);
}

@JsonSerializable()
class ComplexNestedGroups {
  const ComplexNestedGroups({required this.active, required this.archived});

  final List<User> active;
  final List<User> archived;

  factory ComplexNestedGroups.fromJson(Map<String, dynamic> json) =>
      _$ComplexNestedGroupsFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexNestedGroupsToJson(this);
}

@JsonSerializable()
class ComplexNestedRecommendation {
  const ComplexNestedRecommendation({
    required this.primaryUser,
    required this.backupUsers,
  });

  @JsonKey(name: 'primary_user')
  final User primaryUser;

  @JsonKey(name: 'backup_users')
  final List<User> backupUsers;

  factory ComplexNestedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ComplexNestedRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexNestedRecommendationToJson(this);
}

@JsonSerializable()
class ComplexNestedMeta {
  const ComplexNestedMeta({
    required this.page,
    required this.pageSize,
    required this.hasNext,
    required this.total,
  });

  final int page;

  @JsonKey(name: 'page_size')
  final int pageSize;

  @JsonKey(name: 'has_next')
  final bool hasNext;

  final int total;

  factory ComplexNestedMeta.fromJson(Map<String, dynamic> json) =>
      _$ComplexNestedMetaFromJson(json);

  Map<String, dynamic> toJson() => _$ComplexNestedMetaToJson(this);
}
