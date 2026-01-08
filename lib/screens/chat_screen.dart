import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_ai_assistant/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final model = GenerativeModel(
    model: 'gemini-2.5-flash', 
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? ' ',
  );

  final TextEditingController _controller = TextEditingController();
  
  final List<Message> _messages = []; 
  bool _isLoading = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  int _chatVersion = 0;

  static const String _welcomeText = 'Hi there! I am SIMY, your AI assistant. How can I help you today?';

  void _addWelcomeMessage() {
      _messages.add(Message(text: _welcomeText, isUser: false, timestamp: DateTime.now()));
  }

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_history', encodedData);
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('chat_history');
    if (storedData != null) {
      final List<dynamic> decodedData = jsonDecode(storedData);
      setState(() {
        _messages.clear();
        _messages.addAll(decodedData.map((json) => Message.fromJson(json)).toList());
      });
    } else {
      _addWelcomeMessage();
    }
  }

  void _resetChat() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      _chatVersion++;
      _messages.clear();
      _isLoading = false;
      _selectedImage = null;
      _addWelcomeMessage();
    });

    _saveChatHistory();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final image = _selectedImage;
    if (text.isEmpty && image == null) return;

    _controller.clear();

    final int versionAtStart = _chatVersion;

    setState(() {
      _messages.add(Message(text: text, isUser: true, image: image, timestamp: DateTime.now()));
      _isLoading = true;
      _selectedImage = null;
    });

    _saveChatHistory();

    try {
      GenerateContentResponse response;

      if (image != null) {
        final imageBytes = await image.readAsBytes();
        final content = [
          Content.multi([
            TextPart(text.isEmpty ? "Describe this image." : text),
            DataPart('image/jpeg', imageBytes),
          ])
        ];
        response = await model.generateContent(content);
      } else {
        final content = [Content.text(text)];
        response = await model.generateContent(content);
      }

      if (!mounted || versionAtStart != _chatVersion) return;

      setState(() {
        _messages.add(Message(
          text: response.text ?? 'Error parsing response.', 
          isUser: false,
          image: image,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _saveChatHistory();

    } catch (e) {
      if (!mounted || versionAtStart != _chatVersion) return;
      setState(() {
        _messages.add(Message(text: 'Error: $e', isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });

      _saveChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text('SIMY'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            onPressed: _resetChat, 
            icon: const Icon(Icons.delete)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, 
              itemCount: _messages.reversed.length,
              itemBuilder: (context, index) {
                final message = _messages.reversed.toList()[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          
          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("SIMY 💭", style: TextStyle(color: Colors.grey)),
            ),
          
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 100,
              alignment: Alignment.centerLeft,
              color: Colors.white,
              child: Stack(
                children: [
                  Image.file(_selectedImage!),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () => setState(() => _selectedImage = null), 
                      icon: const Icon(Icons.close, color: Colors.blueGrey),))
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.camera), 
                  icon: const Icon(Icons.camera_alt, color: Colors.blueGrey)),
                IconButton(
                  onPressed: () => _pickImage(ImageSource.gallery), 
                  icon: const Icon(Icons.photo, color: Colors.blueGrey)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Send a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
               IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueGrey),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blueGrey[100] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: message.isUser ? const Radius.circular(15) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(message.image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(message.image!, width: 200, fit: BoxFit.cover),
                ),
              ),
              message.isUser
            ? Text(message.text, style: const TextStyle(fontSize: 16))
            : MarkdownBody( 
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isUser ? Colors.blueGrey[600] : Colors.grey,
                  ),
                ),
              )
          ],
        )
      ),
    );
  }
}