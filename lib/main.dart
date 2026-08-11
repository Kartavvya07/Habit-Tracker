import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/notifications/notification_provider.dart';
import 'features/habits/presentation/providers/use_case_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  try {
    final notificationService = container.read(notificationServiceProvider);
    await notificationService.initialize();
    final reconcileUseCase = container.read(reconcileRemindersUseCaseProvider);
    await reconcileUseCase.execute();
  } catch (_) {}

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
