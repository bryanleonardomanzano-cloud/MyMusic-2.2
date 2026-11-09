import 'package:flutter_test/flutter_test.dart';
import 'package:mymusic/features/auth/domain/auth_repository.dart';
import 'package:mymusic/features/auth/domain/auth_state.dart';
import 'package:mymusic/features/auth/presentation/auth_notifier.dart';

void main() {
  test('AuthNotifier starts uninitialized with its repository', () {
    final notifier = AuthNotifier(repository: AuthRepository());

    expect(notifier.state, isA<AuthUninitialized>());
    notifier.dispose();
  });
}
