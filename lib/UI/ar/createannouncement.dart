import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({Key? key}) : super(key: key);

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAcademicYear;
  String _selectedDepartment = 'ITT'; // Default department
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown options for academic year
  final List<String> _academicYears = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year'
  ];

  // Function to add announcement to Firestore
  Future<void> _createAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('announcements').add({
          'academicYear': _selectedAcademicYear,
          'department': _selectedDepartment,
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
          'seen': false, // Add the 'seen' field with default value false
        });

        // Show a success message (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement created successfully!')),
        );

        // Clear the form
        setState(() {
          _selectedAcademicYear = null;
          _selectedDepartment = 'ITT';
          _subjectController.clear();
          _descriptionController.clear();
        });
      } catch (e) {
        // Handle errors (e.g., show an error message)
        print("Error creating announcement: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating announcement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.black,
            onPressed: () {
              // Handle notification icon press (if needed)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Create Announcement',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Academic Year',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: _selectedAcademicYear,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedAcademicYear = newValue;
                    });
                  },
                  items: _academicYears
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an academic year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  'Select Department',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRadioOption('ITT'),
                    _buildRadioOption('EET'),
                    _buildRadioOption('FDT'),
                    _buildRadioOption('BPT'),
                  ],
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _createAnnouncement,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: option,
          groupValue: _selectedDepartment,
          onChanged: (value) {
            setState(() {
              _selectedDepartment = value!;
            });
          },
          activeColor: Colors.black,
          fillColor: MaterialStateProperty.all<Color>(Colors.black),
        ),
        Text(option),
      ],
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
