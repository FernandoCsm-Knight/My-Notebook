import 'package:flutter/material.dart';
import 'package:my_notebook/authentication/service/auth_service.dart';

Future<T?> showRemoveAccountDialog<T>(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      TextEditingController passwordController =
          TextEditingController();

      return AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Write your password to delete account.'),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  AuthService()
                      .deleteAccount(
                          password: passwordController.text)
                      .then((value) {
                    if (value == null) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value),
                        ),
                      );
                    }
                  });
                },
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      );
    },
  );
}