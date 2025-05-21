import 'package:flutter/material.dart';
import '../models/service_provider.dart';
import '../services/appwrite_provider_service.dart';

class ServiceProviderProvider extends ChangeNotifier {
  ServiceProvider? _provider;
  bool _isLoading = false;
  final AppwriteProviderService _appwriteService = AppwriteProviderService();

  ServiceProvider? get provider => _provider;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _provider != null;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final providerData = await _appwriteService.loginProvider(
        email: email,
        password: password,
      );

      print(providerData);

      _provider = ServiceProvider.fromJson(providerData);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _appwriteService.logoutProvider();
      _provider = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Remove the condition that checks for existing provider
      final providerData = await _appwriteService.getCurrentUser();

      if (providerData != null) {
        _provider = ServiceProvider.fromJson(providerData);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return providerData;
      
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearProviderData() {
    _provider = null;
    notifyListeners();
  }

  void updateProvider(ServiceProvider updatedProvider) {
    _provider = updatedProvider;
    notifyListeners();
  }
}
