import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_event.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name = state is AuthAuthenticated ? state.user.name : '';
            return Center(
              child: Text(
                'Welcome, $name',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          },
        ),
      ),
    );
  }
}
