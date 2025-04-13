import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('uid', isEqualTo: currentUser.uid)
          .get();

      final List<Map<String, dynamic>> patients = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'nic': data['nic'],
          'name': data['name'],
        };
      }).toList();

      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching patients: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchPatient(String query) {
    final filtered = _allPatients.where((patient) {
      return patient['nic']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPatients = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPatientDetails(String nic) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(nic)
        .get();

    if (snapshot.exists) {
      final patientData = snapshot.data()!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailsPage(patient: patientData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient details not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        automaticallyImplyLeading: false, // 👈 This disables the back button
        title: const Text('Patients',style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: _searchPatient,
              decoration: InputDecoration(
                hintText: 'Search by Patient NIC...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPatients.isEmpty
                      ? const Center(
                          child: Text(
                            'No patients found',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return Card(
                              color: const Color(0xFF333333),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                ),
                                title: Text(
                                  patient['name'] ?? 'Unknown',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'NIC: ${patient['nic']}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  _openPatientDetails(patient['nic']);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
