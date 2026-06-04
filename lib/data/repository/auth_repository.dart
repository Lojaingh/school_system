import '../model/login_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<LoginResponse> login(
    String userName,
    String password,
  ) async {
    final response = await authService.login(
      userName: userName,
      password: password,
    );

   
    if (response.data is Map<String, dynamic>) {
      return LoginResponse.fromJson(response.data);
    } else {
      throw Exception('Invalid response format');
    }
  }
}
