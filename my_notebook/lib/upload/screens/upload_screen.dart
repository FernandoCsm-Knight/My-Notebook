import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/application_bottom_app_bar.dart';
import 'package:my_notebook/common/application_drawer.dart';
import 'package:my_notebook/common/storage/services/file_service.dart';
import 'package:my_notebook/upload/screens/pdf_screen.dart';
import 'package:my_notebook/upload/services/pdf_provider.dart';
import 'package:my_notebook/upload/services/pdf_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UploadScreen extends StatefulWidget {
  final User user;
  
  const UploadScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late PDFProvider _pdfProvider;
  double progress = 0.0;
  bool isConnected = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pdfProvider = PDFProvider(uid: widget.user.uid);
    _pdfProvider.refresh().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Upload'),
        actions: [
          IconButton(
            onPressed: () {
              _uploadPdf(context);
            },
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      drawer: ApplicationDrawer(user: widget.user),
      bottomNavigationBar: ApplicationBottomAppBar(user: widget.user),
      body: Column(
        children: [
          Visibility(
            visible: isConnected,
            child: LinearProgressIndicator(
              value: progress,
            ),
          ),
          (_pdfProvider.pdfFiles.length == 0)
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  alignment: Alignment.topCenter,
                  child: const Text(
                    'There are no files to be listed.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(200, 200, 200, 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _pdfProvider.pdfFiles.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0,),
                          title: Text(_pdfProvider.pdfFiles[index].name
                              .replaceFirst('.pdf', '').substring(0, _pdfProvider.pdfFiles[index].name.indexOf('?'))),
                          leading: Icon(Icons.picture_as_pdf),
                          trailing: IconButton(
                            onPressed: () {
                              _pdfProvider.pdfFiles[index].delete();
                              _pdfProvider.pdfFiles.removeAt(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          onTap: () async {
                            File file = await _downloadPdf(index);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PdfScreen(user: widget.user, file: file);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _uploadPdf(BuildContext context) async {
    File? file = await PdfService.pickFile();
    setState(() {
      isConnected = true;
    });

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected.'),
        ),
      );
      return;
    }

    String? error = await FileService().uploadPdf(
      uid: widget.user.uid,
      file: file,
      onProgress: (double percentage) {
        setState(() {
          progress = percentage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Uploading... ${(percentage * 100).toStringAsFixed(2)}%'),
            duration: Duration(milliseconds: 100),
          ),
        );
      },
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
      return;
    }

    await _pdfProvider.refresh();
    setState(() {
      isConnected = false;
      progress = 0.0;
    });
  }

  Future<File> _downloadPdf(int idx) async {
    setState(() {
      progress = 0.0;
      isConnected = true;
    });

    try {
      final String url = await _pdfProvider.pdfFiles[idx].getDownloadURL();
      final response =
          await http.Client().send(http.Request('GET', Uri.parse(url)));

      int totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      List<int> bytes = [];

      await for (List<int> chunk in response.stream) {
        downloadedBytes += chunk.length;
        progress = downloadedBytes / totalBytes;
        setState(() {});
        bytes.addAll(chunk);
      }

      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/' +
      '${_pdfProvider.pdfFiles[idx].name.replaceFirst('.pdf', '').substring(0, _pdfProvider.pdfFiles[idx].name.indexOf('?'))}.pdf');

      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('Failed to load PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load PDF: $e'),
        ),
      );
      return Future.error('Failed to load PDF: $e');
    } finally {
      setState(() {
        progress = 0.0;
        isConnected = false;
      });
    }
  }
}
