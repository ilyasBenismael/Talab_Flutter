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
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
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


  //if still loading ma andiru walo, sinon ansettiwha l loading o nrebuildiw lpage o nsaviw luser
  //then anchufu result o ansetiw lerror msg o ndiru
  void registerUser() {
    if (_isLoading) {
      return;
    }
    _errorMsg = '';
    _isLoading = true;
    setState(() {});
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

    //all this bloc is exec asynch, if error we show it, if all good we popout
    UserService().registerUser(userInfo).then((result) {
      if (!mounted) {
        return;
      }
      _isLoading = false;
      if (result == -1) {
        toastMsg('fill all fields');
      } else if (result == 1) {
        Navigator.pop(context);
      } else {
        toastMsg('unexpected error happened');
      }
        setState(() {});
    });
  }



  void goToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }



  //we can do nothing while picking image (isloading is true)
  //check if mounted before each setstate to avoid errors
  Future<void> _pickImage() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;

    //the pickedimage will be  either null or contains the image
    _pickedImage = await Utilities.pickImage();

    if(_pickedImage == null){
      toastMsg("error while picking image");
    }
      _isLoading = false;

    setState(() {});
  }



  //we cant pick when it's loading, and if there is an error in picking we show it to user
  Future<void> _selectDate(BuildContext context) async {
    if (_isLoading) {
      return;
    }
    try {
      //when clicking the choose_date we make the show_date_picker object and the initial date will be the now date if no date is selected
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      //if a new date is picked we update the ui with the new picked date
      //the selected_date is of type date but we show it as a string
      if (pickedDate != null && pickedDate != _selectedDate && mounted) {
        setState(() {
          _selectedDate = pickedDate;
          _dateController.text = _selectedDate!
              .toString()
              .substring(0, 10); // Update text field value
        });
      }
    } catch (e) {
      print('cant pick date: ' + e.toString());
    }
  }



  toastMsg(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg)));
  }











}
