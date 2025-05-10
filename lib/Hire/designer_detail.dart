  import 'dart:convert';

  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
import 'package:velora2/Hire/edit_desinger_form.dart';
import 'package:velora2/Hire/offer_designer.dart';
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
    final user = FirebaseAuth.instance.currentUser;


    @override
    void initState(){
      super.initState();
      data = widget.designer.data() as Map<String, dynamic>;

    }


    @override
    Widget build(BuildContext context) {
      final isOwner = user?.email == data['email'];

      final location = [
        data['country']?.toString(),
        data['state']?.toString()
      ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

      final List workImgs = data['workImgs'] is List
          ? data['workImgs']  // if is Array in firestore, it assign as List
          : (data['workImgs'] is String && data['workImgs'].isNotEmpty)
          ? [data['workImgs']] // if is String in firestore, make it as List
          : []; // empty List

      ImageProvider profileImgProvider;
      if (data['profileImg'] != null && (data['profileImg'] as String).trim().isNotEmpty) {
        try {
          profileImgProvider = MemoryImage(base64Decode(data['profileImg']));
        } catch (_) {
          profileImgProvider = const AssetImage('assets/images/default.png');
        }
      } else {
        profileImgProvider = const AssetImage('assets/images/default.png');
      }

      return Scaffold(
        appBar: TheAppBar(
          content: data['name'] ?? 'Designer Name',
          style: 2,
        ),
        backgroundColor: Colors.white,
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child:
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                      backgroundImage: profileImgProvider,
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
                    Text(
                      data['slogan'],
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'About: ',
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
                          ),
                          TextSpan(
                            text: (data['desc'] ?? '').toString().trim().isNotEmpty
                                ? data['desc']
                                : 'No information provided.',
                            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)
                          )
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1),
                  if (workImgs.isNotEmpty)
                    const Text('Work:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Padding(
                        padding: EdgeInsets.all(12),
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: workImgs.length ,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8
                          ),
                          itemBuilder: (context,index) {
                            final img = workImgs[index];
                            if (img is! String || img.isEmpty) {
                              return const Icon(Icons.broken_image, size: 40);
                            }
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
                ],
              )
            ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: EdgeInsets.only(left: 20,right: 20, top: 5,bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Contact No.: ',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
                              ),
                              TextSpan(
                                  text: (data['contact'] ?? '').toString().trim().isNotEmpty
                                      ? data['contact']
                                      : null,
                                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)
                              )
                            ]
                        ),
                      ),
                      RichText(
                        maxLines: 2,
                        text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Email: ',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
                              ),
                              TextSpan(
                                  text: (data['email'] ?? '').toString().trim().isNotEmpty
                                      ? data['email']
                                      : null,
                                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),

                              )
                            ]
                        ),
                      ),
                    ],
                  ),
                  isOwner
                      ? MaterialButton(
                      onPressed: () => checkAndNavigateToDesignerForm(context),
                      color: const Color(0xff689f77),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            Text('Edit', style: TextStyle(color: Colors.white, fontSize: 25))
                          ],
                        ),
                      )
                  )
                      :MaterialButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OfferDesignerScreen(designer: widget.designer),
                        ),
                      ),
                      color: const Color(0xff689f77),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.work, color: Colors.white),
                            Text('Hire', style: TextStyle(color: Colors.white, fontSize: 25))
                          ],
                        ),
                      )
                  )
                ]
              )
            )
          ],
        ),
      );
    }


    Future<void> checkAndNavigateToDesignerForm(BuildContext context) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final designersRef = FirebaseFirestore.instance.collection('designers');
      final query = await designersRef.where('email', isEqualTo: user.email).limit(1).get();
      final designerDoc = query.docs.isNotEmpty ? query.docs.first : null;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterOrEditDesigner(designerData: designerDoc),
        ),
      );
    }
  }
