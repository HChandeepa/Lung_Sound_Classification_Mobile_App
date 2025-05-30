import 'package:flutter/material.dart';

class NewPatientAuscultationPage extends StatelessWidget {
  final String patientName;
  final String patientNIC;
  final String gender;
  final String birthDate;
  final String homeTown;
  final String phoneNumber;

  const NewPatientAuscultationPage({
    super.key,
    required this.patientName,
    required this.patientNIC,
    required this.gender,
    required this.birthDate,
    required this.homeTown,
    required this.phoneNumber,
  });

  void _showDiagnosisOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text(
            'Choose Diagnosis Method',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('UPLOAD AUDIO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Handle Upload Audio
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.mic),
                label: const Text('RECORD AUDIO'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  // Handle Record Audio
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Colors.white30, thickness: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('New Patient Diagnosis'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Info Section with Card
            Card(
              color: const Color(0xFF333333),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile('Name', patientName),
                    _buildDivider(),
                    _buildInfoTile('NIC', patientNIC),
                    _buildDivider(),
                    _buildInfoTile('Gender', gender),
                    _buildDivider(),
                    _buildInfoTile('Birth Date', birthDate),
                    _buildDivider(),
                    _buildInfoTile('Home Town', homeTown),
                    _buildDivider(),
                    _buildInfoTile('Phone', phoneNumber),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Diagnosis Button Section
            Center(
              child: ElevatedButton(
                onPressed: () => _showDiagnosisOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'CHECK DIAGNOSIS',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
