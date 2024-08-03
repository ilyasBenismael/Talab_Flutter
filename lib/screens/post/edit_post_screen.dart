import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/services/postService.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/services/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  EditPostScreen({required this.postId});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  ///////////////////////////////////////////////////////////////////////////////
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  bool _isLoading = false;
  bool _isImgEdited = false;
  String? previousImgUrl;
  dynamic _pickedImage;
  List<QueryDocumentSnapshot> categories = [];
  List<dynamic> selectedCategories = [];
  Map<String, dynamic>? _postData;
  late Future<int> stateVar;

  ////////////////////////////////////////////// INIT STATE ///////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    setCategories();
    print('eeeee');
    stateVar = getPostData(widget.postId);
  }

  ///////////////////////////////////////////// DISPOSE //////////////////////////////////////////////////////////////////
  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  /////////////////////////////////////////////// BUILD ///////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Save Post'),
      ),
      body: FutureBuilder<int>(
          future: stateVar,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data == 1) {
              return SingleChildScrollView(
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
                                  ? Container(
                                      child: _isImgEdited
                                          ? Image.file(
                                              _pickedImage!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: _pickedImage!,
                                              placeholder: (context, url) =>
                                                  Container(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(),
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            ),
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
                                size: 30,
                                color: Colors.black,
                              ),
                            ),
                          ]),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _keywordsController,
                        decoration: const InputDecoration(
                          labelText: 'Keywords',
                          hintText: 'put ur keywords separated with space',
                        ),
                        maxLength: 50, // Set the maximum length
                        maxLines: 1, // Restrict to a single line
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final categoryId = category.id;
                            final categoryName = category.get('name');
                            final isSelected =
                                selectedCategories.contains(categoryId);
                            return GestureDetector(
                              onTap: () {
                                toggleCategory(categoryId);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.purple : Colors.grey,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: savePost,
                        child: const Text('Add Post'),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Container(),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text("error occured, try again"));
            }
          }),
    );
  }

///////////////////////////////////////////////// GET POST DATA ///////////////////////////////////////////////////////////////

  //this is the future int our futurebuilder use, before the methode complets aykun loading,
  //if no error o has data o data ==1 means all is good o postdata o selectedcategs are filled succesfully
  //else we will show an error
  Future<int> getPostData(String postId) async {
    try {
      //we get the post if any error we return -1
      _postData = await PostService.getPostById(postId);
      if (_postData == null) {
        return -1;
      }

      //if no error we fill the picked image and the selected categories and the controllers
      _pickedImage = _postData!['imageUrl'];
      previousImgUrl = _postData!['imageUrl'];
      selectedCategories = _postData!['categories'];

      _titleController.text = _postData!['title'] ?? '';
      _priceController.text = _postData!['price'] ?? '';
      _descriptionController.text = _postData!['description'] ?? '';
      _keywordsController.text = _postData!['keywords'] ?? '';

      return 1;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }

  ///////////////////////////////////////////// SET CATEGS /////////////////////////////////////////////////////////////

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
    } catch (e) {
      categories = [];
    }
  }

  ///////////////////////////////////////////// TOGGLE CATEGS ///////////////////////////////////////////////////////////////

  void toggleCategory(String categoryId) {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
    } else {
      selectedCategories.add(categoryId);
    }
    print(selectedCategories);
    setState(() {});
  }

  ////////////////////////////////////////////////// PICK THE IMAGE ////////////////////////////////////////////////////////////

  //first pickedimage is neither null(errorcase) or has a network value (depends on if the user has profil pic or not)
  //if the image is picked successfully the picked image will have a file value and imageedited is true now
  Future<void> _pickImage() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _pickedImage = await Utilities.pickImage();
    if (_pickedImage != null) {
      _isImgEdited = true;
    }
    _isLoading = false;
    setState(() {});
  }

////////////////////////////////////////// SAAAVE THE POST /////////////////////////////////////////////////////////////////////

  void savePost() async {
    // 1- loading true mean previous addpost is still running then there is nothing to do
    if (_isLoading) {
      return;
    }

    // 2- first loading is set to true so we cant execute addpost again
    _isLoading = true;
    setState(() {});

    // 3- we get post infos
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

    //after all this we add the post to the database
    PostService.updatePost(
            postInfos, _isImgEdited, widget.postId, previousImgUrl)
        .then((result) {
      if (!mounted) {
        return;
      }
      if (result == -1) {
        _isLoading = false;
        toastMsg("Please fill in all required fields and select an image");
        setState(() {});
      } else if (result == 1) {
        Navigator.pop(context);
      } else {
        _isLoading = false;
        toastMsg('error');
        setState(() {});
        return;
      }
    });
  }

/////////////////////////////////////////////////// TOAST /////////////////////////////////////////////////////////////////////////

  toastMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
