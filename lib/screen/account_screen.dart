import 'package:flutter/material.dart';
import 'package:cardholder/screen/login_page.dart';
import '../model/UserModel.dart';
import '../services/auth_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class AccountScreen extends StatefulWidget {
  final User? currentUser;
  
  const AccountScreen({super.key, this.currentUser});
  
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final result = await authService.userInfo();
    print('API Response: $result'); // Debug print

    if (result['success']) {
      print('User data: ${result['user']}'); // Debug print
      setState(() {
        _currentUser = User.fromJson(result['user']);
      });
      print('Current user after set: $_currentUser'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _currentUser?.avatarUrl != null
                            ? NetworkImage(_currentUser!.avatarUrl!) as ImageProvider
                            : null,
                        child: _currentUser?.avatarUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.userName ?? '',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _currentUser?.email ?? '',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 200, // Fixed width for button
                        child: ElevatedButton.icon(
                          onPressed: _showEditProfileDialog,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12
                            ),
                          ),
                        ),
                      ),
                      // Add extra space to ensure content pushes up from logout button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            // Logout button positioned at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final authService = AuthService();
                      final success = await authService.logout();
                      if (success) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget buildSuccessToast(BuildContext context, shadcn.ToastOverlay overlay) {
    return shadcn.SurfaceCard(
      child: shadcn.Basic(
        title: const Text('Success'),
        subtitle: const Text('Action completed successfully'),
        trailing: shadcn.PrimaryButton(
            size: shadcn.ButtonSize.small,
            onPressed: () {
              overlay.close();
            },
            child: const Text('Close')
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }

  Widget buildErrorToast(BuildContext context, shadcn.ToastOverlay overlay, Map<String, dynamic> result) {
    return shadcn.SurfaceCard(
      fillColor: shadcn.Colors.red,
      child: shadcn.Basic(
        title: const Text('Error'),
        subtitle: Text(result['message'] ?? 'Something went wrong'),
        trailing: shadcn.PrimaryButton(
            size: shadcn.ButtonSize.small,
            onPressed: () {
              overlay.close();
            },
            child: const Text('Close')
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }
  
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                _showPasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Change Avatar'),
              onTap: () {
                Navigator.pop(context);
                _showAvatarDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Setup 2FA'),
              onTap: () {
                Navigator.pop(context);
                _showTotpSetupDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Old Password'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  if (value!.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              TextFormField(
                controller: _retypePasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Retype New Password'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final authService = AuthService();
                final result = await authService.changePassword(
                  _oldPasswordController.text,
                  _newPasswordController.text,
                  _retypePasswordController.text,
                );

                Navigator.pop(context);

                shadcn.showToast(
                  context: context,
                  builder: (context, overlay) => result['success']
                      ? buildSuccessToast(context, overlay)
                      : buildErrorToast(context, overlay, result),
                  location: shadcn.ToastLocation.bottomRight,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showAvatarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Avatar'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _avatarUrlController,
            decoration: const InputDecoration(labelText: 'Avatar URL'),
            validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final authService = AuthService();
                final result = await authService.updateAvatar(
                  _avatarUrlController.text,
                );

                Navigator.pop(context);

                if (result['success']) {
                  setState(() {
                    _currentUser?.avatarUrl = result['avatarUrl'];
                  });
                }

                shadcn.showToast(
                  context: context,
                  builder: (context, overlay) => result['success']
                      ? buildSuccessToast(context, overlay)
                      : buildErrorToast(context, overlay, result),
                  location: shadcn.ToastLocation.bottomRight,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTotpSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: const Text('Are you sure you want to enable 2FA? An email with setup instructions will be sent to you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = AuthService();
              final result = await authService.setupTotp();

              shadcn.showToast(
                context: context,
                builder: (context, overlay) => result['success']
                    ? buildSuccessToast(context, overlay)
                    : buildErrorToast(context, overlay, result),
                location: shadcn.ToastLocation.bottomRight,
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
}
