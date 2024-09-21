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
    //these methods are both async so we build first with role and empty categ
    //and then setstate is callled with new data
    setCategories();
    setUserRole();
  }


  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Add Post'),
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
                          const Text(
                              'You are 1 step from becoming a chef so please fill these fields :',
                              style:  TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(
                            height: 7,
                          ),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
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
    if(_isLoading){
      return;
    }
      if (selectedCategories.contains(categoryId)) {
        selectedCategories.remove(categoryId);
      } else {
        selectedCategories.add(categoryId);
      }
      setState(() {});
  }













  void addPost() async {
    // 1- loading true mean previous addpost is still running then there is nothing to do
    if (_isLoading) {
      return;
    }

    // 2- first loading is set to true so we cant execute addpost again
    _isLoading = true;
    _addingPostMsg = "";
    setState(() {});

    // 3- we get user infos
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();
    Map<String, dynamic> postInfos = {
      'title': title,
      'price': price,
      'description': description,
      'imageFile': _pickedImage,
      'categories': selectedCategories,
    };

    if (postInfos['title'].isEmpty ||
        postInfos['price'].isEmpty ||
        postInfos['description'].isEmpty ||
        postInfos['categories'].isEmpty ||
        postInfos['imageFile'] == null) {
      _isLoading = false;
      toastMsg("Please fill in all required fields and select an image");
      setState(() {});
      return;
    }

    //()- we check if role == 0 then we see if fields are assigned then we update the user first
    if (role == 0) {
      if (_phoneController.text.isEmpty || userLocation == null) {
        _isLoading = false;
        toastMsg("Please fill in all required fields and select an image");
        setState(() {});
        return;
      }
      Map<String, dynamic> userInfos = {
        'phone': _phoneController.text,
        'note': 0.0,
        'role': 1,
        'location': userLocation
      };
      int response1 = await UserService().makeUserChef(userInfos);

      if(!mounted){
        return;
      }

      //if user not updated we leave
      if (response1 != 1) {
        _isLoading = false;
        _addingPostMsg = "error while saving";
        setState(() {});
        return;
      }
    }

    //after all this we add the post to the database
    PostService.addPost(postInfos).then((result) {
      if(!mounted){return;}
      if (result == 1) {
        Navigator.pop(context);
      } else {
        _isLoading = false;
        setState(() {
          _addingPostMsg = "error while saving";
        });
        return;
      }
    });
  }





  Future<void> _pickImage() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _pickedImage = await Utilities.pickImage();
    if(_pickedImage == null) {
      toastMsg("error while picking image");
    }
    _isLoading = false;
    if(!mounted){return;}
    setState(() {});
  }




  void setCategories() {
    try {
      FirebaseFirestore.instance
          .collection('categories')
          .get()
          .then((querySnapshot) {
        if (!mounted) {
          return;
        }
        categories = querySnapshot.docs;
        setState(() {});
      });
    }catch(e){
      categories= [];
    }
  }






  //if role != 1 or error it will remain 0
  void setUserRole() async {
    if (await UserService().getUserRole() == 1) {
      role = 1;
    }
    if (!mounted) {
      return;
    }
    setState(() {});
  }






  toastMsg(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg)));
  }



  void getUserLocation() async {
    //if we already got location no need to get it again
    if (_isLoading || userLocation != null) {
      return;
    }
    _isLoading = true;
    locationMsg = "";

    //if -1 or -2 we show error msg, else we set userlocation and set locationmsg
    List a = await UserService.getLocation();
    if(!mounted){return;}
    if (a[0] == -1) {
      _isLoading = false;
      toastMsg("u have to permit location access");
    } else if (a[0] == -2) {
      _isLoading = false;
      toastMsg("error while getting user location");
    } else {
      userLocation = a;
      _isLoading = false;
      locationMsg = "lat: ${a[0]}, long: ${a[1]}";
    }
    setState(() {});
  }
}
