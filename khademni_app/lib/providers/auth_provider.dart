import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/storage.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = response.data['token'];
    final user = response.data['user'];
    ApiService.setToken(token);
    await Storage.saveToken(token);
    await Storage.saveUser(user);
    _user = user;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String university, String skills) async {
    final response = await ApiService.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'university': university,
      'skills': skills,
    });
    final token = response.data['token'];
    final user = response.data['user'];
    ApiService.setToken(token);
    await Storage.saveToken(token);
    await Storage.saveUser(user);
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await Storage.clear();
    ApiService.clearToken();
    _user = null;
    notifyListeners();
  }
}