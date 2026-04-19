# JSON Convert Generator

一个 Dart/Flutter 代码生成包，基于 build_runner 自动扫描模型类并生成统一 JSON 转换工具。

## 核心能力

- 自动扫描项目中的模型类并生成类型映射
- 统一的 JSON 到对象、列表到对象列表转换入口
- 支持普通类与泛型类（如 `ApiResponse<T>`）
- 与 json_serializable / freezed 工作流兼容

## 安装

在业务项目的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.13.1
  json_serializable: ^6.0.0
  json_convert_generator:
    path: ../json_convert_generator
```

## 快速开始

### 1) 定义模型

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### 2) 生成代码

```bash
dart run build_runner build --delete-conflicting-outputs
```

生成文件包含：

- `lib/models/*.g.dart`（json_serializable 生成）
- `lib/utils/json_convert.generator.dart`（本包 builder 生成）

### 3) 使用转换工具

```dart
import 'package:your_app/utils/json_convert.generator.dart';

final user = JsonConvert.fromJsonAsT<User>({
  'id': 1,
  'name': 'Tom',
});
```

## 识别规则（重要）

当前 builder 会遍历 `lib/**/*.dart`，并忽略以下文件：

- `*.g.dart`
- `*.freezed.dart`
- `lib/utils/` 下文件

类会被纳入生成映射，当且仅当存在名为 `fromJson` 的 constructor 或 method，且签名满足：

- 仅 1 个参数
- 参数类型为 `Map<String, dynamic>`

## 推荐模型写法

### 普通类

```dart
@JsonSerializable()
class Article {
  final int id;
  final String title;

  Article({required this.id, required this.title});

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
```

### 泛型类

```dart
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final int code;
  final T? data;

  ApiResponse({required this.code, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T?) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
```

## 常见问题

### 没有生成 `json_convert.generator.dart`

请检查：

- 是否执行了 `dart run build_runner build --delete-conflicting-outputs`
- 模型类是否有 `fromJson(Map<String, dynamic>)`
- 文件是否被放在 `lib/utils/`（该目录会被扫描排除）

### build_runner 报 analyzer API 错误

本项目已对不同 analyzer 版本做了兼容处理；如果仍有冲突，建议先执行：

```bash
dart pub upgrade
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## 项目结构

- `lib/json_convert_generator.dart`：包入口
- `lib/src/builder.dart`：自定义 builder 实现
- `lib/src/template.dart`：生成模板
- `build.yaml`：builder 配置
- `example/`：可运行示例

## License

MIT
