import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Widgets/the_app_bar.dart';
import 'Widgets/designer_card.dart';

class DesignerDetailScreen extends StatefulWidget {
  final DocumentSnapshot designer;

  const DesignerDetailScreen({
    super.key,
    required this.designer
});

  @override
  State<DesignerDetailScreen> createState() => _DesginerDetailScreenState();
}

class _DesginerDetailScreenState extends State<DesignerDetailScreen> {
  late Map<String, dynamic> data;

  @override
  void initState(){
    super.initState();
    fixDesignerDocs();
    data = widget.designer.data() as Map<String, dynamic>;

    // 👇 Debug: Print all document fields
    print("DESIGNER DATA: ${widget.designer.data()}");
    print('About: ${data['about']}');
    print('Slogan: ${data['slogan']}');
  }
  void fixDesignerDocs() async {
    final snapshot = await FirebaseFirestore.instance.collection('designers').get();
    for (var doc in snapshot.docs) {
      await doc.reference.set({
        'about': doc.data().containsKey('about') ? doc['about'] : 'No information provided.',
        'slogan': doc.data().containsKey('slogan') ? doc['slogan'] : '',
      }, SetOptions(merge: true));
    }
    print('Designer documents patched.');
  }

  @override
  Widget build(BuildContext context) {
    final location = [
      data['country']?.toString(),
      data['state']?.toString()
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    final List portfolioImgs = data['portfolioImg'] is List
        ? data['portfolioImg']  // if is Array in firestore, it assign as List
        : (data['portfolioImg'] is String && data['portfolioImg'].isNotEmpty)
        ? [data['portfolioImg']] // if is String in firestore, make it as List
        : []; // empty List


    return Scaffold(
      appBar: TheAppBar(
        content: data['name'] ?? 'Designer Name',
        style: 2,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                backgroundImage: MemoryImage(base64Decode(data['profileImg'])),
                radius: 50,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Designer Name',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,height: 1.25),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          color: Colors.green.shade100,
                          child: Center(
                            child: Text(
                              data['category'] ?? 'Designer Category',
                              style:TextStyle(fontSize: 13,color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
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
              ]
            ),
            const SizedBox(height: 8),
            if ((data['slogan'] ?? '').toString().trim().isNotEmpty)
              Text(data['slogan'], style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'About: ',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green)
                    ),
                    TextSpan(
                      text: (data['about'] ?? '').toString().trim().isNotEmpty
                          ? data['about']
                          : 'No information provided.',
                    )
                  ]
                )
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const Text('Portfolio:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (portfolioImgs.isNotEmpty)
              Padding(
                  padding: EdgeInsets.all(12),
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: portfolioImgs.length ,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8
                    ),
                    itemBuilder: (context,index) {
                      final img = portfolioImgs[index];
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(base64Decode(img),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                          )
                      );
                    }
                  )
                )
            else
              const Center(child: Text('No portfolio images available'))
          ],
        )
      )
    );
  }
}
