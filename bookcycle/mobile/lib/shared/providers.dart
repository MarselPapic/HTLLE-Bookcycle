import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/identity/data/user_repository.dart';
import '../features/identity/domain/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getCurrentUser();
});

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, AsyncValue<User?>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserProfileController(repo);
});

class UserProfileController extends StateNotifier<AsyncValue<User?>> {
  final UserRepository repository;

  UserProfileController(this.repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(User user) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateProfile(user);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
