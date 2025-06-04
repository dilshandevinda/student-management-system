// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:educonnectfinal/UI/ar/arprofilehome.dart';
import 'package:educonnectfinal/UI/canteen/canteenprofilehome.dart';
import 'package:educonnectfinal/UI/lecturer/lecturerprofilehome.dart';
import 'package:educonnectfinal/UI/student/studentprofilehome.dart';
import 'package:flutter/material.dart';
import '../AUTH/login_auth.dart';
import 'ar/arprofile.dart';
import 'canteen/canteenownerprofile.dart';
import 'lecturer/lecturerprofile.dart';
import 'register.dart';
import 'student/studentprofile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = LoginAuth();
  bool _loginSuccess = false;
  String _userRole = '';
  bool _obscurePassword = true;
  bool _showDomainSuggestion = false; // For domain suggestion

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      String? role = await _auth.login(
        _emailOrUsernameController.text,
        _passwordController.text,
      );

      if (role != null) {
        setState(() {
          _loginSuccess = true;
          _userRole = role;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed!")),
        );
      }
    }
  }

  void _navigateToProfile() {
    if (_userRole == 'Student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentProfileHome()),
      );
    } else if (_userRole == 'AR') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const arprofilehome()),
      );
    } else if (_userRole == 'Lecturer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const lecturerprofilehome()),
      );
    } else if (_userRole == 'Canteen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const canteenprofilehome()),
      );
    }
  }

  // Add this method to handle domain suggestion
  void _onEmailUsernameChanged(String value) {
    setState(() {
      _showDomainSuggestion =
          value.contains('@') && !value.endsWith('@tec.rjt.ac.lk');
    });
  }

  // Add this method to append the domain
  void _addDomainSuggestion() {
    setState(() {
      _emailOrUsernameController.text =
          '${_emailOrUsernameController.text.split('@')[0]}@tec.rjt.ac.lk';
      _emailOrUsernameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _emailOrUsernameController.text.length));
      _showDomainSuggestion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/images/EduconnectLogo.jpg',
                    width: 150,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                        controller: _emailOrUsernameController,
                        enabled: !_loginSuccess,
                        decoration: const InputDecoration(
                          labelText: "Username or Email",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onEmailUsernameChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username or email';
                          }
                          return null;
                        },
                      ),
                      if (_showDomainSuggestion)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: _addDomainSuggestion,
                            child: const Chip(
                              label: Text('tec.rjt.ac.lk'),
                              backgroundColor: Colors.blueAccent,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _passwordController,
                    enabled: !_loginSuccess,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _loginSuccess ? null : _handleLogin,
                    child: Text(_loginSuccess ? "LOGIN SUCCESSFUL" : "LOGIN"),
                  ),
                ),
                if (_loginSuccess)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _navigateToProfile,
                      child: Text("PROCEED TO $_userRole"),
                    ),
                  ),
                if (!_loginSuccess)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()),
                        );
                      },
                      child: const Text(
                        "Not yet registered? Register now",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
