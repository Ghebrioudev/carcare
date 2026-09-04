import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/main_shell.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';
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
          backgroundColor: AppTheme.surface1,
          title: const Text('Delete Account?'),
          content: Form(
            key: confirmKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action is irreversible. All vehicles, log history, and reminders will be deleted.\n\nPlease type "DELETE" to confirm:',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'DELETE',
                    errorStyle: TextStyle(color: AppTheme.danger),
                  ),
                  validator: (value) {
                    if (value != 'DELETE') {
                      return 'Must match "DELETE"';
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
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (confirmKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Permanently Delete'),
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
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: ScreenHeader(
                title: 'Profile & Settings',
                subtitle: 'Manage your owner account and preferences.',
              ),
            ),
            if (authProvider.user == null)
              const SliverFillRemaining(
                child: AppLoadingOverlay(message: 'Loading profile...'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Executive User Profile Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1E1E24), Color(0xFF121215)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppTheme.borderHighlighted,
                              width: 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x3316A249),
                                      blurRadius: 16,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    authProvider.user!.name.isNotEmpty
                                        ? authProvider.user!.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authProvider.user!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      authProvider.user!.email,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const StatusBadge(
                                      label: 'GARAGE OWNER',
                                      color: AppTheme.primaryLight,
                                      showDot: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Edit Credentials Card
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Credentials',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GlassTextField(
                                controller: _nameController,
                                labelText: 'Display Name',
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 14),
                              GlassTextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email_outlined),
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
                              const SizedBox(height: 16),

                              if (_showPasswordFields) ...[
                                GlassTextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  labelText: 'New Password',
                                  hintText: 'At least 8 characters',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    }),
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
                                GlassTextField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  labelText: 'Confirm New Password',
                                  hintText: 'Re-type password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    }),
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
                                const SizedBox(height: 12),
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
                                GlassButton(
                                  onPressed: () => setState(() {
                                    _showPasswordFields = true;
                                  }),
                                  label: 'Change Password',
                                  icon: Icons.key_rounded,
                                  height: 46,
                                ),

                              if (authProvider.errorMessage != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: AppTheme.danger),
                                ),
                              ],

                              const SizedBox(height: 20),
                              PrimaryButton(
                                onPressed: _isLoading ? null : _submit,
                                isLoading: _isLoading,
                                label: 'Save Changes',
                                icon: Icons.check_circle_outline_rounded,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Session Logout
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                            side: BorderSide(
                              color: AppTheme.danger.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Danger Zone Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerGlow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.danger.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppTheme.danger,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Danger Zone',
                                    style: TextStyle(
                                      color: AppTheme.danger,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Erasing your account permanently removes all stored vehicles, service invoices, telemetry logs, and scheduled reminders.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _confirmDeleteAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(46),
                                ),
                                child: const Text('Delete Account'),
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
