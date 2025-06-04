// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:educonnectfinal/AUTH/regsiter_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _indexController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController =
      TextEditingController(); // Add password controller
  String _selectedRole = 'Student'; // Default role
  bool _isRegistering = false; // Track registration in progress
  final _auth = RegisterAuth();
  bool _showDomainSuggestion = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _indexController.dispose();
    _contactController.dispose();
    _passwordController.dispose(); // Dispose password controller
    super.dispose();
  }

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      try {
        bool success = await _auth.register(
          _nameController.text,
          _emailController.text,
          _usernameController.text,
          _indexController.text,
          _contactController.text,
          _selectedRole,
          _passwordController.text, // Pass password to auth
        );

        setState(() {
          _isRegistering = false;
        });

        if (success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Registration Successful"),
              content: const Text("Your account has been created."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration failed!")),
          );
        }
      } catch (e) {
        setState(() {
          _isRegistering = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    }
  }

  void _onEmailChanged(String text) {
    if (text.contains('@')) {
      String username = text.split('@')[0];
      _usernameController.text = username;
    } else {
      _usernameController.clear();
    }

    setState(() {
      _showDomainSuggestion =
          text.contains('@') && !text.endsWith('@tec.rjt.ac.lk');
    });
  }

  void _addDomainSuggestion() {
    setState(() {
      _emailController.text =
          '${_emailController.text.split('@')[0]}@tec.rjt.ac.lk';
      _showDomainSuggestion = false;
    });

    _emailController.selection = TextSelection.fromPosition(
        TextPosition(offset: _emailController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                        if (_selectedRole != 'Student') {
                          _indexController.clear();
                        }
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'Student', child: Text('Student')),
                      DropdownMenuItem(value: 'AR', child: Text('AR')),
                      DropdownMenuItem(
                          value: 'Lecturer', child: Text('Lecturer')),
                      DropdownMenuItem(
                          value: 'Canteen', child: Text('Canteen')),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name with Initials",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name with initials';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        onChanged: _onEmailChanged,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (_selectedRole != 'Canteen' &&
                              !value.endsWith('@tec.rjt.ac.lk')) {
                            return 'Please enter a valid university email';
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
                  const SizedBox(height: 16),
                  if (_selectedRole == 'Student')
                    TextFormField(
                      controller: _indexController,
                      decoration: const InputDecoration(
                        labelText: "Index Number",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedRole == 'Student' &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter your index number';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: "Contact Number",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact number';
                      }
                      if (value.length != 10) {
                        return 'Contact number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Username (Automatically Generated)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isRegistering ? null : _handleRegistration,
                    child: _isRegistering
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
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
