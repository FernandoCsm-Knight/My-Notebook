import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/application_drawer.dart';
import 'package:my_notebook/main.dart';
import 'package:my_notebook/profile/components/get_image.dart';
import 'package:my_notebook/profile/screens/update_profile_screen.dart';
import 'package:my_notebook/profile/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {
    'photoURL': '',
    'name': '',
    'email': '',
    ProfilePaths.job: '',
    ProfilePaths.phone: '',
    ProfilePaths.birthday: '',
  };

  final ProfileService _service = ProfileService();

  Future<void> refreshProfile() async {
    User user = FirebaseAuth.instance.currentUser ?? widget.user;
    Map<String, dynamic>? res = await _service.profile;

    setState(() {
      if(res != null) _profile = res;
      _profile['photoURL'] = user.photoURL;
      _profile['name'] = user.displayName ?? 'Without Name';
      _profile['email'] = user.email ?? 'Without Email';
    });
  }

  @override
  void initState() {
    super.initState();
    refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenReplacer(),
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      drawer: ApplicationDrawer(
        user: widget.user,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshProfile();
        },
        child: ListView(
          children: <Widget>[
            Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: getImage(photoURL: _profile['photoURL']),
                ),
                const SizedBox(height: 20),
                Text(
                  _profile['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  (_profile[ProfilePaths.job] != null &&
                          _profile[ProfilePaths.job].isNotEmpty)
                      ? _profile[ProfilePaths.job]
                      : 'Without Job',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(200, 200, 200, 0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(_profile['email']),
                  ),
                ),
                Container(
                  color: const Color.fromRGBO(200, 200, 200, 0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(
                      (_profile[ProfilePaths.birthday] != null &&
                              _profile[ProfilePaths.birthday].isNotEmpty)
                          ? _profile[ProfilePaths.birthday]
                          : 'Without Birthday',
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(200, 200, 200, 0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(
                      (_profile[ProfilePaths.phone] != null &&
                              _profile[ProfilePaths.phone].isNotEmpty)
                          ? _profile[ProfilePaths.phone]
                          : 'Without Phone',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProfileScreen(
                          user: widget.user,
                          profile: _profile,
                        ),
                      ),
                    ).then((value) async {
                      await refreshProfile();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: (value == null)
                              ? const Text(
                                  'No changes made',
                                )
                              : Text(
                                  value,
                                ),
                          backgroundColor: (value == null ||
                                  value !=
                                      'Was not possible to update your profile.')
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    });
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
