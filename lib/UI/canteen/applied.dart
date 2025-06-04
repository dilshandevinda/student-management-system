import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class applied extends StatefulWidget {
  const applied({super.key});

  @override
  _AppliedFacultyCanteenState createState() => _AppliedFacultyCanteenState();
}

class _AppliedFacultyCanteenState extends State<applied> {
  List<Map<String, dynamic>> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  _fetchFoodItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('canteen')
          .where('canteenname',
              isEqualTo: 'Applied Faculty') // Changed canteen name
          .get();

      List<Map<String, dynamic>> items = [];
      querySnapshot.docs.forEach((doc) {
        items.add(doc.data() as Map<String, dynamic>);
      });

      setState(() {
        _foodItems = items;
      });
    } catch (e) {
      print("Error fetching food items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching food items: $e")),
      );
    }
  }

  // Function to get the default image URL based on food name
  Future<String> _getDefaultImageURL(String foodName) async {
    try {
      String imageName;
      switch (foodName.toLowerCase()) {
        case 'kottu':
          imageName = 'kottu.jpg';
          break;
        case 'noodles':
          imageName = 'noodles.jpg';
          break;
        case 'rice and curry':
          imageName = 'riceandcurry.jpg';
          break;
        case 'string hoppers':
          imageName = 'stringhoppers.jpg';
          break;
        default:
          imageName = 'placeholder.jpg'; // Default image in case of no match
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('canteenfood/$imageName'); // Path in Firebase Storage
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Error getting default image URL for $foodName: $e");
      return 'assets/placeholder.jpg'; // Placeholder image in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 218, 254),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Applied Faculty Canteen', // Changed canteen name
          style: TextStyle(color: Color.fromARGB(255, 49, 66, 148)),
        ),
        centerTitle: true, // Center the title
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _foodItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _foodItems.length,
                      itemBuilder: (context, index) {
                        return _buildFoodItemCard(context, _foodItems[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 66, 148),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: FutureBuilder<String>(
                future: _getDefaultImageURL(item['foodname']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      // Check if the URL is a Firebase Storage URL or a local asset
                      if (snapshot.data!.startsWith('http')) {
                        return Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error");
                            return const Icon(Icons.fastfood,
                                size: 40, color: Colors.white);
                          },
                        );
                      } else {
                        // Load from assets if it's a local asset path
                        return Image.asset(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error");
                            return const Icon(Icons.fastfood,
                                size: 40, color: Colors.white);
                          },
                        );
                      }
                    } else {
                      // Return the placeholder image if the URL is empty
                      return Image.asset(
                        'assets/placeholder.jpg', // Correct path to your asset
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    }
                  } else if (snapshot.hasError) {
                    print("Error loading image: ${snapshot.error}");
                    return const Icon(Icons.fastfood,
                        size: 40, color: Colors.white);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['foodname'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: Rs.${item['foodprice']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${item['stock']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
