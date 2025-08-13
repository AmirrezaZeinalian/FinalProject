import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

const String CURRENT_USER_EMAIL = 'example@example.com'; // IMPORTANT: Replace with actual user email

class SpotifySupportApp extends StatelessWidget {
  // We'll pass the userEmail from the parent widget (e.g., ProfileTab)
  final String userEmail;

  const SpotifySupportApp({super.key, this.userEmail = CURRENT_USER_EMAIL}); // Default for testing

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Support',
      debugShowCheckedModeBanner: false, // Set to false to remove the debug banner
      theme: ThemeData(
        primarySwatch: Colors.purple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF673AB7), // Deep purple for app bar
          foregroundColor: Colors.white, // White text for app bar title
          elevation: 0, // Remove shadow from app bar
          centerTitle: true, // Center app bar title by default
        ),
        // Make scaffold background a deeper purple
        scaffoldBackgroundColor: const Color(0xFF4A148C), // A darker, richer purple
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70), // Lighter text for dark background
          bodyMedium: TextStyle(color: Colors.white70),
          // Add a default style for app bar title if needed
          titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ).apply(
          bodyColor: Colors.white, // Default text color for the entire app
          displayColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0), // A slightly brighter purple for buttons
            foregroundColor: Colors.white, // White button text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0), // More rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), // Larger padding
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.15), // Slightly transparent white for input fields
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)), // Lighter hint text
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none, // No border line
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.deepPurpleAccent.shade100, width: 2.0), // Highlight on focus
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      home: SupportChatScreen(userEmail: userEmail), // Pass user email to chat screen
    );
  }
}

class SupportChatScreen extends StatefulWidget {
  final String userEmail; // To receive the user's email

  const SupportChatScreen({super.key, required this.userEmail});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = []; // List to hold messages
  final ScrollController _scrollController = ScrollController(); // For auto-scrolling

  @override
  void initState() {
    super.initState();
    // Add an initial welcome message from support
    _messages.add({
      'sender': 'support',
      'text': 'Hi there! How can I help you with your Spotify account today?',
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final String userMessage = _messageController.text;

      setState(() {
        _messages.add({'sender': 'user', 'text': userMessage});
      });
      _messageController.clear();

      // Scroll to the bottom after adding a new message
      _scrollToBottom();

      try {
        const String serverIp = '192.168.100.3';
        const int serverPort = 13579; // The PROFILE port for contact action

        final Socket socket = await Socket.connect(serverIp, serverPort);
        print('Connected to backend for support message.');

        final Map<String, String> requestData = {
          'action': 'contact',
          'email': widget.userEmail, // Send the user's email
          'message': userMessage,
        };
        final String jsonString = jsonEncode(requestData);

        socket.writeln(jsonString);
        await socket.flush();

        print('Sent JSON to backend: $jsonString');

        // Listen for the response from the server
        await for (String response in socket.transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>).transform(const LineSplitter())) {
          print('Received response from backend: $response');
          try {
            final Map<String, dynamic> jsonResponse = jsonDecode(response);
            final String status = jsonResponse['status'];
            final String backendMessage = jsonResponse['message'];

            setState(() {
              _messages.add({'sender': 'support', 'text': backendMessage});
            });
            _scrollToBottom(); // Scroll after receiving backend response

            if (status == 'success') {
              print('Message sent successfully according to backend.');
            } else {
              print('Backend reported an error: $backendMessage');
            }
          } catch (e) {
            print('Error decoding JSON response from backend: $e');
            setState(() {
              _messages.add({'sender': 'support', 'text': 'Error processing server response.'});
            });
            _scrollToBottom();
          }
          break;
        }

        socket.close();
      } catch (e) {
        print('Error sending message to backend: $e');
        setState(() {
          _messages.add({'sender': 'support', 'text': 'Failed to send message. Please try again later.'});
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Support'), // Consistent title
        // No need for centerTitle: true here, as it's set in AppBarTheme
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Assign scroll controller
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      isUser ? 60.0 : 8.0, // User messages start further right
                      8.0,
                      isUser ? 8.0 : 60.0, // Support messages start further left
                      8.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF673AB7) : const Color(0xFF9C27B0), // Different shades of purple
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16.0),
                        topRight: const Radius.circular(16.0),
                        bottomLeft: isUser ? const Radius.circular(16.0) : const Radius.circular(4.0), // Pointed bottom-left for support
                        bottomRight: isUser ? const Radius.circular(4.0) : const Radius.circular(16.0), // Pointed bottom-right for user
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Slightly darker shadow
                          blurRadius: 7, // Increased blur
                          offset: const Offset(0, 3), // More pronounced shadow
                        ),
                      ],
                    ),
                    child: Text(
                      message['text']!,
                      style: const TextStyle(color: Colors.white, fontSize: 15), // Slightly larger text
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input area
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4A148C).withOpacity(0.8), // Slightly transparent background for input area
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, -5), // Shadow at the top of the input area
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4, // Allow multiple lines for longer messages
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white), // Input text color
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1), // Input field background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.deepPurpleAccent.shade100, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true, // Make it smaller
                  backgroundColor: const Color(0xFF673AB7), // Match app bar color
                  foregroundColor: Colors.white,
                  elevation: 5,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }
}