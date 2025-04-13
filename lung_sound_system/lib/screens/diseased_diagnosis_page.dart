import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class DiseasedDiagnosisPage extends StatefulWidget {
  final Map<String, dynamic> patient;
  final List<String> diseases;
  final List<double> probabilities;

  const DiseasedDiagnosisPage({
    super.key,
    required this.patient,
    required this.diseases,
    required this.probabilities,
  });

  @override
  State<DiseasedDiagnosisPage> createState() => _DiseasedDiagnosisPageState();
}

class _DiseasedDiagnosisPageState extends State<DiseasedDiagnosisPage> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final topDiseases = widget.diseases.take(3).toList();
    final topProbs = widget.probabilities.take(3).toList();

    final dataMap = {
      for (int i = 0; i < topDiseases.length; i++) topDiseases[i]: topProbs[i] * 100,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Diseased Diagnosis",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This page provides diagnosis results based on the uploaded lung sound.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            PieChart(
              dataMap: dataMap,
              chartType: ChartType.disc,
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValueBackground: false,
                showChartValuesOutside: true,
                chartValueStyle: TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              colorList: const [
                Colors.redAccent,
                Colors.orangeAccent,
                Colors.yellowAccent,
              ],
              legendOptions: const LegendOptions(
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendTextStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            _buildDiseaseList(),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Text(
                  _showAll ? 'Show less' : 'Show more',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const Text(
              'Note:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const Text(
              'This application is capable of diagnosing only 10 lung diseases:\n'
              'Asthma, Bronchiectasis, Bronchiolitis, Bronchitis, COPD, Lung Fibrosis, '
              'Pleural Effusion, Pneumonia, URTI.\n\n'
              'Please consult a medical professional before taking any medication based on this result.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 20), // Added extra space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseList() {
    final int count = _showAll ? widget.diseases.length : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (index) {
        final disease = widget.diseases[index];
        final prob = (widget.probabilities[index] * 100).toStringAsFixed(2);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.coronavirus_outlined,
              color: Colors.redAccent,
            ),
            title: Text(
              disease,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Probability: $prob%',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      }),
    );
  }
}