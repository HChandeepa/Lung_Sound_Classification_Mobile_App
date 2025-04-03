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
  List<Map<String, dynamic>> messages;

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
    Contact(name: 'Janith', profilePicUrl: 'https://www.example.com/profile1.jpg', messages: [
      {'text': 'Hello!', 'isUser': false},
      {'text': 'How are you?', 'isUser': false},
    ]),
    Contact(name: 'Charith', profilePicUrl: 'https://www.example.com/profile2.jpg', messages: [
      {'text': 'Hey!', 'isUser': false},
      {'text': "What's up?", 'isUser': false},
    ]),
  ];

  late Contact selectedContact;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedContact = contacts[0];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        selectedContact.messages.add({'text': _messageController.text, 'isUser': true});
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text("Chat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF181818),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          // Contact List
          Container(
            width: 280,
            color: const Color(0xFF333333),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Contacts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(contacts[index].profilePicUrl),
                          radius: 25,
                        ),
                        title: Text(
                          contacts[index].name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            selectedContact = contacts[index];
                          });
                        },
                        tileColor: selectedContact == contacts[index] ? Colors.blueGrey[700] : Colors.transparent,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat Interface
          Expanded(
            child: Column(
              children: [
                // Selected Contact Header
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
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.white24, thickness: 1),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedContact.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(
                        selectedContact.messages[index]['text'],
                        selectedContact.messages[index]['isUser'],
                      );
                    },
                  ),
                ),

                // Message Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
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

  // Chat Message Widget
  Widget _buildMessage(String text, bool isSentByUser) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blueAccent : Colors.grey[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
