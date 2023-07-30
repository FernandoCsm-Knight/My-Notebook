import 'package:flutter/material.dart';
import 'package:my_notebook/authentication/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLogin = true;
  AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.bookmark, size: 75.0),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'My Notebook',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    (isLogin) ? 'Login to Note' : 'Create an Account',
                    textAlign: TextAlign.center,
                  ),
                  Visibility(
                    visible: !isLogin,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                  ),
                  Visibility(
                    visible: isLogin,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                        onPressed: () {
                          forgotMyPassword();
                        },
                        child: const Text('Forgot my password'),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isLogin,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'Please enter your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      send();
                    },
                    child: Text((isLogin) ? 'Login' : 'Create Account'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      (isLogin) ? 'Create an Account' : 'Login',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  void send() {
    if (_formKey.currentState!.validate()) {
      if (isLogin) {
        authService
            .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        )
            .then(
          (error) {
            if (error != null) {
              showSnackBar(content: error, color: Colors.black);
            }
          },
        );
      } else {
        authService
            .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        )
            .then(
          (error) {
            if (error != null) {
              showSnackBar(content: error, color: Colors.black);
            }
          },
        );
      }
    }
  }

  void forgotMyPassword() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController confirmEmailController = TextEditingController();

        return AlertDialog(
          title: const Text('Enter your email'),
          content: TextFormField(
            controller: confirmEmailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }

              return null;
            },
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                authService
                    .resetPassword(email: confirmEmailController.text.trim())
                    .then((error) {
                  if (error == null) {
                    showSnackBar(content: 'Email sent', color: Colors.green);
                  } else {
                    showSnackBar(content: error, color: Colors.black);
                  }

                  Navigator.pop(context);
                });
              },
              child: const Text('Reset password'),
            ),
          ],
        );
      },
    );
  }

  void showSnackBar({required String content, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content, style: const TextStyle(color: Colors.white70),),
        backgroundColor: color,
      ),
    );
  }
}
