import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                  topRight: Radius.circular(8),
                ),
                child: Container(
                  color: const Color(0xFFADADAD),
                  child: CachedNetworkImage(
                    imageUrl: postInfos['imageUrl'] ?? "",
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) => Container(),
                    fit: BoxFit.cover,
                    width: 120,
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              postInfos['title'] ?? "",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
