import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_notebook/search/service/pdf_list_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfScreen extends StatefulWidget {
  final File file;
  final User user;
  const PdfScreen({required this.file, required this.user, Key? key}) : super(key: key);

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  final PdfListService _pdfListService = PdfListService();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  double rate = 0.5;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _uploadPdf() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    bool res = await _pdfListService.uploadPdf(
        pdfFile: widget.file, title: widget.file.path.split('/').last.replaceFirst('.pdf', ''),
        user: widget.user,
        onProgress: (double progress) {
      setState(() {
        _uploadProgress = progress;
      });
    });

    setState(() {
      _isUploading = false;
    });

    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('PDF Uploaded Successfully'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('PDF Upload Failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setVolume(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document'),
        actions: <Widget>[
          _buildPageNavigationTextField(),
          IconButton(
            onPressed: _uploadPdf,
            icon: Icon(Icons.add_box_rounded),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await Share.shareXFiles(
                [XFile(widget.file.path)],
                text: 'Share PDF',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.navigate_before, size: 32.0),
                onPressed: () {
                  _navigatePage(-1);
                },
              ),
              _buildRateSlider(),
              IconButton(
                icon: Icon(Icons.navigate_next, size: 32.0),
                onPressed: () {
                  _navigatePage(1);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Visibility(
            visible: _isUploading,
            child: Column(
              children: [
                LinearProgressIndicator(value: _uploadProgress),
                Container(height: 8, color: Colors.black)
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                PDFView(
                  filePath: widget.file.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  pageSnap: false,
                  defaultPage: currentPage!,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onRender: (_pages) {
                    setState(() {
                      pages = _pages;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = '$page: ${error.toString()}';
                    });
                    print('$page: ${error.toString()}');
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    if (!_controller.isCompleted) {
                      _controller.complete(pdfViewController);
                    }
                  },
                  onLinkHandler: (String? uri) {
                    print('goto uri: $uri');
                  },
                  onPageChanged: (int? page, int? total) {
                    print('page change: $page/$total');
                    setState(() {
                      currentPage = page;
                    });
                  },
                ),
                errorMessage.isEmpty
                    ? !isReady
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container()
                    : Center(
                        child: Text(errorMessage),
                      )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleTts();
        },
        child: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPageNavigationTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${currentPage ?? 0}',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  void _navigatePage(int offset) async {
    final int targetPage = (currentPage ?? 0) + offset;
    _goToPage(targetPage);
  }

  void _goToPage(int page) async {
    if (page >= 0 && page <= pages!) {
      final controller = await _controller.future;
      await controller.setPage(page);
    } else {
      print('Invalid page number');
    }
  }

  void _toggleTts() {
    if (isPlaying) {
      _pauseTts();
    } else {
      _playTts();
    }
  }

  Future<void> _playTts() async {
    final text = await _extractTextFromPdf();
    await flutterTts.speak(text);
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _pauseTts() async {
    await flutterTts.stop();
    setState(() {
      isPlaying = false;
    });
  }

  Future<String> _extractTextFromPdf() async {
    PdfDocument document =
        PdfDocument(inputBytes: widget.file.readAsBytesSync());
    String text = PdfTextExtractor(document).extractText(startPageIndex: 0);
    document.dispose();

    return text.toLowerCase();
  }

  Widget _buildRateSlider() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        flutterTts.setSpeechRate(newRate).then((_) {
          setState(() {
            rate = newRate;
          });
        });
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
    );
  }
}
