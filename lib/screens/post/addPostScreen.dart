import 'package:ecommerce/services/UserService.dart';
import 'package:ecommerce/services/postService.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/services/utilities.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String locationMsg = "";
  String? _addingPostMsg;
  int role = 0;
  bool _isLoading = false;
  File? _pickedImage;
  List? userLocation;
  List<QueryDocumentSnapshot> categories = [];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    setCategories();
    setUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                        : Container(
                            color: Colors.grey,
                            width: 100,
                            height: 100,
                          ),
                  ),
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      // Use the camera_alt icon for image picking
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _keywordsController,
                decoration: InputDecoration(
                  labelText: 'Keywords',
                  hintText: 'put ur keywords separated with space',
                ),
                maxLength: 50, // Set the maximum length
                maxLines: 1, // Restrict to a single line
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Show 2 items per row
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final categoryId = category.id;
                    final categoryName = category.get('name');
                    final isSelected = selectedCategories.contains(categoryId);
                    return GestureDetector(
                      onTap: () {
                        toggleCategory(categoryId);
                      },
                      child: Container(
                        margin: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          categoryName,
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
              ),
              role == 0
                  ? Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                              'You are 1 step from becoming a chef so please fill these fields :',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(
                            height: 7,
                          ),
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
              const SizedBox(height: 16),
              Text(
                _addingPostMsg ?? "",
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: addPost,
                child: Text('Add Post'),
              ),
              SizedBox(height: 16),
              _isLoading ? CircularProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void toggleCategory(String categoryId) {
    setState(() {
      if (selectedCategories.contains(categoryId)) {
        selectedCategories.remove(categoryId);
      } else {
        selectedCategories.add(categoryId);
      }
    });
  }




  void addPost() async {
    // 1- loading true mean previous addpost is still running then there is nothing to do
    if (_isLoading) {
      return;
    }

    // 2- first loading is set to true so we cant execute addpost again
    setState(() {
      _isLoading = true;
      _addingPostMsg = "";
    });

    // 3- we get user infos
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();
    final keywords = _keywordsController.text.trim();
    Map<String, dynamic> postInfos = {
      'title': title,
      'price': price,
      'description': description,
      'imageFile': _pickedImage,
      'categories': selectedCategories,
      'keywords': keywords,
    };


    if (postInfos['title'].isEmpty ||
        postInfos['price'].isEmpty ||
        postInfos['description'].isEmpty ||
        postInfos['categories'].isEmpty ||
        postInfos['keywords'].isEmpty ||
        postInfos['imageFile'] == null) {
      setState(() {
        _isLoading = false;
        _addingPostMsg = "Please fill in all required fields and select an image";
      });
      return;
    }

    //()- we check if role == 0 then we see if fields are assigned then we updatethe user first
    if (role == 0) {
      if (_phoneController.text.isEmpty || userLocation == null) {
        _isLoading = false;
        _addingPostMsg = "Please fill in all required fields and select an image";
        setState(() {});
        return;
      }
      Map<String, dynamic> userInfos = {
        'phone': _phoneController.text,
        'note': 3.0,
        'role': 1,
        'location': userLocation
      };
      String? response1 = await UserService().makeUserChef(userInfos);
      if (response1 != "done") {
        _isLoading = false;
        _addingPostMsg = response1;
        setState(() {
        });
        return;
      }
    }

    //after all this we add the post to the database
    PostService.addPost(postInfos).then((result) {
      if (result == "done") {
        _addingPostMsg = result;
        _isLoading = false;
        setState(() {
        });
        Navigator.pop(context);
      } else {
        _isLoading = false;
        setState(() {
          _addingPostMsg = result;
        });
        return;
      }
    });
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



  //first thing we
  void setCategories() {
    FirebaseFirestore.instance
        .collection('categories')
        .get()
        .then((querySnapshot) {
      setState(() {
        categories = querySnapshot.docs;
      });
    });
  }



  void setUserRole() async {
    if (await UserService().getUserRole() == 1) {
      role = 1;
    }
    setState(() {});
  }






//the getLocation returns either error list [nbr] or list of lat and lon
  void getUserLocation() async {
    if (_isLoading || userLocation != null) {
      return;
    }
    _isLoading = true;
    setState(() {
      locationMsg = "";
    });

    List a = await UserService.getLocation();
    if (a[0] == -1) {
      _isLoading = true;
      setState(() {
        locationMsg = "u have to permit location access";
      });
      return;
    } else if (a[0] == -2) {
      _isLoading = false;
      setState(() {
        locationMsg = "error while getting user location";
      });
      return;
    } else {
      userLocation = a;
      _isLoading = false;
      setState(() {
        locationMsg = "lat: ${a[0]}, long: ${a[1]}";
      });
    }
  }




}
