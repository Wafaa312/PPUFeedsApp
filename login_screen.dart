import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'feeds_screen.dart'; // شاشة التغذيات

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://feeds.ppu.edu/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['session_token'];

        // الانتقال إلى شاشة التغذيات
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FeedsScreen(authToken: token)),
        );
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        setState(() {
          _errorMessage =
              'فشل تسجيل الدخول. تحقق من البريد الإلكتروني أو كلمة المرور.';
        });
      } else {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة لاحقًا.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'حدث خطأ أثناء الاتصال بالخادم. تأكد من اتصالك بالإنترنت.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}
