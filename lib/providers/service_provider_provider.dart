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

      // Only set provider if login was successful
      if (providerData != null) {
        _provider = ServiceProvider.fromJson(providerData);
      }

    } catch (e) {
      // Make sure to clear provider data if login fails
      _provider = null;
      
      // Properly propagate the error message
      if (e.toString().contains('pending_approval')) {
        throw Exception('Your account is pending approval from admin');
      } else if (e.toString().contains('account_rejected')) {
        throw Exception('Your account has been rejected');
      } else if (e.toString().contains('Invalid credentials')) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception(e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
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
