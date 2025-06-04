import 'package:flutter/material.dart';

class Undergraduatestatus extends StatelessWidget {
  const Undergraduatestatus({super.key});

  Color _getGPAColor(double gpa) {
    if (gpa >= 3) {
      return Colors.green;
    } else if (gpa > 2) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for GPA and credits
    final Map<String, Map<String, dynamic>> semesters = {
      '1st Year Semester I': {'gpa': 3.5, 'credits': 15},
      '1st Year Semester II': {'gpa': 3.2, 'credits': 16},
      '2nd Year Semester I': {'gpa': 2.8, 'credits': 14},
      '2nd Year Semester II': {'gpa': 3.0, 'credits': 15},
      '3rd Year Semester I': {'gpa': 2.5, 'credits': 12},
      '3rd Year Semester II': {'gpa': 3.7, 'credits': 18},
      '4th Year Semester I': {'gpa': 1.9, 'credits': 10},
      '4th Year Semester II': {'gpa': 3.1, 'credits': 17},
    };

    // Calculate total GPA and credits (you should fetch this from Firestore)
    double totalGPA = 0;
    int totalCredits = 0;
    semesters.forEach((semester, data) {
      totalGPA += (data['gpa'] * data['credits']);
      totalCredits += (data['credits'] as num).toInt(); // Cast to int here
    });
    totalGPA = totalCredits > 0 ? totalGPA / totalCredits : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Undergraduate Status"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 columns
              childAspectRatio: 2.0, // Adjust for box height
              padding: const EdgeInsets.all(8.0),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: semesters.keys.map((String semester) {
                final gpa = semesters[semester]!['gpa'];
                final credits = semesters[semester]!['credits'];
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _getGPAColor(gpa),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        semester,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text('GPA: ${gpa.toStringAsFixed(2)}'),
                      Text('Credits: $credits'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 30,
                  child: Text('GPA: ${totalGPA.toStringAsFixed(2)}'),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 30,
                  child: Text('Credits: $totalCredits'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
