import 'package:flutter/material.dart';
import 'package:cardholder/screen/login_page.dart';
import '../model/UserModel.dart';
import '../services/auth_service.dart';

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
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _currentUser?.avatarUrl != null
                    ? NetworkImage(_currentUser!.avatarUrl!)
                    : null,
                child: _currentUser?.avatarUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _currentUser?.userName ?? '',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(_currentUser?.email ?? ''),
              const SizedBox(height: 32),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                    'Edit Profile', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .primaryColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final authService = AuthService();
                    final success = await authService.logout();
                    if (success) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                      'Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Change Email'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEmailDialog();
                  },
                ),
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

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Change Email'),
            content: TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'New Email'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Implement email change logic
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                ),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                TextField(
                  controller: _retypePasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Retype New Password'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Implement password change logic here
                  Navigator.pop(context);
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
      builder: (context) =>
          AlertDialog(
            title: const Text('Change Avatar'),
            content: TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Implement avatar update logic here
                  Navigator.pop(context);
                },
                child: const Text('Save'),
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
