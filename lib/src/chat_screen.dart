import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'gemini_service.dart';
import 'login_signup_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final GeminiService geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isReading = false;
  bool isListening = false;
  bool isNewMessage = false;
  late AnimationController _animationController;
  bool isGenerating = false;
  bool isAnimating = false;
  String animatedResponse = '';
  bool _stopGenerating = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      messages.insert(0, {
        "role": "bot",
        "text": "Hello! Welcome to the AI Chatbot. How can I help you today?",
      });
    });
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  void _initializeSpeech() async {
    await speechToText.initialize();
  }

  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.insert(0, {"role": "user", "text": userMessage});
      _controller.clear();
      isGenerating = true;
      animatedResponse = '';
      _stopGenerating = false;
    });

    _scrollToBottom();

    try {
      String botResponse = await geminiService.sendMessage(userMessage);

      if (!_stopGenerating) {
        setState(() {
          messages.insert(0, {"role": "bot", "text": botResponse});
          isGenerating = false;
          _startTypingAnimation(botResponse);
        });
      }
    } catch (e) {
      debugPrint("AI Response Error: $e");
      setState(() {
        isGenerating = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTypingAnimation(String response) async {
    setState(() {
      isAnimating = true;
    });

    for (int i = 0; i < response.length; i++) {
      if (_stopGenerating) break;
      await Future.delayed(const Duration(milliseconds: 10), () {
        setState(() {
          animatedResponse = response.substring(0, i + 1);
        });
      });
    }

    setState(() {
      isAnimating = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? imageFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      String extractedText = recognizedText.text.trim();
      if (extractedText.isNotEmpty) {
        setState(() {
          _controller.text = extractedText;
        });
      }
    }
  }

  Future<void> startListening() async {
    bool available = await speechToText.initialize();
    if (!available) return;

    setState(() {
      isListening = true;
    });

    speechToText.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
    );
  }

  void stopListening() {
    speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  void stopGenerating() {
    setState(() {
      _stopGenerating = true;
      isGenerating = false;
      isAnimating = false;
    });
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Help"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "How to use the AI Chatbot:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "1. Type your message in the text field and press the send button to get a response from the AI.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "2. Use the microphone button to speak your message. The app will convert your speech to text.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "3. Use the image button to pick an image from your gallery. The app will extract text from the image and use it as your message.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "4. Use the copy button to copy the AI's response to your clipboard.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "5. Use the share button to share the conversation as a PDF.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "6. Use the volume button to listen to the AI's response using text-to-speech.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "7. Use the stop button to stop generating a response or stop the text-to-speech playback.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareConversationAsPdf(
      Map<String, String> userMessage, Map<String, String> aiMessage) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "User: ${userMessage["text"]}",
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "AI: ${aiMessage["text"]}",
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.black,
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/conversation.pdf");
    await file.writeAsBytes(await pdf.save());

    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile],
        text: 'Here is the conversation in PDF format.');
  }

  Future<void> toggleTts(String text) async {
    if (isSpeaking) {
      await flutterTts.pause();
      setState(() {
        isSpeaking = false;
      });
    } else {
      await flutterTts.speak(text);
      setState(() {
        isSpeaking = true;
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speechToText.stop();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chatbot"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(messages: messages),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => _showHelpDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginSignupScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemCount: messages.length + (isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 && isGenerating) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TypingIndicator(),
                      ),
                    );
                  }
                  
                  final messageIndex = isGenerating ? index - 1 : index;
                  final message = messages[messageIndex];
                  final bool isUser = message["role"] == "user";
                  final bool isLastMessage = messageIndex == 0;
                  final String displayText = isLastMessage && !isUser && isAnimating 
                      ? animatedResponse 
                      : message["text"]!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.smart_toy,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue
                                  : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayText,
                                  style: TextStyle(
                                    color: isUser
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (!isUser)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.content_copy, size: 16),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: message["text"]!));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Copied to clipboard")),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share, size: 16),
                                        onPressed: () {
                                          if (messageIndex < messages.length - 1 && 
                                              messages[messageIndex + 1]["role"] == "user") {
                                            final userMessage = messages[messageIndex + 1];
                                            final aiMessage = messages[messageIndex];
                                            _shareConversationAsPdf(userMessage, aiMessage);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isSpeaking ? Icons.pause : Icons.volume_up,
                                          size: 16,
                                        ),
                                        onPressed: () => toggleTts(message["text"]!),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (isUser)
                          const SizedBox(width: 8),
                        if (isUser)
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (text) => sendMessage(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.blue,
                          ),
                          onPressed: sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: isListening ? stopListening : startListening,
                  backgroundColor: isListening 
                      ? Colors.red 
                      : Colors.blue,
                  child: Icon(
                    isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                if (isGenerating || isAnimating)
                  IconButton(
                    icon: const Icon(Icons.stop, color: Colors.red),
                    onPressed: stopGenerating,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDot(context, 0),
          _buildDot(context, 1),
          _buildDot(context, 2),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      margin: const EdgeInsets.all(2),
      child: AnimatedOpacity(
        opacity: index == 0 ? 0.3 : index == 1 ? 0.6 : 0.9,
        duration: const Duration(milliseconds: 500),
        child: Container(),
      ),
    );
  }
}