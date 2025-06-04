// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ProfileAndSecurity extends StatefulWidget {
  const ProfileAndSecurity({super.key});

  @override
  _ProfileAndSecurityPageState createState() => _ProfileAndSecurityPageState();
}

class _ProfileAndSecurityPageState extends State<ProfileAndSecurity> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  String? _userName;
  String? _userEmail;
  String? _userImageUrl;
  DateTime? _userBirthdate;
  String? _userAddressLine1;
  String? _userAddressLine2;
  String? _userCity;
  String? _userDistrict;
  String? _userPostalCode;
  String? _userPrivateContact;
  String? _userParentContact;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['username'] ?? '';
          _userEmail = data['email'] ?? '';
          _userImageUrl = data['imageUrl'];
          _userBirthdate = data['birthdate']?.toDate();
          _userAddressLine1 = data['addressLine1'];
          _userAddressLine2 = data['addressLine2'];
          _userCity = data['city'];
          _userDistrict = data['district'];
          _userPostalCode = data['postalCode'];
          _userPrivateContact = data['privateContact'];
          _userParentContact = data['parentContact'];
        });
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Upload to Firebase Storage (Corrected Path)
        Reference ref = _storage.ref().child('users/${_user!.uid}/profile.jpg');
        UploadTask uploadTask = ref.putFile(File(image.path));

        // 2. Await Completion and Get Download URL
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // 3. Update Firestore Document
        await _firestore.collection('users').doc(_user!.uid).update({
          'imageUrl': downloadUrl,
        });

        // 4. Update Local State
        setState(() {
          _userImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile picture updated successfully!")),
        );
      } on FirebaseException catch (e) {
        // More specific error handling
        String errorMessage = "Failed to update profile picture.";
        if (e.code == 'unauthorized') {
          errorMessage =
              "You don't have permission to update the profile picture.";
        } else if (e.code == 'canceled') {
          errorMessage = "Profile picture update was canceled.";
        }
        print("Error updating profile picture: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBirthdate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _userBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Update the birthdate in Firestore
        await _firestore.collection('users').doc(_user!.uid).update({
          'birthdate': Timestamp.fromDate(pickedDate),
        });

        // Update the local state
        setState(() {
          _userBirthdate = pickedDate;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Birthdate updated successfully!")),
        );
      } catch (e) {
        print("Error updating birthdate: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update birthdate.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Combined update for address fields
  Future<void> _updateAddress({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? district,
    String? postalCode,
  }) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> updates = {};
    if (addressLine1 != null) updates['addressLine1'] = addressLine1;
    if (addressLine2 != null) updates['addressLine2'] = addressLine2;
    if (city != null) updates['city'] = city;
    if (district != null) updates['district'] = district;
    if (postalCode != null) updates['postalCode'] = postalCode;

    try {
      await _firestore.collection('users').doc(_user!.uid).update(updates);

      setState(() {
        _userAddressLine1 = addressLine1 ?? _userAddressLine1;
        _userAddressLine2 = addressLine2 ?? _userAddressLine2;
        _userCity = city ?? _userCity;
        _userDistrict = district ?? _userDistrict;
        _userPostalCode = postalCode ?? _userPostalCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address updated successfully!")),
      );
    } catch (e) {
      print("Error updating address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update address.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Combined update for contact fields
  Future<void> _updateContact(
      {String? privateContact, String? parentContact}) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> updates = {};
    if (privateContact != null) {
      if (privateContact.length == 10) {
        updates['privateContact'] = privateContact;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Private contact number must be 10 digits")),
        );
        return;
      }
    }
    if (parentContact != null) {
      if (parentContact.length == 10) {
        updates['parentContact'] = parentContact;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Parent contact number must be 10 digits")),
        );
        return;
      }
    }

    try {
      await _firestore.collection('users').doc(_user!.uid).update(updates);

      setState(() {
        _userPrivateContact = privateContact ?? _userPrivateContact;
        _userParentContact = parentContact ?? _userParentContact;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact updated successfully!")),
      );
    } catch (e) {
      print("Error updating contact: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update contact.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        // Update address (potentially multiple fields)
        await _updateAddress(
          addressLine1: _userAddressLine1,
          addressLine2: _userAddressLine2,
          city: _userCity,
          district: _userDistrict,
          postalCode: _userPostalCode,
        );

        // Update contacts (potentially both fields)
        await _updateContact(
          privateContact: _userPrivateContact,
          parentContact: _userParentContact,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to update profile. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Security"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  _buildAddressSection(),
                  const SizedBox(height: 20),
                  _buildContactSection(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: _updateProfilePicture, // Update picture on tap
      child: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _userImageUrl != null
                  ? NetworkImage(_userImageUrl!)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider<Object>,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildInfoField("Username", _userName, enabled: false),
        _buildInfoField("Email", _userEmail, enabled: false),
        _buildDateField("Birthdate", _userBirthdate, _updateBirthdate),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildAddressFields(),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildTextField(
          "Private Contact",
          _userPrivateContact,
          (val) => setState(() => _userPrivateContact = val),
          maxLength: 10,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        _buildTextField(
          "Parent Contact",
          _userParentContact,
          (val) => setState(() => _userParentContact = val),
          maxLength: 10,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String? value, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text('$label: ${value ?? ''}'),
          ),
          // Only show edit icon if enabled is true
          if (enabled) const Icon(Icons.edit, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label: ${value != null ? DateFormat('yyyy-MM-dd').format(value) : "Select Date"}',
              ),
            ),
            const Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String? value,
    Function(String) onSave, {
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text('$label: ${value ?? ''}'),
          ),
          GestureDetector(
            onTap: () {
              _showEditDialog(label, value, onSave,
                  maxLength: maxLength, keyboardType: keyboardType);
            },
            child: const Icon(Icons.edit, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    String label,
    String? currentValue,
    Function(String) onSave, {
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    String? updatedValue = currentValue;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextFormField(
            initialValue: currentValue,
            onChanged: (value) {
              updatedValue = value;
            },
            keyboardType: keyboardType,
            inputFormatters: maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (updatedValue != null) {
                  onSave(updatedValue!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        _buildTextField("Address Line 1", _userAddressLine1,
            (val) => setState(() => _userAddressLine1 = val)),
        _buildTextField("Address Line 2", _userAddressLine2,
            (val) => setState(() => _userAddressLine2 = val)),
        _buildTextField(
            "City", _userCity, (val) => setState(() => _userCity = val)),
        _buildTextField("District", _userDistrict,
            (val) => setState(() => _userDistrict = val)),
        _buildTextField("Postal Code", _userPostalCode,
            (val) => setState(() => _userPostalCode = val)),
      ],
    );
  }
}
