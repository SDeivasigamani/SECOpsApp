import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:get/get.dart';

class PDFViewScreen extends StatefulWidget {
  final String url;
  final String fileName;

  const PDFViewScreen({Key? key, required this.url, required this.fileName}) : super(key: key);

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  String? localPath;
  bool isLoading = true;
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.fileName}');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) {
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error downloading PDF: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _printPdf() async {
    if (localPath == null) return;
    
    final file = File(localPath!);
    final bytes = await file.readAsBytes();
    
    // Printing.layoutPdf returns a Future<bool> which can be used to detect print
    final result = await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: widget.fileName,
    );
    
    if (result) {
      Get.snackbar(
        "Print",
        "Print job triggered successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          if (localPath != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printPdf,
              tooltip: 'Print PDF',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : localPath != null
                  ? PDFView(
                      filePath: localPath,
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
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = 'Page $page: ${error.toString()}';
                        });
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        // viewController.complete(pdfViewController);
                      },
                      onPageChanged: (int? page, int? total) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    )
                  : const Center(child: Text("Initialising...")),
    );
  }
}
