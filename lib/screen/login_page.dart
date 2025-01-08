import 'package:cardholder/screen/register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'Admin_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String value = '';

  @override
  void initState() {
    super.initState();
    _checkToken(); // Kiểm tra token khi mở màn hình
  }

  // Kiểm tra token trong SharedPreferences
  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      // Nếu token tồn tại, chuyển hướng đến MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  Widget buildValidationToast(BuildContext context, shadcn.ToastOverlay overlay) {
    return shadcn.SurfaceCard(
      child: shadcn.Basic(
        title: const Text('Validation Error'),
        subtitle: const Text('Vui lòng nhập đầy đủ thông tin'),
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
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      shadcn.showToast(
        context: context,
        builder: buildValidationToast,
        location: shadcn.ToastLocation.bottomRight,
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> result = await Auth.login(
        _emailController.text,
        _passwordController.text
    );
    Widget buildToast(BuildContext context, shadcn.ToastOverlay overlay) {
      return shadcn.SurfaceCard(
        child: shadcn.Basic(
          title: const Text('Đăng nhập thất bại'),
          subtitle: Text('Kiểm tra tài khoản mật khẩu\n'  + result['message']  ?? 'Đăng nhập thất bại'),
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
    if (result['success']) {
      if (result['twoFactorEnabled']) {
        String? totpCode = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enter 2FA Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                shadcn.InputOTP(
                  onChanged: (value) {
                    setState(() {
                      this.value = value.otpToString();
                    });
                  },
                  children: [
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.separator,
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isLoading = false);
                },
                child: const Text('Cancel'),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context, value),
                child: const Text('Verify'),
              ),
            ],
          ),
        );

        if (totpCode != null) {
          result = await Auth.loginWithTotp(
              _emailController.text,
              _passwordController.text,
              totpCode
          );
        }
      }

      if (result['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', result['token']); // Lưu token
        String roles = result['roles'] ?? 'User'; // Changed from 'role' to 'roles' to match API response
        await prefs.setString('roles', roles);

        if (roles.toLowerCase().contains('admin')) {
          Navigator.pushReplacement(
            context,
            //Nếu người dùng là admin thì chuyển đến trang admin
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            //nếu không phải là admin thì chuyển đến trang MainScreen
            MaterialPageRoute(builder: (context) => MyHomePage()),

          );
        }
      }
    }

    setState(() => _isLoading = false);

    if (!result['success']) {
      shadcn.showToast(
        context: context,
        builder: buildToast,
        location: shadcn.ToastLocation.bottomRight,
      );
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final resetEmailController = TextEditingController();
        return AlertDialog(
          title: Text('Đặt lại mật khẩu'),
          content: TextField(
            controller: resetEmailController,
            decoration: InputDecoration(
              hintText: 'Nhập email của bạn',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (resetEmailController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã gửi hướng dẫn đặt lại mật khẩu')),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Đặt lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[50]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đăng Nhập',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Đăng Nhập',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Chưa có tài khoản? Đăng ký ngay',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}