import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DesignerCard extends StatelessWidget {
  final Map<String,dynamic> data;
  final DocumentSnapshot? doc;

  const DesignerCard({
    Key? key,
    required this.data,
    this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = [
      data['country']?.toString(),
      data['state']?.toString()
    ].where((e) => e != null && e.trim().isNotEmpty).join(',');

    final List portfolioImgs = data['portfolioImg'] is List
        ? data['portfolioImg']  // if is Array in firestore, it assign as List
        : (data['portfolioImg'] is String && data['portfolioImg'].isNotEmpty)
        ? [data['portfolioImg']] // if is String in firestore, make it as List
        : []; // empty List

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: () {
          if (doc != null) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => DesignerDetailScreen(designer: doc!)),
            // );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("This designer is not available now."))
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: _safeDecodeImage(data['profileImg']),
                    radius: 28,
                  ),
                  const SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'Designer Name',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4,),
                        Row(
                          children: [
                            Text(
                              'From \$${data['fee']}/ project',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 25,),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4,),
                          Text(location, style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12,),
              if (portfolioImgs.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: portfolioImgs.length,
                    itemBuilder: (context, index){
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: _safeDecodeImage(portfolioImgs[index]),
                                fit: BoxFit.cover
                            )
                        ),
                      );
                    },
                  ),
                )
              else
                const Text('No portfolio images available'),
            ],
          ),

        ),
      ),
    );
  }

  ImageProvider _safeDecodeImage(dynamic base64String) {
    try {
      if (base64String is String && base64String.isNotEmpty) {
        return MemoryImage(base64Decode(base64String));
      }
    } catch (e) {
      debugPrint('Image decode failed: $e');
    }
    return const AssetImage('assets/images/default.png');
  }

}