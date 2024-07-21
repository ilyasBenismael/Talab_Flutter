import 'package:ecommerce/screens/user/my_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../options/settings_screen.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with AutomaticKeepAliveClientMixin {
  List<String> items = List.generate(30, (index) => 'Item $index');

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Screen'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                // Display 3 items in a row
                return Row(
                  children: [
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(items[index]),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    if ((index + 1) % 3 == 0) SizedBox(width: 8.0),
                    // Add spacing after every 3 items
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
