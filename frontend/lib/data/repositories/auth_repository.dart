import '../../core/api/api_client.dart';
import '../../core/services/auth_service.dart';

class AuthRepository {
  final _api = ApiClient();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    final data = response.data;
    if (data['success'] == true) {
      final authData = data['data'];
      await AuthService.saveAuth(
        authData['token'],
        authData['refresh_token'],
        authData['user'],
      );
    }
    
    return data;
  }
  
  Future<Map<String, dynamic>> getMe() async {
    final response = await _api.get('/auth/me');
    return response.data;
  }
  
  Future<void> logout() async {
    await AuthService.clear();
  }
}