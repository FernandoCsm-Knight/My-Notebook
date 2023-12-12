import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/storage/services/file_service.dart';
import 'package:my_notebook/profile/components/get_image.dart';
import 'package:my_notebook/search/models/pdf_metadata.dart';
import 'package:my_notebook/search/service/pdf_list_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfInfoScreen extends StatefulWidget {
  final PdfMetadata pdf;
  final User user;

  const PdfInfoScreen({required this.pdf, required this.user, Key? key})
      : super(key: key);

  @override
  State<PdfInfoScreen> createState() => _PdfInfoScreenState();
}

class _PdfInfoScreenState extends State<PdfInfoScreen> {
  double _progressValue = 0.0;
  bool _isUploading = false;
  PdfListService _pdfListService = PdfListService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdf.title),
        actions: [
          IconButton(
            onPressed: () async {
              bool? value = await _showEvaluationDialog();
              if (value != null && value) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Evaluation Sent'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Evaluation Not Sent'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icon(Icons.message),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: _isUploading,
              child: LinearProgressIndicator(value: _progressValue),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: CircleAvatar(
                    child: getImage(photoURL: widget.pdf.userPhotoUrl),
                    backgroundColor: Colors.grey,
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      Text(widget.pdf.userDisplayName ?? widget.pdf.userEmail),
                      (widget.pdf.userDisplayName != null)
                          ? Text(' ${widget.pdf.userEmail}')
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Visibility(
                  visible: widget.user.uid == widget.pdf.userId,
                  child: IconButton(
                    onPressed: () async {
                      await _pdfListService.deletePdf(widget.pdf.pdfId);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete, size: 30, color: Colors.red[400]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 230,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(widget.pdf.thumbnailUrl),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 32),
                IconButton(
                  onPressed: () async {
                    File downloadedFile =
                        await downloadPdf(widget.pdf.pdfUrl, widget.pdf.title);

                    setState(() {
                      _isUploading = true;
                      _progressValue = 0.0;
                    });

                    String? error = await FileService().uploadPdf(
                      uid: widget.user.uid,
                      file: downloadedFile,
                      onProgress: (double progress) {
                        setState(() {
                          _progressValue = progress;
                        });
                      },
                    );

                    setState(() {
                      _isUploading = false;
                    });

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PDF Uploaded Successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.file_download_outlined, size: 40),
                ),
                SizedBox(width: 32),
                Column(
                  children: [
                    SizedBox(height: 16),
                    Container(
                      width: 275,
                      child: Text(
                          'Title: ${widget.pdf.title.replaceAll("_", " ")}',
                          style: TextStyle(fontSize: 20)),
                    ),
                    SizedBox(height: 16),
                    Text(
                        'Uploaded on: ${widget.pdf.uploadDate.day}/${widget.pdf.uploadDate.month}/${widget.pdf.uploadDate.year}'),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
            Divider(thickness: 3),
            SizedBox(height: 16),
            Text(
                '${(widget.pdf.evaluations.length == 0) ? "No" : ""} User Evaluations',
                style: TextStyle(fontSize: 20)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.pdf.evaluations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: getImage(photoURL: widget.pdf.evaluations[index].userPhotoUrl),
                  ),
                  title: Text(widget.pdf.evaluations[index].text),
                  subtitle:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.pdf.evaluations[index].userDisplayName ?? widget.pdf.evaluations[index].userEmail),
                          Text('${widget.pdf.evaluations[index].date.day}/${widget.pdf.evaluations[index].date.month}/${widget.pdf.evaluations[index].date.year}'),
                        ],
                      ),
                  trailing: Visibility(
                    visible: (widget.user.uid == widget.pdf.evaluations[index].userId) || (widget.user.uid == widget.pdf.userId),
                    child: IconButton(
                      onPressed: () async {
                        await _pdfListService.deleteEvaluation(
                          widget.pdf.pdfId,
                          widget.pdf.evaluations[index].userId,
                        );
                        widget.pdf.evaluations.removeAt(index);
                        setState(() {});
                      },
                      icon: Icon(Icons.delete, size: 30, color: Colors.red[400]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<File> downloadPdf(String url, String fileName) async {
    var response = await http.get(Uri.parse(url));
    var documentDirectory = await getApplicationDocumentsDirectory();
    var filePath = '${documentDirectory.path}/$fileName.pdf';
    var file = File(filePath);
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  Future<bool?> _showEvaluationDialog() {
    TextEditingController controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Evaluation'),
          content: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            maxLength: 200,
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Evaluation',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.length > 5) {
                  UserEvaluation evaluation = UserEvaluation(
                    userId: widget.user.uid,
                    userDisplayName: widget.user.displayName,
                    userPhotoUrl: widget.user.photoURL,
                    userEmail: widget.user.email ?? '',
                    date: DateTime.now(),
                    text: controller.text,
                  );

                  await _pdfListService.addEvaluation(
                    widget.pdf.pdfId,
                    evaluation,
                  );

                  widget.pdf.evaluations.add(evaluation);
                  Navigator.pop(context, true);
                } else {
                  Navigator.pop(context, false);
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
