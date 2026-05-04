import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_route_paths.dart';

/// Shown when [GoRouter] cannot match the URL — keeps users inside the app.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.state});

  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final uri = state.uri;
    final err = state.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.explore_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'No route for “${uri.path}”.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (err != null) ...[
              const SizedBox(height: 8),
              Text(
                '$err',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutePaths.home),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Go to Explore'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(AppRoutePaths.landing),
              child: const Text('Back to welcome'),
            ),
          ],
        ),
      ),
    );
  }
}
