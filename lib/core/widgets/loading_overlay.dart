import 'package:flutter/material.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';

Widget buildLoadingOverlay() {
  return Stack(
    children: [
      const Opacity(
        opacity: 0.3,
        child: ModalBarrier(dismissible: false, color: Colors.black),
      ),
      Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please wait...',
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
