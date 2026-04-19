import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

/// Article model class
@JsonSerializable()
class Article {
  final int id;
  final String title;
  final String content;
  final String author;
  @JsonKey(name: 'created_at')
  final String createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
