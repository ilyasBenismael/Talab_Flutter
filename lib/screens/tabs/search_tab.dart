import 'package:ecommerce/services/postService.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/screens/post/post_screen.dart';
import 'package:ecommerce/screens/post/post_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  SearchTabState createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> selectedTags = [];
  List<Map<String, dynamic>> allTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setAllTags();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 2), // Spacing
            const Divider(thickness: 1),
            const SizedBox(height: 1), // Spacing
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Selected:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 3), // Spacing
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: selectedTags.asMap().entries.map((entry) {
                        int index = entry.key;
                        var tag = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 3.0),
                          child: Chip(
                            label: Text(
                             tag['name'] ?? "",
                              style: const TextStyle(fontSize: 11),
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 11,
                            ),
                            onDeleted: () {
                              removeTag(index);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0), // Spacing
            const Divider(thickness: 1),
            SizedBox(
              height: 120, // Adjust as needed
              child: GridView.builder(
                gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100.0, // Max width for each item
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                  childAspectRatio: 1.5
                ),
                itemCount: allTags.length,
                itemBuilder: (context, index) {
                  return _buildTagItem(allTags[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////////////////// END OF BUILD /////////////////////////////////////////////////////////


  Widget _buildTagItem(Map<String, dynamic> tagData) {
    return GestureDetector(
      onTap: () {
        addTag(tagData);
      },
      child: Chip(
        label: Text(
          '#${tagData['name'] ?? ""} ',
          style: const TextStyle(fontSize: 11),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.blueAccent.withOpacity(0.2),
        // Optionally set the selected state
      ),
    );
  }


/////////////////////////////////////////////////// END OF WIDGET /////////////////////////////////////////////////////////








/////////////////////////////////////////////// SET TAGS //////////////////////////////////////////////////////////////

  void setAllTags() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    allTags = await PostService.getAllTags();

    if (allTags == []) {
      print("error fetching tags");
    }
    _isLoading = false;

    if(mounted){
      setState(() {});
    }
  }






  /////////////////////////////////////////////// GO TO POST ////////////////////////////////////////////////////////////////

  void goToPost(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: id)),
    );
  }



  /////////////////////////////////////////////// SELECT TAG //////////////////////////////////////////////////////////////


  void addTag(tagData) {
    selectedTags.add(tagData);
    setState(() {});
  }

  void removeTag(int index) {
    selectedTags.removeAt(index);
    setState(() {});
  }


}







//we get tags(u get all of them and put them in a list of maps) and show their name as circle texts in 3 per column
//in a horizontal list

//on select kitl3o li fihum and u can select many (if none is selected makitl3 walo)
//selected tags always kidaru fmo9dima

//ontextchanged fsearch bar : kanchufu akhir string mn b3d fasila or ila kan flbdya o ykun fog 2 chars,
//we find tags containing that string o ndiruhum fmo9dima
//
