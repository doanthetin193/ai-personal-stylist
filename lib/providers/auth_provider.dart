import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider(this._firebaseService) {
    _init();
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  String get displayName => _user?.displayName ?? 'Người dùng';
  String? get photoUrl => _user?.photoURL;
  String? get email => _user?.email;
  String? get userId => _user?.uid;

  /// Initialize auth state listener
  void _init() {
    _firebaseService.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _firebaseService.signInWithGoogle();
      
      if (result != null) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Đăng nhập thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign in anonymously (for testing/demo)
  Future<bool> signInAnonymously() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _firebaseService.signInAnonymously();
      
      if (result != null) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Đăng nhập thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Email/Password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _firebaseService.signInWithEmail(email, password);
      
      if (result != null) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Đăng nhập thất bại';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Đã xảy ra lỗi';
      notifyListeners();
      return false;
    }
  }

  /// Register with Email/Password
  Future<bool> registerWithEmail(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _firebaseService.registerWithEmail(email, password);
      
      if (result != null) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Đăng ký thất bại';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Đã xảy ra lỗi';
      notifyListeners();
      return false;
    }
  }

  /// Get Vietnamese error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      default:
        return 'Đã xảy ra lỗi: $code';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
