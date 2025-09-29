
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileViewerScreen extends StatefulWidget {
  final String filePath;

  const FileViewerScreen({required this.filePath, super.key});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  String? _fileExtension;
  String? _fileContent; // For text files
  bool _isLoading = true;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fileExtension = _getFileExtension(widget.filePath);
    if (_fileExtension == 'txt') {
      _readTextFile();
    } else if (_fileExtension == 'docx') {
      _openDocxFile();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to get the file extension
  String? _getFileExtension(String url) {
    final parts = url.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return null;
  }

  // Function to read text files
  Future<void> _readTextFile() async {
    try {
      final file = File(widget.filePath);
      final content = await file.readAsString();
      setState(() {
        _fileContent = content;
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  // Function to open DOCX files in a third-party app
  Future<void> _openDocxFile() async {
    final result = await OpenFilex.open(widget.filePath);
    if (result.type == ResultType.done) {
      // Successfully opened the DOCX file, return back
      Navigator.pop(context);
    } else {
      // Failed to open DOCX
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileExtension?.toUpperCase() ?? 'File Viewer'),
        backgroundColor: white,
      ),
      body: _isLoading ? circularProgress() : _buildFileContent(),
    );
  }

  // Widget to build the appropriate file viewer based on the extension
  Widget _buildFileContent() {
    if (_fileExtension == 'pdf') {
      // return PDFView(
      //   filePath: widget.filePath,
      //   autoSpacing: true,
      //   enableSwipe: true,
      //   pageSnap: true,
      //   swipeHorizontal: false,
      //   onError: (error) {
      //     print(error.toString());
      //   },
      //   onPageError: (page, error) {
      //     print('$page: ${error.toString()}');
      //   },
      // );
      return SfPdfViewer.network(widget.filePath, key: _pdfViewerKey);
    } else if (_fileExtension == 'txt') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(_fileContent ?? 'Error loading text file'),
      );
    } else {
      return const Center(
        child: Text('Unsupported file type or could not open'),
      );
    }
  }
}
