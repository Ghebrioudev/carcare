import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/main_shell.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
      _emailController.text = authProvider.user!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _showPasswordFields && _passwordController.text.isNotEmpty
            ? _passwordController.text.trim()
            : null,
        passwordConfirmation:
            _showPasswordFields && _passwordController.text.isNotEmpty
                ? _confirmPasswordController.text.trim()
                : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        if (_showPasswordFields) {
          setState(() {
            _showPasswordFields = false;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  Future<void> _confirmDeleteAccount() async {
    final textController = TextEditingController();
    final confirmKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: Form(
            key: confirmKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action is irreversible. All vehicles, log history, and reminders will be deleted.\n\nPlease type "DELETE" to confirm:',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'DELETE',
                    errorStyle: TextStyle(color: AppTheme.danger),
                  ),
                  validator: (value) {
                    if (value != 'DELETE') {
                      return 'Matches verification text';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.danger,
              ),
              onPressed: () {
                if (confirmKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final success = await context.read<AuthProvider>().deleteAccount();
        if (success && mounted) {
          context.go('/login');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account.')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: ScreenHeader(title: 'Profile'),
            ),
            if (authProvider.user == null)
              const SliverFillRemaining(
                child: AppLoadingOverlay(message: 'Loading profile...'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const IconBadge(
                                    icon: Icons.person,
                                    size: 56,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authProvider.user!.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          authProvider.user!.email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Edit profile',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (!value.contains('@')) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        if (_showPasswordFields) ...[
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'New password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                              ),
                            ),
                            validator: (value) {
                              if (_showPasswordFields &&
                                  (value == null || value.isEmpty)) {
                                return 'Required';
                              }
                              if (value != null && value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                }),
                              ),
                            ),
                            validator: (value) {
                              if (_showPasswordFields &&
                                  _passwordController.text.isNotEmpty) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showPasswordFields = false;
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              });
                            },
                            child: const Text('Cancel password change'),
                          ),
                        ] else
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _showPasswordFields = true;
                            }),
                            icon: const Icon(Icons.key_outlined),
                            label: const Text('Change password'),
                          ),
                        const SizedBox(height: 24),
                        if (authProvider.errorMessage != null) ...[
                          Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: AppTheme.danger),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save changes'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          'Danger Zone',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.danger,
                              ),
                        ),
                        const SizedBox(height: 12),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Once you delete your account, there is no going back. All your vehicles, logs, and files will be permanently erased.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _confirmDeleteAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete account'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
