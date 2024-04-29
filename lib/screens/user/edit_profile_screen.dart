//first thing we set fields with old user data
//the user can pick img and date and change location fill fields
//then we can update the user

import 'package:ecommerce/services/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/services/UserService.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List? location;
  DateTime? _selectedDate;
  bool _isImgEdited = false;
  dynamic _pickedImage;
  bool _isLoading = false;
  String? selectedCity;
  String _errorMsg = '';
  String? previousImgUrl;
  String locationMsg = '';
  bool isChef = false;

  @override
  void initState() {
    super.initState();
    setFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: _pickedImage != null
                          ? Container(
                              child: _isImgEdited
                                  ? Image.file(
                                      _pickedImage!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      _pickedImage!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : Image.asset(
                              'images/profileX.jpeg',
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
                SizedBox(height: 7),
                isChef
                    ? Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Enter phone number',
                              ),
                            ),
                            TextField(
                              onTap: () {
                                getUserLocation();
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: locationMsg,
                                prefixIcon: const Icon(Icons.map),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateUser,
                  child: const Text('Update User'),
                ),
                const SizedBox(height: 16),
                _isLoading ? const CircularProgressIndicator() : Container(),
                Text(_errorMsg),
              ],
            ),
          ),
        ));
  }





  void updateUser() {
    //if it's still loading from previous update we return
    if (_isLoading) {
      return;}

    //first thing we make the ui of a loading page
    _errorMsg = '';
    _isLoading = true;
    setState(() {});

    //we get userinfos from controllers and put chef fields to null cuz we might need it in the update methode if the user is not a chef
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final description = _descriptionController.text.trim();
    Map<String, dynamic> userInfo = {
      'name': name,
      'city': city,
      'description': description,
      'imageFile': _pickedImage,
      'birthDay': _selectedDate,
      'phone': null,
      'location': null
    };

    //we check if the infos are not empty (if they are then we show the errorMsg and return)
    if (userInfo['name'].isEmpty ||
        userInfo['city'].isEmpty ||
        userInfo['birthDay'] == null) {
      _errorMsg = 'fill all fields';
      _isLoading = false;
      setState(() {});
      return;
    }

    //if it's a chef we update chef fields and check their emptiness
     if (isChef) {
      userInfo['location'] = location;
      userInfo['phone'] = _phoneController.text.trim();

      if (userInfo['phone'].isEmpty || location == null) {
        _errorMsg = 'fill all fields';
        _isLoading = false;
        setState(() {});
        return;
      }
    }

    //we update the user, if there is an error we show it and return, if it's okey we go to previous page
    UserService
        .updateUser(userInfo, _isImgEdited, previousImgUrl)
        .then((result) {
      _isLoading = false;
      if (result == "done") {
        Navigator.pop(context);
      } else {
        _errorMsg = result.toString();
      }
      setState(() {});
    });
  }



  //pickedimage takes wether null or the file ref
  //if it's not null the imgedited is set to true
  Future<void> _pickImage() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    setState(() {});
    _pickedImage = await Utilities.pickImage();
    if (_pickedImage != null) {
      _isImgEdited = true;
    }
    _isLoading = false;
    setState(() {});
  }




  //when clicking the choose_date we make the show_date_picker object and the initial date will be the now date if no date is selected
  //if a new date is picked we update the ui with the new picked date
  //the selected_date is of type date but we show it as a string
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




  void setFields() {
//to prevent the ui imperfection
    _nameController.text = '_';
    _cityController.text = '_';
    _descriptionController.text = '_';
    _dateController.text = '_';

//we get the user , this run asynch
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
//after we get user we initiate the textfieldControllers and rebuild
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? '';
        _cityController.text = userData['city'] ?? '';
        _descriptionController.text = userData['description'] ?? '';
        _selectedDate = userData['birthDay'].toDate();
        _dateController.text = _selectedDate.toString().substring(0, 10);
        _pickedImage = userData['imageUrl'];
        previousImgUrl = userData['imageUrl'];

        if (userData['role'] == 1) {
          isChef = true;
          location = userData['location'] ?? '';
          locationMsg = "lat: ${location?[0]}, long: ${location?[1]}";
          _phoneController.text = userData['phone'] ?? '';
        }
      }
      setState(() {});
    });
  }




  void getUserLocation() async {
    //if a previous updtae or getLocation are still running we leave
    if (_isLoading) {
      return;
    }

    //we make the loading ui
    _isLoading = true;
    locationMsg = "";
    setState(() {});

    //we get the location msg which either a denial, an error or the location
    //we show the corresponding msg and leave
    //if it's a location we set the location list and leave
    List a = await UserService.getLocation();
    if (a[0] == -1) {
      _isLoading = true;
      locationMsg = "u have to permit location access";
      setState(() {});
      return;
    } else if (a[0] == -2) {
      _isLoading = false;
      locationMsg = "error while getting user location";
      setState(() {});
      return;
    } else {
      location = a;
      _isLoading = false;
      locationMsg = "lat: ${a[0]}, long: ${a[1]}";
      setState(() {});
    }
  }
}
