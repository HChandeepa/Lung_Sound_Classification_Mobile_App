import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MicrophonePage extends StatefulWidget {
  const MicrophonePage({super.key});

  @override
  MicrophonePageState createState() => MicrophonePageState();
}

class MicrophonePageState extends State<MicrophonePage> {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isPlaying = false;
  bool _isRecording = false;
  String _currentPlaying = "";
  double _recordingProgress = 0.0;

  final List<Map<String, String>> _audioClips = [
    {'title': 'Audio Clip 1', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Audio Clip 2', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Audio Clip 3', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.openPlayer();
    _audioRecorder.openRecorder();
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  // Function to start or stop recording
  void _toggleRecording() async {
    if (_isRecording) {
      // Stop recording and save the file automatically
      await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
    } else {
      // Get the app's documents directory to save the recording automatically
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDirectory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _audioRecorder.startRecorder(toFile: filePath);
      setState(() {
        _isRecording = true;
      });
      _startRecordingAnimation();
    }
  }

  // Function to simulate recording progress
  void _startRecordingAnimation() async {
    while (_isRecording) {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _recordingProgress += 0.1;
        if (_recordingProgress >= 1.0) {
          _recordingProgress = 1.0;
        }
      });
    }
  }

  // Function to handle play/pause of audio
  void _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.startPlayer(fromURI: _currentPlaying);
      setState(() {
        _isPlaying = true;
      });
    }
  }

  // Function to handle stop of audio
  void _stopPlayback() async {
    await _audioPlayer.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222), // Dark background
      appBar: AppBar(
        title: const Text("Microphone Page"),
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side: Music Library
            Container(
              width: 250,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 51, 55, 56),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Music Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _audioClips.length,
                      itemBuilder: (context, index) {
                        final clip = _audioClips[index];
                        return Card(
                          color: const Color.fromARGB(255, 72, 77, 79),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 15),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const Icon(
                              Icons.audiotrack,
                              color: Colors.white,
                              size: 40,
                            ),
                            title: Text(
                              clip['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _currentPlaying = clip['url']!;
                              });
                              _togglePlayback();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // Middle: Music Player and Recorder
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_currentPlaying.isNotEmpty)
                    Text(
                      "Now Playing: ${_audioClips.firstWhere((clip) => clip['url'] == _currentPlaying)['title']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Beautiful Music Player Controls
                  if (_currentPlaying.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: _togglePlayback,
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: _stopPlayback,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                  // Beautiful Animated Record Button
                  ElevatedButton.icon(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isRecording ? "Stop Recording" : "Record Audio",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Show Recording Progress Animation
                  if (_isRecording)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      height: 10,
                      width: MediaQuery.of(context).size.width * _recordingProgress,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // Right side: Add Music Option
            Container(
              width: 250,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 51, 55, 56),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Music",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open file picker or music upload functionality
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add New Audio Clip",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 72, 77, 79),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
