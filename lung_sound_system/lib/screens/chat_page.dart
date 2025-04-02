import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChatPage(),
  ));
}

class Contact {
  final String name;
  final String profilePicUrl;
  final List<String> messages;

  Contact({
    required this.name,
    required this.profilePicUrl,
    required this.messages,
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final List<Contact> contacts = [
    Contact(name: 'Janith', profilePicUrl: 'https://www.example.com/profile1.jpg', messages: ['Hello!', 'How are you?']),
    Contact(name: 'Charith', profilePicUrl: 'https://www.example.com/profile2.jpg', messages: ['Hey!', 'What\'s up?']),
    Contact(name: 'Dinuvi', profilePicUrl: 'https://www.example.com/profile3.jpg', messages: ['Hi!', 'Long time no see.']),
    Contact(name: 'Kenath', profilePicUrl: 'https://www.example.com/profile7.jpg', messages: ['Hey!', 'How\'s it going?']),
    Contact(name: 'Chandeepa', profilePicUrl: 'https://www.example.com/profile8.jpg', messages: ['Hi!', 'Can you help me with something?']),
    Contact(name: 'Manu', profilePicUrl: 'https://www.example.com/profile10.jpg', messages: ['Hey!', 'Let\'s hang out soon!']),
  ];

  late Contact selectedContact;

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedContact = contacts[0]; // Default to first contact
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Send message to the selected contact
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        selectedContact.messages.add(_messageController.text); // Add message to the selected contact's messages
      });
      _messageController.clear(); // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222), // Dark background
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings functionality
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side: Contact List with Group Option
          Container(
            width: 320,
            color: const Color(0xFF222222), // Dark background
            child: Column(
              children: [
                const SizedBox(height: 20), // Space on top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Contacts & Groups',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24),
Expanded(
  child: ListView.builder(
    itemCount: contacts.length + 1, // One extra for "Create Group" option
    itemBuilder: (context, index) {
      if (index == contacts.length) {
        return ListTile(
          leading: const Icon(Icons.group, color: Colors.white),
          title: const Text(
            'Create Group',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            // Handle group creation logic here
          },
          tileColor: Colors.blueGrey[700],
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18), // Add 10 units of space between each contact
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(contacts[index].profilePicUrl),
            radius: 30,
          ),
          title: Text(
            contacts[index].name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          onTap: () {
            setState(() {
              selectedContact = contacts[index]; // Set the selected contact
            });
          },
          tileColor: selectedContact == contacts[index] ? Colors.blueGrey[700] : Colors.transparent,
        ),
      );
    },
  ),
),

              ],
            ),
          ),

          // Divider to separate the two sections
          const VerticalDivider(
            color: Colors.white24,
            thickness: 1,
          ),

          // Right side: Chat Interface
          Expanded(
            child: Column(
              children: [
                // Header for the selected contact
                Container(
                  color: Colors.blueGrey[900],
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(selectedContact.profilePicUrl),
                        radius: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedContact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  color: Colors.white24,
                  thickness: 1,
                ),

                // Display chat messages
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedContact.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(selectedContact.messages[index], index % 2 == 0);
                    },
                  ),
                ),

                // Message input field and send button
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      // Text Field for input
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),

                      // Send Button
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a chat message
  Widget _buildMessage(String text, bool isSentByUser) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blueAccent : Colors.grey[700],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
