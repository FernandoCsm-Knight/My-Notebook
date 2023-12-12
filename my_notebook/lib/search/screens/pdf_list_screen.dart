import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/application_bottom_app_bar.dart';
import 'package:my_notebook/common/application_drawer.dart';
import 'package:my_notebook/search/components/pdf_search_delegate.dart';
import 'package:my_notebook/search/models/pdf_metadata.dart';
import 'package:my_notebook/search/screens/pdf_info_screen.dart';
import 'package:my_notebook/search/service/pdf_list_service.dart';

class PdfListScreen extends StatefulWidget {
  final User user;
  const PdfListScreen({required this.user});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}


class _PdfListScreenState extends State<PdfListScreen> {
  final PdfListService _pdfListService = PdfListService();
  List<PdfMetadata> _pdfList = [];
  List<PdfMetadata> _filteredPdfList = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadPdfList();
  }

  Future<void> _loadPdfList() async {
    var pdfList = await _pdfListService.fetchPdfList();
    setState(() {
      _pdfList = pdfList;
      _filterPdfList();
    });
  }

  void _filterPdfList() {
    setState(() {
      if (_searchText.isEmpty) {
        _filteredPdfList = _pdfList;
      } else {
        _filteredPdfList = _pdfList
            .where((pdf) =>
                pdf.title.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available PDFs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, size: 30),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PdfSearchDelegate(pdfList: _pdfList, updateSearchText: _updateSearchText, user: widget.user),
              );
            },
          ),
        ],
      ),
      drawer: ApplicationDrawer(user: widget.user),
      bottomNavigationBar: ApplicationBottomAppBar(user: widget.user),
      body: RefreshIndicator(
        onRefresh: _loadPdfList,
        child: _buildPdfGridView(),
      ),
    );
  }

  Widget _buildPdfGridView() {
    return _filteredPdfList.isEmpty
        ? Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(16),
            child: const Text(
              'No PDFs available',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
        : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6,
                ),
                itemCount: _pdfList.length,
                itemBuilder: (context, index) {
                  var pdf = _pdfList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PdfInfoScreen(pdf: pdf, user: widget.user),
                        ),
                      ).then((value) => setState(() { _loadPdfList(); }));
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8)),
                              child: Image.network(
                                pdf.thumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              (pdf.title.length > 20)
                                  ? '${pdf.title.substring(0, 20)}...'
                                  : pdf.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
      _filterPdfList();
    });
  }
}
