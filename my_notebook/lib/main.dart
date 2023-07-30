import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_notebook/authentication/screens/login_screen.dart';
import 'firebase_options.dart';
import 'notes/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyNotebook());
}

class MyNotebook extends StatelessWidget {
  const MyNotebook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notebook',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const ScreenReplacer(),
    );
  }
}

class ScreenReplacer extends StatelessWidget {
  const ScreenReplacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasData) {
          return HomeScreen(user: snapshot.data!,);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}