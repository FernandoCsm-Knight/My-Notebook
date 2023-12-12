import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/search/models/pdf_metadata.dart';
import 'package:my_notebook/search/screens/pdf_info_screen.dart';

class PdfSearchDelegate extends SearchDelegate<PdfMetadata> {
  final List<PdfMetadata> pdfList;
  final Function(String) updateSearchText;
  final User user;

  PdfSearchDelegate({ required this.pdfList, required this.updateSearchText, required this.user });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, PdfMetadata(
            title: '',
            uploadDate: DateTime.now(),
            userId: '',
            userEmail: '',
            thumbnailUrl: '',
            pdfId: '',
            pdfUrl: '',
            evaluations: [],
            userDisplayName: '',
            userPhotoUrl: '',
          ),);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = pdfList.where((pdf) {
      return pdf.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final pdf = results[index];
        return ListTile(
          title: Text(pdf.title),
          subtitle: Text('Uploaded on: ${pdf.uploadDate}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PdfInfoScreen(pdf: pdf, user: user,),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = pdfList.where((pdf) {
      return pdf.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final pdf = suggestions[index];
        return ListTile(
          title: Text(pdf.title),
          onTap: () {
            query = pdf.title;
            showResults(context);
          },
        );
      },
    );
  }
}

