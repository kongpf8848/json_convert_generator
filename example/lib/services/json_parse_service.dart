import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/api_response.dart';
import '../models/complex_nested_response.dart';
import '../models/user.dart';
import '../utils/json_convert.generator.dart';

/// Demo 1: 从内存 Map 解析单个对象
class ParseFromMapExample {
  static User? parseUser() {
    final Map<String, dynamic> json = {
      'id': 10,
      'name': '内存用户',
      'email': 'memory@example.com',
      'age': 22,
    };
    return JsonConvert.fromJsonAsT<User>(json);
  }
}

/// Demo 2: 从内存 List 解析对象列表
class ParseListFromMapExample {
  static List<User>? parseUserList() {
    final List<Map<String, dynamic>> jsonList = [
      {'id': 1, 'name': '用户A', 'email': 'a@example.com', 'age': 20},
      {'id': 2, 'name': '用户B', 'email': 'b@example.com', 'age': 25},
      {'id': 3, 'name': '用户C', 'email': 'c@example.com', 'age': 30},
    ];
    return JsonConvert.fromJsonAsT<List<User>>(jsonList);
  }
}

/// Demo 3 & 4: 解析 ApiResponse，泛型分别为对象和列表
class ParseApiResponseExample {
  /// ApiResponse<User> —— 泛型为单个对象
  static ApiResponse<User>? parseApiResponseUser() {
    final Map<String, dynamic> json = {
      'code': 200,
      'message': 'success',
      'data': {
        'id': 99,
        'name': 'API用户',
        'email': 'api@example.com',
        'age': 35,
      },
    };
    return ApiResponse.fromJson(
      json,
      (data) => JsonConvert.fromJsonAsT<User>(data)!,
    );
  }

  /// ApiResponse<List<User>> —— 泛型为列表
  static ApiResponse<List<User>>? parseApiResponseUserList() {
    final Map<String, dynamic> json = {
      'code': 200,
      'message': 'success',
      'data': [
        {'id': 1, 'name': '列表用户A', 'email': 'la@example.com', 'age': 20},
        {'id': 2, 'name': '列表用户B', 'email': 'lb@example.com', 'age': 28},
      ],
    };
    return ApiResponse.fromJson(json, (data) {
      return JsonConvert.fromJsonAsT<List<User>>(data)!;
    });
  }
}

/// Demo 5 & 6: 从 assets 读取 JSON 并解析 ApiResponse
class ParseFromAssetsExample {
  /// 从 assets/api_response_user.json 解析 ApiResponse<User>
  static Future<ApiResponse<User>?> loadApiResponseUser() async {
    final String jsonString = await rootBundle.loadString(
      'assets/api_response_user.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ApiResponse.fromJson(
      json,
      (data) => JsonConvert.fromJsonAsT<User>(data)!,
    );
  }

  /// 从 assets/api_response_users.json 解析 ApiResponse<List<User>>
  static Future<ApiResponse<List<User>>?> loadApiResponseUserList() async {
    final String jsonString = await rootBundle.loadString(
      'assets/api_response_users.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ApiResponse.fromJson(json, (data) {
      return JsonConvert.fromJsonAsT<List<User>>(data)!;
    });
  }
}

/// Demo 7: 解析复杂嵌套 JSON 结构
class ParseComplexNestedExample {
  static Future<ComplexNestedResponse?> loadComplexNestedData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/complex_nested_users.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return JsonConvert.fromJsonAsT<ComplexNestedResponse>(json);
  }
}
