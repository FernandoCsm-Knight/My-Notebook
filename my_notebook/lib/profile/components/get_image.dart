import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_notebook/notes/services/fox_api.dart';

Widget getImage({ required String? photoURL }) {
    Uri? uri = Uri.tryParse(photoURL ?? '');
    if (photoURL != null && uri != null && uri.isAbsolute) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          photoURL,
          fit: BoxFit.cover,
          width: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error),
            );
          },
        ),
      );
    } else if (photoURL != null &&
        File(photoURL).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          File(photoURL),
          fit: BoxFit.cover,
          width: 200,
        ),
      );
    } else {
      return FutureBuilder<String>(
        future: FoxApi.getFoxImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }
  }