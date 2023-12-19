import 'package:flutter/material.dart';

// App theme colors
const Color colorPrimary = Color(0xFF24B682);
const Color colorSecondary = Color(0xFF34D99E);

// Background colors
const Color bgLight = Colors.white;
const Color bgDark = Color(0xFF272727);

// Button colors
const Color buttonPrimary = Color(0xFF34D99E);
const Color buttonSecondary = Color(0xFF6C757D);
const Color buttonDisabled = Color(0xFFC4C4C4);

// Error and validation colors
const Color error = Color(0xFFD32F2F);
const Color success = Color(0xFF388E3C);
const Color warning = Color(0xFFF57C00);
const Color info = Color(0xFF1976D2);

// Neutral Shades
const Color black = Colors.black;
const Color darkerGrey = Color(0xFF4F4F4F);
const Color darkGrey = Color(0xFF939393);
const Color grey = Color(0xFFE0E0E0);
const Color softGrey = Color(0xFFF4F4F4);
const Color lightGrey = Color(0xFFF9F9F9);
const Color white = Colors.white;

// Color map for object detection classes
Map<String, Color> colorMap = {
  'battery': const Color.fromRGBO(0, 255, 255, 1),            // Cyan
  'paper': const Color.fromRGBO(0, 255, 0, 1),                // Bright Green
  'plastic bag': const Color.fromRGBO(255, 255, 0, 1),        // Yellow
  'can': const Color.fromRGBO(255, 153, 204, 1),              // Pink
  'glass bottle': const Color.fromRGBO(0, 100, 0, 1),         // Dark Green
  'pop tab': const Color.fromRGBO(255, 0, 0, 1),              // Red
  'plastic bottle': const Color.fromRGBO(0, 0, 255, 1),       // Blue
  'cardboard': const Color.fromRGBO(255, 165, 0, 1),          // Orange
  'plastic bottle cap': const Color.fromRGBO(255, 0, 255, 1), // Purple
  'drink carton': const Color.fromRGBO(0, 128, 128, 1),       // Teal
};