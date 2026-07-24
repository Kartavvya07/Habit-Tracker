import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Centralized [GoRouter] configuration for the application.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.root,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.root,
        name: 'root',
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 64,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Habit Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Phase 1 – Core Infrastructure Ready',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        body: Center(
          child: Text('Route error: ${state.error?.message}'),
        ),
      );
    },
  );
}
