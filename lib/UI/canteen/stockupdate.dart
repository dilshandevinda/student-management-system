import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class stockupdate extends StatefulWidget {
  const stockupdate({super.key});

  @override
  _AddFoodItemPageState createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<stockupdate> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCanteen;
  String? _selectedFoodItem;
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  final List<String> _canteenNames = [
    'Dutugemunu',
    'Viharamahadevi',
    'Technology Faculty Canteen',
    'Applied Science Faculty Canteen',
    'Social',
    'Milk Bar'
  ];

  final List<String> _foodItems = [
    'Rice and Curry',
    'Noodles',
    'Kottu',
    'String Hoppers'
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _addFoodItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('canteen').add({
          'canteenname': _selectedCanteen,
          'foodname': _selectedFoodItem,
          'foodprice': _priceController.text,
          'stock': _stockController.text,
          'fooditemimage': '' // You might want to update this later
        });

        // Clear the form fields
        setState(() {
          _selectedCanteen = null;
          _selectedFoodItem = null;
        });
        _priceController.clear();
        _stockController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item added successfully!')),
        );
      } catch (e) {
        print("Error adding food item: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding food item: $e")),
        );
      }
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
          'Update Canteen Stock',
          style: TextStyle(color: Color.fromARGB(255, 49, 66, 148)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Canteen Name Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Canteen Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedCanteen,
                items: _canteenNames.map((canteen) {
                  return DropdownMenuItem<String>(
                    value: canteen,
                    child: Text(canteen),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCanteen = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a canteen';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Food Item Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedFoodItem,
                items: _foodItems.map((foodItem) {
                  return DropdownMenuItem<String>(
                    value: foodItem,
                    child: Text(foodItem),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFoodItem = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a food item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Price Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter price',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Stock Field
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  hintText: 'Enter stock amount',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a stock amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Update Button
              Center(
                child: ElevatedButton(
                  onPressed: _addFoodItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 49, 66, 148),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
