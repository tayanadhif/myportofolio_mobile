import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/project.dart';

/// HTTP boundary for the Django REST API.
/// Set API_BASE_URL with --dart-define when running on a device/emulator.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const _tokenPath = String.fromEnvironment(
    'API_TOKEN_PATH',
    defaultValue: '/api-token-auth/',
  );
  static const _registerPath = String.fromEnvironment(
    'API_REGISTER_PATH',
    defaultValue: '/api/v1/auth/register/',
  );
  static const _googleTokenPath = String.fromEnvironment(
    'API_GOOGLE_TOKEN_PATH',
    defaultValue: '/api/v1/auth/google/',
  );
  static const _projectsPath = String.fromEnvironment(
    'API_PROJECTS_PATH',
    defaultValue: '/api/v1/projects/',
  );
  static const _logoutPath = String.fromEnvironment(
    'API_LOGOUT_PATH',
    defaultValue: '/api/logout/',
  );

  final http.Client _client;
  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Map<String, dynamic>>> getSection(
    String section, {
    String? token,
  }) async {
    final response = await _client.get(
      _sectionUri(section),
      headers: _headers(token),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(body, 'Gagal memuat $section.'),
        statusCode: response.statusCode,
      );
    }
    final items = body is List
        ? body
        : body is Map<String, dynamic>
        ? body['results'] ?? body['data']
        : null;
    if (items is! List) {
      throw ApiException('Format daftar $section dari server tidak valid.');
    }
    if (items.any((item) => item is! Map<String, dynamic>)) {
      throw ApiException('Format entri $section dari server tidak valid.');
    }
    return items
        .cast<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> postSection(
    String section,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _client.post(
      _sectionUri(section),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(body, 'Gagal menyimpan $section.'),
        statusCode: response.statusCode,
      );
    }
    if (body is! Map<String, dynamic>) {
      throw ApiException('Format respons $section dari server tidak valid.');
    }
    return body;
  }

  Future<String> login(String username, String password) async {
    final response = await _client.post(
      _uri(_tokenPath),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = _decode(response);
    if (body is! Map<String, dynamic>) {
      throw const ApiException('Format respons login tidak valid.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(body, 'Login gagal.'),
        statusCode: response.statusCode,
      );
    }
    final token = body['token'] ?? body['key'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Respons login tidak berisi token.');
    }
    return token;
  }

  Future<String> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _client.post(
      _uri(_registerPath),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'username': username,
        'email': email,
        'password1': password,
        'password2': passwordConfirmation,
      }),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(body, 'Registrasi gagal.'),
        statusCode: response.statusCode,
      );
    }
    if (body is! Map<String, dynamic>) {
      throw const ApiException('Format respons registrasi tidak valid.');
    }
    final token = body['token'] ?? body['key'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Respons registrasi tidak berisi token.');
    }
    return token;
  }

  Future<String> loginWithGoogle(String idToken) async {
    final response = await _client.post(
      _uri(_googleTokenPath),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id_token': idToken}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(body, 'Google Sign-In gagal.'),
        statusCode: response.statusCode,
      );
    }
    if (body is! Map<String, dynamic>) {
      throw const ApiException('Format respons Google login tidak valid.');
    }
    final token = body['token'] ?? body['key'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Respons Google login tidak berisi token.');
    }
    return token;
  }

  Future<List<Project>> fetchProjects({String? token}) async {
    final projects = await getSection('projects', token: token);
    return projects.map(Project.fromJson).toList();
  }

  Future<Project> createProject(Project project, String token) async {
    final body = await postSection('projects', project.toApiJson(), token);
    return Project.fromJson(body);
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      _uri(_logoutPath),
      headers: _headers(token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Logout server gagal (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Token $token',
  };

  Uri _sectionUri(String section) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(section)) {
      throw ArgumentError.value(section, 'section', 'Invalid API section name');
    }
    if (section == 'projects') return _uri(_projectsPath);
    return _uri('/api/v1/$section/');
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Respons server bukan JSON yang valid.',
        statusCode: response.statusCode,
      );
    }
  }

  String _errorMessage(dynamic body, String fallback) {
    if (body is! Map<String, dynamic>) return fallback;
    final detail = body['detail'] ?? body['error'] ?? body['non_field_errors'];
    if (detail is List && detail.isNotEmpty) return detail.join(' ');
    if (detail is String && detail.isNotEmpty) return detail;
    for (final entry in body.entries) {
      final errors = entry.value;
      if (errors is List && errors.isNotEmpty) {
        return '${entry.key}: ${errors.join(' ')}';
      }
      if (errors is String && errors.isNotEmpty) {
        return '${entry.key}: $errors';
      }
    }
    return fallback;
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}
