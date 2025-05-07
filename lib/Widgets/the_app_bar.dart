import 'package:flutter/material.dart';
import 'package:velora2/InfoScreen/info_screen.dart';

class TheAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String content;
  final int style;

  const TheAppBar({Key? key, required this.content, this.style = 1})
    : super(key: key);

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
          color: style == 2 ? const Color(0xffffffff) : Colors.black,
        ),
      ),
      centerTitle: style != 1,
      leading:
          style == 2 && Navigator.canPop(context)
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
              : null,
      actions: [
        if (style == 1)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {
                  // TODO: Navigate to notifications screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications tapped')),
                  );
                },
              ),
              // Optional: red dot indicator
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          )
        else if (style == 2 && content != 'About Velora')
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InfoScreen()),
              );
            },
          ),
      ],

      flexibleSpace: Container(
        decoration:   style == 2 ? const BoxDecoration(color: Color(0xff689f77)): const BoxDecoration(color: Color(0xffffffff)),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
