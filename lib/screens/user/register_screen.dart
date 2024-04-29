import 'package:ecommerce/services/Utilities.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ecommerce/screens/options/settings_screen.dart';
import 'package:ecommerce/services/UserService.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  File? _pickedImage = null;
  bool _isLoading = false;
  String? selectedCity;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      goToSettings(context);
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/profileX.jpeg',
                            // Path to your anonymous profile image asset
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'description(optional)'),
              ),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerUser,
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              _isLoading ? const CircularProgressIndicator() : Container(),
              Text(_errorMsg)
            ],
          ),
        ),
      ),
    );
  }



  void registerUser() {
    if (_isLoading) {
      return;
    }
    setState(() {
      _errorMsg = '';
      _isLoading = true;
    });
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final description = _descriptionController.text.trim();

    Map<String, dynamic> userInfo = {
      'name': name,
      'city': city,
      'description': description,
      'imageFile': _pickedImage,
      'birthDay': _selectedDate
    };

    UserService().registerUser(userInfo).then((result) {
      if (result == "done") {
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMsg = result.toString();
        });
      }
      _isLoading = false;
      setState(() {});
    });
  }

  void goToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  Future<void> _pickImage() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _pickedImage = await Utilities.pickImage();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _selectedDate!
            .toString()
            .substring(0, 10); // Update text field value
      });
    }
  }
}
