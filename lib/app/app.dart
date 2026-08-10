import 'package:flutter/material.dart';
import '../core/update/presentation/update_listener.dart';
import 'router.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: goRouter,
      builder: (context, child) {
        return UpdateListener(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
