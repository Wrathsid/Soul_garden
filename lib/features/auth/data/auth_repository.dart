import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_client.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

/// Authentication states
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// User authentication data
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
}

/// Repository for authentication operations
class AuthRepository {
  /// Signs in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return AuthResult.success(response.user!);
      }
      return const AuthResult.failure('Login failed. Please try again.');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return const AuthResult.failure('An unexpected error occurred.');
    }
  }

  /// Signs up with email and password
  Future<AuthResult> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      
      if (response.user != null) {
        // Create profile entry
        await _createProfile(response.user!.id, displayName ?? 'Gardener');
        return AuthResult.success(response.user!);
      }
      return const AuthResult.failure('Sign up failed. Please try again.');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return const AuthResult.failure('An unexpected error occurred.');
    }
  }

  /// Signs in anonymously for users who want to try the app
  Future<AuthResult> signInAnonymously() async {
    try {
      final response = await SupabaseService.client.auth.signInAnonymously();
      
      if (response.user != null) {
        await _createProfile(response.user!.id, 'Gardener');
        return AuthResult.success(response.user!);
      }
      return const AuthResult.failure('Anonymous login failed.');
    } catch (e) {
      return const AuthResult.failure('An unexpected error occurred.');
    }
  }

  /// Sends password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  /// Gets the current user
  User? get currentUser => SupabaseService.client.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges {
    return SupabaseService.client.auth.onAuthStateChange.map((event) {
      return AuthState(
        status: event.session != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: event.session?.user,
      );
    });
  }

  /// Creates a profile for new users
  Future<void> _createProfile(String userId, String displayName) async {
    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': userId,
        'display_name': displayName,
        'xp': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Profile creation is best-effort
    }
  }
}

/// Result of an authentication operation
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  const AuthResult.success(User user) : this._(isSuccess: true, user: user);
  const AuthResult.failure(String message) : this._(isSuccess: false, errorMessage: message);
}

/// Provider for auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});
