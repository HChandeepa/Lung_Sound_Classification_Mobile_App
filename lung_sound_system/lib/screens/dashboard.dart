import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// Import other pages
import 'microphone_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _timeString = "";
  String _dateString = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('hh:mm a').format(now);
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    setState(() {
      _timeString = formattedTime;
      _dateString = formattedDate;
    });
  }

  void _onItemTapped(int index) {
    Widget page;
    switch (index) {
      case 1:
        page = const MicrophonePage();
        break;
      case 2:
        page = const ChatPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222), // Dark background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 40.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            _timeString,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _dateString,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const Spacer(),
Padding(
  padding: const EdgeInsets.only(bottom: 28), // Add margin to bottom
  child: SizedBox(
    width: 800, // Change this value to increase/decrease width
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(33, 33, 33, 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white70, size: 28),
            onPressed: () => _onItemTapped(1),
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white70, size: 28),
            onPressed: () => _onItemTapped(2),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white70, size: 28),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
    ),
  ),
),
        ],
      ),
    );
  }
  
}
