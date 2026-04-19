// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complex_nested_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplexNestedResponse _$ComplexNestedResponseFromJson(
  Map<String, dynamic> json,
) => ComplexNestedResponse(
  requestId: json['request_id'] as String,
  payload: ComplexNestedPayload.fromJson(
    json['payload'] as Map<String, dynamic>,
  ),
  meta: ComplexNestedMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ComplexNestedResponseToJson(
  ComplexNestedResponse instance,
) => <String, dynamic>{
  'request_id': instance.requestId,
  'payload': instance.payload,
  'meta': instance.meta,
};

ComplexNestedPayload _$ComplexNestedPayloadFromJson(
  Map<String, dynamic> json,
) => ComplexNestedPayload(
  team: ComplexNestedTeam.fromJson(json['team'] as Map<String, dynamic>),
  recommendation: ComplexNestedRecommendation.fromJson(
    json['recommendation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ComplexNestedPayloadToJson(
  ComplexNestedPayload instance,
) => <String, dynamic>{
  'team': instance.team,
  'recommendation': instance.recommendation,
};

ComplexNestedTeam _$ComplexNestedTeamFromJson(Map<String, dynamic> json) =>
    ComplexNestedTeam(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
      groups: ComplexNestedGroups.fromJson(
        json['groups'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ComplexNestedTeamToJson(ComplexNestedTeam instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'owner': instance.owner,
      'groups': instance.groups,
    };

ComplexNestedGroups _$ComplexNestedGroupsFromJson(Map<String, dynamic> json) =>
    ComplexNestedGroups(
      active: (json['active'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      archived: (json['archived'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ComplexNestedGroupsToJson(
  ComplexNestedGroups instance,
) => <String, dynamic>{
  'active': instance.active,
  'archived': instance.archived,
};

ComplexNestedRecommendation _$ComplexNestedRecommendationFromJson(
  Map<String, dynamic> json,
) => ComplexNestedRecommendation(
  primaryUser: User.fromJson(json['primary_user'] as Map<String, dynamic>),
  backupUsers: (json['backup_users'] as List<dynamic>)
      .map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ComplexNestedRecommendationToJson(
  ComplexNestedRecommendation instance,
) => <String, dynamic>{
  'primary_user': instance.primaryUser,
  'backup_users': instance.backupUsers,
};

ComplexNestedMeta _$ComplexNestedMetaFromJson(Map<String, dynamic> json) =>
    ComplexNestedMeta(
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$ComplexNestedMetaToJson(ComplexNestedMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'page_size': instance.pageSize,
      'has_next': instance.hasNext,
      'total': instance.total,
    };
