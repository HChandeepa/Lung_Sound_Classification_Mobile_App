import 'package:flutter/material.dart';

class PatientDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Patient Details'),
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildDetailTile("Name", patient['name']),
            _buildDetailTile("NIC", patient['nic']),
            _buildDetailTile("Gender", patient['gender']),
            _buildDetailTile("Birth Day", patient['birthDate']),
            _buildDetailTile("Home Town", patient['homeTown']),
            _buildDetailTile("Phone Number", patient['phone']),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
