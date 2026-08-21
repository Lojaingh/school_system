import 'package:school_management/data/model/profile_model.dart';
import '../model/login_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<LoginResponse> login(
    String userName,
    String password,
  ) async {
    try {
      final response = await authService.login(
        username: userName,
        password: password,
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return LoginResponse.fromJson(response.data);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<ProfileModel> getProfile() async {
    try {
      final response = await authService.getProfile();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ProfileModel.fromJson(data);
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (e) {
      print('Logout API error: $e');
    }
  }

  Future<String?> fetchRole() async {
    try {
      final response = await authService.getProfile();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final roles = data?['roles'] as List? ?? [];

        if (roles.isNotEmpty) {
          return roles.first['title'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching role: $e');
      return null;
    }
  }
}
