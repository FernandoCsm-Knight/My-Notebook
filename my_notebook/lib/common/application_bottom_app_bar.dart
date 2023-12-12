import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/main.dart';
import 'package:my_notebook/search/screens/pdf_list_screen.dart';
import 'package:my_notebook/upload/screens/upload_screen.dart';

class ApplicationBottomAppBar extends StatelessWidget {
  final User user;
  const ApplicationBottomAppBar({required this.user, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfListScreen(
                    user: user,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search, size: 40),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenReplacer(),
                ),
              );
            },
            icon: const Icon(Icons.bookmark, size: 40),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadScreen(
                    user: user,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.document_scanner, size: 40),
          ),
        ],
      ),
    );
  }
}
