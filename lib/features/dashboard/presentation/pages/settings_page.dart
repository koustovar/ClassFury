import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/app/theme/bloc/theme_cubit.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/core/services/url_launcher_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _buildSectionHeader(context, 'Preference'),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: mode == ThemeMode.dark,
                    onChanged: (value) => context.read<ThemeCubit>().toggleTheme(),
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Account'),
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => _showEditProfileDialog(context, user?.name ?? ''),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings coming soon')),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Security',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Security settings coming soon')),
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'App'),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => getIt<UrlLauncherService>().openHelpAndSupport(),
              ),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About ClassFury',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'ClassFury',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(),
                    children: [
                      const Text('ClassFury is an all-in-one education platform for teachers and students.'),
                    ],
                  );
                },
              ),
              const Gap(40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const Gap(20),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: AppTypography.bodySmall.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<AuthBloc>().add(UpdateProfileRequested(name: newName));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
