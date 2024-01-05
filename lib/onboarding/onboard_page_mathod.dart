import 'package:flutter/material.dart';

Widget buildPage({
  required BuildContext context,
  required Color color,
  required String urlImage,
  required String title,
  required String subtitle,
}) {
  final size = MediaQuery.of(context).size;

  return Container(
    color: color,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(50),
          child: Image.asset(
            urlImage,
            fit: BoxFit.scaleDown,
            width: double.infinity,
          ),
        ),
        SizedBox(
          height: size.height * 0.02,
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.teal.shade700,
            fontSize: size.height * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    ),
  );
}
