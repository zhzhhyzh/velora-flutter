import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class RegisterDesigner extends StatefulWidget {
  final DocumentSnapshot? designerData;

  const RegisterDesigner({
    Key? key,
    this.designerData
  }) : super(key: key)
;

  @override
  State<RegisterDesigner> createState() => _RegisterDesignerState();
}

class _RegisterDesignerState extends State<RegisterDesigner> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
