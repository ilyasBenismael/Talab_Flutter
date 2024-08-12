import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentWidget extends StatelessWidget {
  final String commentData;
  final Map<String, dynamic> userData;

  const CommentWidget(
      {super.key, required this.commentData, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: userData['imageUrl'] ?? '',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.person),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(userData['name'] ?? 'Unknown User'),
        subtitle: Text(commentData),
      ),
    );
  }


}