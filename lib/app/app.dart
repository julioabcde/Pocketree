import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/app/routes.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_theme.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_event.dart';

class PocketreeApp extends StatefulWidget {
  const PocketreeApp({super.key});

  @override
  State<PocketreeApp> createState() => _PocketreeAppState();
}

class _PocketreeAppState extends State<PocketreeApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckStatusRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: Builder(
        builder: (context) {
          final router = createRouter(_authBloc);
          return MaterialApp.router(
            title: 'Pocketree',
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
