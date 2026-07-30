import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _error;
  bool _isSuccess = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.lock_reset, color: AppTheme.primaryIndigo),
          SizedBox(width: 8),
          Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSuccess) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.accentEmerald, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Password updated successfully!', style: TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ] else ...[
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                const SizedBox(height: 8),
              ],

              const Text('New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Enter new password', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 12),

              const Text('Confirm New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Confirm new password', border: OutlineInputBorder()),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isSuccess)
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        else ...[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryIndigo, foregroundColor: Colors.white),
            onPressed: () async {
              final newPass = _newPasswordController.text;
              final confirmPass = _confirmPasswordController.text;

              if (newPass.length < 6) {
                setState(() => _error = 'Password must be at least 6 characters');
                return;
              }
              if (newPass != confirmPass) {
                setState(() => _error = 'Passwords do not match');
                return;
              }

              final success = await authService.changePassword(newPass);
              if (success) {
                setState(() {
                  _isSuccess = true;
                  _error = null;
                });
              } else {
                setState(() => _error = 'Failed to update password. Check database connection.');
              }
            },
            child: const Text('Save Password'),
          ),
        ],
      ],
    );
  }
}
