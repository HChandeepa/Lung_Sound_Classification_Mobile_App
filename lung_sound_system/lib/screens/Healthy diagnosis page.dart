import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthyDiagnosisPage extends StatefulWidget {
  final Map<String, dynamic> diagnosisResult;
  final Map<String, dynamic> patient;

  const HealthyDiagnosisPage({
    super.key,
    required this.diagnosisResult,
    required this.patient,
  });

  @override
  State<HealthyDiagnosisPage> createState() => _HealthyDiagnosisPageState();
}

class _HealthyDiagnosisPageState extends State<HealthyDiagnosisPage> {
  bool _isSaving = false;

  Future<void> _saveHealthyDiagnosisToFirestore() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .where('nic', isEqualTo: widget.patient['nic'])
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (patientDoc.docs.isEmpty) {
        throw Exception('Patient record not found or access denied');
      }

      final visitData = {
        'uid': user.uid,
        'patientId': widget.patient['nic'],
        'patientName': widget.patient['name'],
        'healthy': true,
        'timestamp': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
        'type': 'diagnosis',
      };

      await FirebaseFirestore.instance.collection('visits').add(visitData);

      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: Colors.green[600],
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    content: Row(
      children: const [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Diagnosis saved successfully!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    duration: Duration(seconds: 3),
  ),
);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save Failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.diagnosisResult['timestamp'] ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(
      timestamp is Timestamp ? timestamp.toDate() : timestamp,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Healthy Diagnosis',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 30),
            _buildDiagnosisInfoSection(formattedDate),
            const SizedBox(height: 30),
            _buildImportantNoteSection(),
            const SizedBox(height: 30),
            _buildDisclaimerSection(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Healthy Lung Sound Detected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[300],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'for ${widget.patient['name']}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'NIC: ${widget.patient['nic']}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisInfoSection(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diagnosis Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Analysis Date: $formattedDate',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'The analysis of the uploaded lung sound indicates a healthy respiratory condition. '
          'Our model did not detect any signs of common pulmonary abnormalities in the audio sample.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'While this result is encouraging, it should be interpreted in the context of the patient\'s '
          'complete clinical picture and not as a definitive diagnosis.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Important Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'Clinical Correlation Required: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'This result should be correlated with clinical symptoms, '
                      'physical examination findings, and other diagnostic tests as needed.\n\n',
                ),
                TextSpan(
                  text: 'Persistent Symptoms: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'If the patient experiences persistent respiratory symptoms '
                      '(cough, shortness of breath, chest pain), please consult a healthcare provider '
                      'regardless of this result.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Disclaimer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'This automated analysis is intended as a screening tool only and has limitations:\n\n'
            '• Not a replacement for professional medical evaluation\n'
            '• Accuracy depends on audio quality and recording conditions\n'
            '• May not detect all pulmonary conditions\n'
            '• Should not be used as the sole basis for clinical decisions',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.blueAccent),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Patient'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveHealthyDiagnosisToFirestore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Report'),
          ),
        ),
      ],
    );
  }
}
