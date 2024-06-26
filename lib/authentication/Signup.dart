import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/colors.dart';
import '../routes.dart';
import 'auth.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _imageFile;
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _pickImage(),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: primary,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Add profile image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Sign Up',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MaldenSans',
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildNameField(),
                  SizedBox(height: 20),
                  _buildEmailField(),
                  SizedBox(height: 20),
                  _buildPasswordField(),
                  SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _imageFile != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        User? user = await _auth.signUpWithEmailAndPassword(
                          _nameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _imageFile!.path,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        if (user != null) {
                          // Navigate to home screen
                          Navigator.pushNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to sign up')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all fields and upload a profile image')),
                        );
                      }
                    },
                    child: Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromHeight(50.0),
                      foregroundColor: Colors.white,
                      backgroundColor: primary,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, Routes.login,(route)=> false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Sign In',
                          style: TextStyle(color: primary),
                        ),
                      ],
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

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.person, color: Secondary),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: UnderlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.email, color: Secondary),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: UnderlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!EmailValidator.validate(value)) {
                  return 'Incorrect Email Address';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.lock, color: Secondary),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: UnderlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
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
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                } else if (!RegExp(r'(?=.*?[#?!@$%^&*-])').hasMatch(value)) {
                  return 'Password must contain at least one special character';
                } else if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
                  return 'Password must contain at least one number';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.lock, color: Secondary),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: UnderlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                } else if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
