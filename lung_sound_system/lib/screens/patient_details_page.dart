import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Healthy diagnosis page.dart';
import 'diseased_diagnosis_page.dart';

class PatientDetailsPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsPage({super.key, required this.patient});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  File? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _diseases = [];
  List<double> _probabilities = [];

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav'],
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "File selection failed: ${e.toString()}";
      });
    }
  }

  Future<void> _uploadAndClassify() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = "Please select a WAV file first");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(
        "https://hchandeepa-pulmosense-ai.hf.space/Predict",
      );
      final bytes = await _selectedFile!.readAsBytes();

      final response = await http
          .post(uri, headers: {"Content-Type": "audio/wav"}, body: bytes)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _handleApiResponse(responseData);
      } else {
        throw "Server responded with ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Analysis failed: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _handleApiResponse(Map<String, dynamic> responseData) {
    print("API Response: $responseData");

    if (responseData['healthy'] == true || responseData['result'] == false) {
      _navigateToHealthyPage();
    } else {
      _navigateToDiseasedPage(responseData);
    }
  }

  Future<void> _navigateToHealthyPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthyDiagnosisPage(
          patient: widget.patient,
          diagnosisResult: {'healthy': true, 'timestamp': DateTime.now()},
        ),
      ),
    );
    _resetState();
  }

  Future<void> _navigateToDiseasedPage(Map<String, dynamic> responseData) async {
    final diseases = List<String>.from(responseData['diseases'] ?? []);
    final probabilities = (responseData['probabilities'] as List?)
            ?.map((p) => (p is num ? p.toDouble() : double.tryParse(p.toString()) ?? 0.0))
            .toList() ??
        [];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseasedDiagnosisPage(
          patient: widget.patient,
          diseases: diseases,
          probabilities: probabilities,
        ),
      ),
    );
    _resetState();
  }

  void _resetState() {
    setState(() {
      _isLoading = false;
      _selectedFile = null;
      _diseases = [];
      _probabilities = [];
    });
  }

  Widget _buildFileSelectionCard() {
    return Card(
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LUNG SOUND ANALYSIS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _pickAudioFile,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    _selectedFile?.path.split('/').last ?? 'SELECT WAV FILE',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadAndClassify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'ANALYZE SOUND',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetailTile(IconData icon, String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          value ?? 'N/A',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

 Widget _buildVisitHistorySection() {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return const SizedBox(); // Or show a sign-in prompt
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Text(
          "VISIT HISTORY",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
      ),
      const SizedBox(height: 12),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('visits')
            .where('patientId', isEqualTo: widget.patient['nic'])
            .where('uid', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Error loading visit history',
                style: TextStyle(color: Colors.red[400]),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No visit history found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final visit = doc.data() as Map<String, dynamic>;
              return _buildVisitCard(visit);
            },
          );
        },
      ),
    ],
  );
}

Widget _buildVisitCard(Map<String, dynamic> visit) {
  final timestamp = visit['timestamp'] as Timestamp?;
  final date = timestamp != null
      ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate())
      : 'Date not available';

  final isHealthy = visit['healthy'] == true;
  final diseases = visit['diseases'] is List ? List<String>.from(visit['diseases']) : [];
  final probabilities = visit['probabilities'] is List
      ? List<double>.from(
          (visit['probabilities'] as List).map((p) => p is num ? p.toDouble() : 0.0))
      : [];

  return Card(
    color: const Color(0xFF2C2C2E),
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                visit['type']?.toString().toUpperCase() ?? 'DIAGNOSIS',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isHealthy)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Healthy Lung Sound Detected',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else if (diseases.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detected Conditions:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(diseases.length, (index) {
                  final disease = diseases[index];
                  final prob = index < probabilities.length
                      ? '${(probabilities[index] * 100).toStringAsFixed(1)}%'
                      : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            disease,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          prob,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Patient Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PROFILE INFORMATION",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildPatientDetailTile(
                    Icons.person,
                    "Name",
                    widget.patient['name'],
                  ),
                  _buildPatientDetailTile(
                    Icons.badge,
                    "NIC",
                    widget.patient['nic'],
                  ),
                  _buildPatientDetailTile(
                    Icons.wc,
                    "Gender",
                    widget.patient['gender'],
                  ),
                  _buildPatientDetailTile(
                    Icons.cake,
                    "Birth Day",
                    widget.patient['birthDate'],
                  ),
                  _buildPatientDetailTile(
                    Icons.location_city,
                    "Home Town",
                    widget.patient['homeTown'],
                  ),
                  _buildPatientDetailTile(
                    Icons.phone,
                    "Phone Number",
                    widget.patient['phone'],
                  ),
                  const SizedBox(height: 24),
                  _buildFileSelectionCard(),
                  _buildErrorWidget(),
                  const SizedBox(height: 24),
                  _buildVisitHistorySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}