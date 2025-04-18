import 'package:flutter/material.dart';

class TheAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String content;
  final int style;

  const TheAppBar({
    Key? key,
    required this.content,
    this.style = 1, // Default to style 1
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        content,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: style == 2 ? const Color(0xFF689f77) : Colors.black,
        ),
      ),
      centerTitle: style != 1 ? true : false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
