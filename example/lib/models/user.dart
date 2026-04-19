import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model class
@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final int age;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
