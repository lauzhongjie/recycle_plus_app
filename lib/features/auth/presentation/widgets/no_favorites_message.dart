import 'package:flutter/material.dart';

import 'package:recycle_plus_app/core/constants/colors.dart';

class NoFavoriteMessageHomeWidget extends StatelessWidget {
  final String msg;

  const NoFavoriteMessageHomeWidget({
    super.key,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: darkerGrey),
        ),
      ),
    );
  }
}
