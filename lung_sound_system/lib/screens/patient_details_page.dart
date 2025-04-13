import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<String> _severities = [];

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _diseases = [];
          _probabilities = [];
          _severities = [];
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to pick file: $e";
      });
    }
  }

  Future<void> _uploadAndClassify() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = "Please select a WAV file first";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var uri = Uri.parse("https://hchandeepa-pulmosense-ai.hf.space/Predict");
      var bytes = await _selectedFile!.readAsBytes();

      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "audio/wav",
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print("API Response: $responseData");

        if (responseData['result'] == false || responseData['healthy'] == true) {
          // Navigate to HealthyDiagnosisPage and wait for return
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthyDiagnosisPage(
                patient: widget.patient,
              ),
            ),
          );
          
          // Reset state when returning from HealthyDiagnosisPage
          setState(() {
            _selectedFile = null;
            _diseases = [];
            _probabilities = [];
            _severities = [];
            _isLoading = false;
          });
        } else {
          // Navigate to DiseasedDiagnosisPage with the results
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiseasedDiagnosisPage(
                patient: widget.patient,
                diseases: List<String>.from(responseData['diseases'] ?? []),
                probabilities: (responseData['probabilities'] as List?)
                    ?.map((p) => (p as num).toDouble())
                    .toList() ?? [],
              ),
            ),
          );
          
          // Reset state when returning from DiseasedDiagnosisPage
          setState(() {
            _selectedFile = null;
            _diseases = [];
            _probabilities = [];
            _severities = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode} - ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error occurred: $e";
        _isLoading = false;
      });
      print("Error details: $e");
    }
  }

  Widget _buildPredictionResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      );
    }

    if (_errorMessage != null) {
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

    if (_diseases.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "PREDICTION RESULTS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ..._diseases.asMap().entries.map((entry) {
          final index = entry.key;
          final disease = entry.value;
          final probability = (_probabilities[index] * 100).toStringAsFixed(2);
          final severity = _severities[index];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.blueAccent,
                ),
              ),
              title: Text(
                disease,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Probability: $probability%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Severity: $severity',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.white70,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String? value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Patient Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
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
                  _buildDetailTile(Icons.person, "Name", widget.patient['name']),
                  _buildDetailTile(Icons.badge, "NIC", widget.patient['nic']),
                  _buildDetailTile(Icons.wc, "Gender", widget.patient['gender']),
                  _buildDetailTile(Icons.cake, "Birth Day", widget.patient['birthDate']),
                  _buildDetailTile(Icons.location_city, "Home Town", widget.patient['homeTown']),
                  _buildDetailTile(Icons.phone, "Phone Number", widget.patient['phone']),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF2C2C2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  ),
                  const SizedBox(height: 16),
                  _buildPredictionResults(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}