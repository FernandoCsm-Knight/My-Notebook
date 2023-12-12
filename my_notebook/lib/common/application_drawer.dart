import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/authentication/service/auth_service.dart';
import 'package:my_notebook/home/components/show_remove_account_dialog.dart';
import 'package:my_notebook/info/screens/about_screen.dart';
import 'package:my_notebook/info/screens/help_screen.dart';
import 'package:my_notebook/info/screens/privacy_policy_screen.dart';
import 'package:my_notebook/main.dart';
import 'package:my_notebook/notes/services/fox_api.dart';
import 'package:my_notebook/profile/screens/profile_screen.dart';
import 'package:my_notebook/settings/screen/SettingsScreen.dart';
import 'package:my_notebook/settings/service/SettingsProvider.dart';

class ApplicationDrawer extends StatefulWidget {
  final User user;
  const ApplicationDrawer({required this.user, Key? key}) : super(key: key);

  @override
  State<ApplicationDrawer> createState() => _ApplicationDrawerState();
}

class _ApplicationDrawerState extends State<ApplicationDrawer> {
  Future<String> imageUrl = FoxApi.getFoxImage();
  SettingsProvider _settings = SettingsProvider();
  bool hasImage = false;

  @override
  void initState() {
    super.initState();
    hasImage = widget.user.photoURL != null;
    _settings.loadSettings();

    if (hasImage) {
      imageUrl = Future.value(widget.user.photoURL!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: GestureDetector(
              onTap: () async {
                if (!hasImage || _settings.settings.randomProfilePicture) {
                  setState(() {
                    imageUrl = FoxApi.getFoxImage();
                  });
                }
              },
              child: FutureBuilder<String>(
                future: imageUrl,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      !(snapshot.connectionState == ConnectionState.waiting)) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            accountName: Text(
              (widget.user.displayName != null) ? widget.user.displayName! : '',
            ),
            accountEmail: Text(widget.user.email!),
            decoration: const BoxDecoration(
              color: Colors.black45,
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ScreenReplacer()),
              );
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen(user: widget.user)),
              );
            },
          ),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: widget.user,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Help'),
            leading: const Icon(Icons.help),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            title:
                Text('Logout', style: TextStyle(color: Colors.brown.shade300)),
            leading: const Icon(Icons.logout),
            onTap: () {
              AuthService().signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenReplacer()),
                );
              });
            },
          ),
          ListTile(
            title: const Text('Delete Account',
                style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.delete_forever),
            onTap: () {
              showRemoveAccountDialog(context).then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenReplacer()),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
