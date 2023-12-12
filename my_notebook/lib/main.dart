import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_notebook/authentication/screens/login_screen.dart';
import 'package:my_notebook/settings/service/SettingsProvider.dart';
import 'firebase_options.dart';
import 'home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SettingsProvider settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  MyNotebook.themeNotifier.value = settingsProvider.settings.darkThemeEnabled ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyNotebook());
}

class MyNotebook extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  const MyNotebook({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentTheme, __) {
        return MaterialApp(
          title: 'My Notebook',
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: currentTheme,
          debugShowCheckedModeBanner: false,
          home: const ScreenReplacer(),
        );
      }
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
          return HomeScreen(
            user: snapshot.data!,

          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
