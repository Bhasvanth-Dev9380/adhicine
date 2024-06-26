import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../routes.dart';
import 'auth.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // To track the loading state
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.medical_services,
                          size: 50,
                          color: primary,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Adhicine',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Sign In',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MaldenSans',
                        ),
                      ),
                      SizedBox(height: 40),
                      _buildEmailField(),
                      SizedBox(height: 20),
                      _buildPasswordField(),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Forgot password logic
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: primary),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            User? user = await _auth.signInWithEmailAndPassword(
                              _emailController.text,
                              _passwordController.text,
                            );
                            if (user != null) {
                              // Navigate to home screen
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to sign in')),
                              );
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child: Text('Sign In'),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(50.0),
                          foregroundColor: Colors.white,
                          backgroundColor: primary,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          User? user = await _auth.signInWithGoogle();
                          if (user != null) {
                            // Store user details in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                              'name': user.displayName,
                              'email': user.email,
                              'profile_image': user.photoURL,
                            });

                            // Navigate to home screen
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to sign in with Google')),
                            );
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        icon: Image.asset(
                          "assets/google.png",
                          height: 24,
                          width: 24,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(50.0),
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, Routes.signup, (route) => false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to Adhicine? ',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              'Sign Up',
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
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
}
