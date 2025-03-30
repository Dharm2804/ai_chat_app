import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfAssetPath;

  const PdfViewerScreen({super.key, required this.pdfAssetPath});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  bool isScrolling = false; // Default: Swipe mode enabled
  int totalPages = 0;
  PDFViewController? pdfController;
  UniqueKey pdfViewKey = UniqueKey(); // Key to force widget rebuild

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final ByteData data = await rootBundle.load(widget.pdfAssetPath);
      final List<int> bytes = data.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File("${tempDir.path}/temp.pdf");

      await tempFile.writeAsBytes(bytes, flush: true);

      setState(() {
        localFilePath = tempFile.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading PDF: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleScrollMode() {
    setState(() {
      isScrolling = !isScrolling;
      pdfViewKey = UniqueKey(); // Force PDFView to rebuild
    });
  }

  Future<void> _downloadPdf() async {
    if (localFilePath == null) return;

    try {
      if (Platform.isAndroid) {
        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          
          final Directory? downloadsDir = await getExternalStorageDirectory();
          if (downloadsDir != null) {
            final File destinationFile = File("${downloadsDir.path}/downloaded.pdf");
            await File(localFilePath!).copy(destinationFile.path);

            // Show pop-up after successful download
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Download Complete"),
                  content: Text("PDF downloaded to:\n${destinationFile.path}"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // Show a pop-up when permission is denied
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Permission Denied"),
                content: const Text("Storage permission is required to download the PDF."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      openAppSettings(); // Open app settings for permissions
                    },
                    child: const Text("Open Settings"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('E-Book Reader', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localFilePath != null
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _toggleScrollMode,
                        child: Text(isScrolling ? "Switch to Swipe Mode" : "Switch to Scroll Mode"),
                      ),
                    ),
                    Expanded(
                      child: PDFView(
                        key: pdfViewKey, // Ensures widget rebuilds
                        filePath: localFilePath!,
                        enableSwipe: true,
                        swipeHorizontal: !isScrolling, // Enable left/right swipe
                        autoSpacing: true,
                        pageSnap: true,
                        pageFling: true,
                        onRender: (pages) {
                          setState(() {
                            totalPages = pages ?? 0;
                          });
                        },
                        onViewCreated: (PDFViewController controller) {
                          setState(() {
                            pdfController = controller;
                          });
                        },
                        onError: (error) {
                          debugPrint("PDF Error: $error");
                        },
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text("Failed to load PDF", style: TextStyle(fontSize: 18, color: Colors.red)),
                ),
    );
  }
}