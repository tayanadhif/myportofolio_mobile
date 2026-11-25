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
      throw ApiException(_errorMessage(body, 'Login gagal.'));
    }
    final token = body['token'] ?? body['key'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Respons login tidak berisi token.');
    }
    return token;
  }

  Future<List<Project>> fetchProjects({String? token}) async {
    final response = await _client.get(
      _uri(_projectsPath),
      headers: _headers(token),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(body, 'Gagal memuat proyek.'));
    }
    final items = body is List ? body : body['results'] ?? body['data'];
    if (items is! List) {
      throw const ApiException('Format daftar proyek dari server tidak valid.');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList();
  }

  Future<Project> createProject(Project project, String token) async {
    final response = await _client.post(
      _uri(_projectsPath),
      headers: _headers(token),
      body: jsonEncode(project.toApiJson()),
    );
    final body = _decode(response);
    if (body is! Map<String, dynamic>) {
      throw const ApiException('Format respons proyek tidak valid.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(body, 'Gagal menyimpan proyek.'));
    }
    return Project.fromJson(body);
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      _uri(_logoutPath),
      headers: _headers(token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Logout server gagal (${response.statusCode}).');
    }
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Token $token',
  };

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Respons server bukan JSON yang valid.');
    }
  }

  String _errorMessage(dynamic body, String fallback) {
    if (body is! Map<String, dynamic>) return fallback;
    final detail = body['detail'] ?? body['error'] ?? body['non_field_errors'];
    if (detail is List && detail.isNotEmpty) return detail.join(' ');
    if (detail is String && detail.isNotEmpty) return detail;
    return fallback;
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
