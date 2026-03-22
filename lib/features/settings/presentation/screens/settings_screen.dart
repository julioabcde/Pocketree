import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_event.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Title
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.brownEspresso,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Profile Card
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state is AuthAuthenticated ? state.user : null;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.neutralTaupe.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryForest.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryForest,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name + Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brownEspresso,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.brownMocha,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // General Section
            const Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brownMocha,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.palette_outlined,
              label: 'Appearance',
              onTap: () => _showComingSoon(context),
            ),

            const SizedBox(height: 24),

            // Logout
            _buildSettingsItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              isDestructive: true,
              onTap: () => _showLogoutConfirmation(context),
            ),

            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                'Pocketree v0.1.0',
                style: TextStyle(fontSize: 12, color: AppColors.neutralTaupe),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFB3261E)
        : AppColors.brownDriftwood;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? const Color(0xFFB3261E)
                      : AppColors.brownEspresso,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralTaupe,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Coming soon'),
          backgroundColor: AppColors.brownDriftwood,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout? You will need to sign in again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFFB3261E)),
              ),
            ),
          ],
        );
      },
    );
  }
}
