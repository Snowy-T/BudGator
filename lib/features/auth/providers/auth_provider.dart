import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgator/models/user.dart';
import 'package:budgator/core/services/sample_data.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool hasCompletedOnboarding;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.hasCompletedOnboarding = false,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? hasCompletedOnboarding,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, accept any email/password
      // In production, this would validate against a backend
      if (email.isNotEmpty && password.isNotEmpty) {
        final user = SampleData.getSampleUser().copyWith(
          email: email,
          name: email.split('@').first,
        );
        
        state = state.copyWith(
          user: user,
          isLoading: false,
          hasCompletedOnboarding: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Please enter email and password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> loginAsDemo() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final user = SampleData.getSampleUser();
      state = state.copyWith(
        user: user,
        isLoading: false,
        hasCompletedOnboarding: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void logout() {
    state = AuthState(hasCompletedOnboarding: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoggedIn;
});
