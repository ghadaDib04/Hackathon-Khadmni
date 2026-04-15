import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/storage.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _initialized = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get initialized => _initialized;


  Future<void> loadUserFromStorage() async {
    final token = await Storage.getToken();
    final user  = await Storage.getUser();
    if (token != null && user != null) {
      ApiService.setToken(token);
      _user = user;
    }
    _initialized = true;
    notifyListeners();
  }


  Future<void> fetchMe() async {
    try {
      final response = await ApiService.get('/users/me');
      _user = response.data as Map<String, dynamic>;
      await Storage.saveUser(_user!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = response.data['token'];
    final user  = response.data['user'];
    ApiService.setToken(token);
    await Storage.saveToken(token);
    await Storage.saveUser(user);
    _user = user;
    notifyListeners();
    await fetchMe();
  }

  Future<void> register(String name, String email, String password,
      String university, String skills) async {
    final response = await ApiService.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'university': university,
      'skills': skills,
    });
    final token = response.data['token'];
    final user  = response.data['user'];
    ApiService.setToken(token);
    await Storage.saveToken(token);
    await Storage.saveUser(user);
    _user = user;
    notifyListeners();
    await fetchMe();
  }

  Future<void> logout() async {
    await Storage.clear();
    ApiService.clearToken();
    _user = null;
    notifyListeners();
  }
}