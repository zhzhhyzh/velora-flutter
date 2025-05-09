import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../designer_detail.dart';
import 'package:path/path.dart';

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
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    final List workImgs = data['workImgs'] is List
        ? data['workImgs']  // if is Array in firestore, it assign as List
        : (data['workImgs'] is String && data['workImgs'].isNotEmpty)
        ? [data['workImgs']] // if is String in firestore, make it as List
        : []; // empty List

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: () {
          if (doc != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DesignerDetailScreen(designer: doc!)),
            );
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
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(3, 1),
              ),
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(-3, 0),
              )
            ]
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4,),
                        Text(
                          'From \$${data['rate']}/ project',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 25,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            color: Colors.green.shade100,
                            child: Center(
                              child: Text(
                                data['category'] ?? 'Designer Category',
                                style:TextStyle(fontSize: 11,color: Colors.black, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4,),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4,),
                            Expanded(child:
                              Text(
                                location,
                                style: TextStyle(fontSize: 12, color: Colors.black),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12,),
              if (workImgs.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workImgs.length,
                    itemBuilder: (context, index){
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: _safeDecodeImage(workImgs[index]),
                                fit: BoxFit.cover
                            )
                        ),
                      );
                    },
                  ),
                )
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