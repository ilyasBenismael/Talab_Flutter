import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final Map<String, dynamic> postInfos;

  PostWidget({required this.postInfos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius:
            BorderRadius.circular(8), // Apply border radius to the container
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                // Apply top-left border radius to the image
                topRight: Radius.circular(8), // Apply top-right border radius to the image
              ),
              child: postInfos['imageUrl'] != null
                  ? Container(
                      child: Container(
                        color: const Color(0xFF212121),
                        child: Image.network(
                          postInfos['imageUrl'] ?? "",
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container()  ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              child: Text(
                postInfos['title'] ?? "",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
