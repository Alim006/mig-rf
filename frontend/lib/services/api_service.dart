import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService storageService;

  static const String baseUrl = 'http://localhost:3000/api/v1';

  ApiService({required this.storageService}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await storageService.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refresh = await storageService.getRefreshToken();
      if (refresh == null) return false;
      final response = await Dio().post('$baseUrl/auth/refresh', data: {'refreshToken': refresh});
      await storageService.saveTokens(
        response.data['accessToken'],
        response.data['refreshToken'],
      );
      return true;
    } catch (_) {
      await storageService.clearTokens();
      return false;
    }
  }

  // Auth
  Future<Map<String, dynamic>> sendSms(String phone) async {
    final r = await _dio.post('/auth/sms/send', data: {'phone': phone});
    return r.data;
  }

  Future<Map<String, dynamic>> registerWithSms(String phone, String code) async {
    final r = await _dio.post('/auth/register/sms', data: {'phone': phone, 'code': code});
    return r.data;
  }

  Future<Map<String, dynamic>> registerWithPassword(String phone, String password) async {
    final r = await _dio.post('/auth/register/password', data: {'phone': phone, 'password': password});
    return r.data;
  }

  Future<Map<String, dynamic>> loginWithPassword(String phone, String password) async {
    final r = await _dio.post('/auth/login/password', data: {'phone': phone, 'password': password});
    return r.data;
  }

  Future<Map<String, dynamic>> loginWithSms(String phone, String code) async {
    final r = await _dio.post('/auth/login/sms', data: {'phone': phone, 'code': code});
    return r.data;
  }

  Future<Map<String, dynamic>> loginWithPin(String userId, String pin) async {
    final r = await _dio.post('/auth/login/pin', data: {'userId': userId, 'pin': pin});
    return r.data;
  }

  Future<void> setPin(String pin, String pinConfirm) async {
    await _dio.post('/auth/pin/set', data: {'pin': pin, 'pinConfirm': pinConfirm});
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  // Profile
  Future<Map<String, dynamic>> getProfile() async {
    final r = await _dio.get('/users/me');
    return r.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final r = await _dio.put('/users/me', data: data);
    return r.data;
  }

  Future<void> setVisitType(String visitType) async {
    await _dio.post('/users/me/visit-type', data: {'visitType': visitType});
  }

  Future<List<dynamic>> getWorkflowSteps() async {
    final r = await _dio.get('/users/me/steps');
    return r.data;
  }

  // Documents
  Future<Map<String, dynamic>> uploadDocument(String filePath, String type) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': type,
    });
    final r = await _dio.post('/documents/upload', data: formData);
    return r.data;
  }

  Future<List<dynamic>> getDocuments() async {
    final r = await _dio.get('/documents');
    return r.data;
  }

  // QR
  Future<Map<String, dynamic>> generateQr() async {
    final r = await _dio.get('/qr/generate');
    return r.data;
  }

  // Admin
  Future<Map<String, dynamic>> adminLogin(String login, String password) async {
    final r = await _dio.post('/auth/admin/login', data: {'login': login, 'password': password});
    return r.data;
  }

  Future<Map<String, dynamic>> verifyQr(String token) async {
    final r = await _dio.get('/qr/verify', queryParameters: {'token': token});
    return r.data;
  }

  Future<Map<String, dynamic>> getAdminUsers({int page = 1, String? status}) async {
    final r = await _dio.get('/admin/users', queryParameters: {'page': page, if (status != null) 'status': status});
    return r.data;
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final r = await _dio.get('/admin/stats');
    return r.data;
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await _dio.patch('/admin/users/$userId/status', data: {'status': status});
  }
}
