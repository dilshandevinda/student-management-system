import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({Key? key}) : super(key: key);

  @override
  State<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAcademicYear;
  String _selectedDepartment = 'ITT'; // Default department
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  bool _allowMultipleAnswers = false;

  // Dropdown options for academic year
  final List<String> _academicYears = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year'
  ];

  // Function to add poll to Firestore
  Future<void> _createPoll() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('polls').add({
          'academicYear': _selectedAcademicYear,
          'department': _selectedDepartment,
          'question': _questionController.text,
          'option1': _option1Controller.text,
          'option2': _option2Controller.text,
          'allowMultipleAnswers': _allowMultipleAnswers,
          'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
          'votes': {
            // Initialize votes (can be modified based on your structure)
            _option1Controller.text: 0,
            _option2Controller.text: 0,
          }
        });

        // Show a success message (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll created successfully!')),
        );

        // Clear the form
        setState(() {
          _selectedAcademicYear = null;
          _selectedDepartment = 'ITT';
          _questionController.clear();
          _option1Controller.clear();
          _option2Controller.clear();
          _allowMultipleAnswers = false;
        });
      } catch (e) {
        // Handle errors (e.g., show an error message)
        print("Error creating poll: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating poll: $e')),
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
        title: const Text(''), // Remove title
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
                    'Create Poll',
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
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
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
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _option1Controller,
                  decoration: InputDecoration(
                    labelText: 'Option 1',
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
                      return 'Please enter option 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _option2Controller,
                  decoration: InputDecoration(
                    labelText: 'Option 2',
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
                      return 'Please enter option 2';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Text("Allow multiple answers"),
                    Switch(
                      value: _allowMultipleAnswers,
                      onChanged: (value) {
                        setState(() {
                          _allowMultipleAnswers = value;
                        });
                      },
                      activeColor: Colors.black, // Customize as needed
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _createPoll,
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
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    super.dispose();
  }
}
