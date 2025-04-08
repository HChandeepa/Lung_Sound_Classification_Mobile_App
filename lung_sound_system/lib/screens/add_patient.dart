import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _homeTownController = TextEditingController();
  String _phoneNumber = '';

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _genderController.dispose();
    _birthDayController.dispose();
    _homeTownController.dispose();
    super.dispose();
  }

  void _showGenderSelection() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Select Gender',
          style: TextStyle(color: Colors.white),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                _genderController.text = 'Male';
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/male.jpg', width: 80, height: 80),
                  const SizedBox(height: 5),
                  const Text('Male', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _genderController.text = 'Female';
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/female.jpg', width: 80, height: 80),
                  const SizedBox(height: 5),
                  const Text('Female', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              surface: Color(0xFF2C2C2C),
              onSurface: Colors.white,
            ),
            dialogTheme:
                const DialogTheme(backgroundColor: Color(0xFF2C2C2C)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _birthDayController.text = formattedDate;
      });
    }
  }

  Future<void> _savePatientData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is logged in')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(_nicController.text.trim())
          .set({
        'name': _nameController.text.trim(),
        'nic': _nicController.text.trim(),
        'gender': _genderController.text.trim(),
        'birthDate': _birthDayController.text.trim(),
        'homeTown': _homeTownController.text.trim(),
        'phone': _phoneNumber,
        'uid': currentUser.uid,  // Store the user's UID with the patient data
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient information saved successfully')),
      );
      Navigator.pop(context); // Or navigate to another screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save patient info: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Patient Info'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField("Patient Name*", "Please enter patient name", _nameController),
                        _buildTextField("Patient NIC*", "Please enter patient ID", _nicController),
                        _buildGenderField(),
                        _buildBirthDateField(),
                        _buildTextField("Home Town", "Please enter patient's Home town", _homeTownController),
                        _buildPhoneField(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _savePatientData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _showGenderSelection,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _genderController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Gender* (Tap to select)",
              labelStyle: TextStyle(color: Colors.white),
              hintText: "Please select patient gender",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'This field is required' : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBirthDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _selectBirthDate,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _birthDayController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Birth Day",
              labelStyle: TextStyle(color: Colors.white),
              hintText: "Please enter patient's birth date",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Please select birth date' : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IntlPhoneField(
        decoration: const InputDecoration(
          labelText: 'Contact No*',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          hintText: 'Enter phone number',
          hintStyle: TextStyle(color: Colors.white54),
        ),
        style: const TextStyle(color: Colors.white),
        dropdownTextStyle: const TextStyle(color: Colors.white),
        initialCountryCode: 'LK',
        onChanged: (phone) {
          _phoneNumber = phone.completeNumber;
        },
        validator: (phone) {
          if (_phoneNumber.isEmpty) {
            return 'Please enter a valid contact number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (label.contains('*') && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}
