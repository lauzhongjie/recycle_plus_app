import 'package:flutter/material.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';

Widget buildLoginToViewOverlay(VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: black.withOpacity(0.05),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Please login to view',
        style: TextStyle(color: darkGrey),
      ),
    ),
  );
}
