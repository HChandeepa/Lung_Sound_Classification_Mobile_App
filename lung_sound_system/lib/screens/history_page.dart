import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy list of patients for demonstration (replace with real data)
  final List<Map<String, String>> _patients = [
    {'nic': '123456789V', 'name': 'John Doe'},
    {'nic': '987654321V', 'name': 'Jane Smith'},
    {'nic': '112233445V', 'name': 'Sam Peterson'},
    {'nic': '556677889V', 'name': 'Amy Lee'},
  ];

  List<Map<String, String>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _patients;
  }

  void _searchPatient(String query) {
    setState(() {
      _filteredPatients =
          _patients
              .where(
                (patient) =>
                    patient['nic']!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Patient History'),
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
              child:
                  _filteredPatients.isEmpty
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
                                patient['name']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'NIC: ${patient['nic']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              onTap: () {
                                // Replace this with navigation to patient details if needed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selected NIC: ${patient['nic']}',
                                    ),
                                  ),
                                );
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
