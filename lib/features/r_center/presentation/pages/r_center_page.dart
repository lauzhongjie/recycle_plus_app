import 'package:flutter/material.dart';
import 'package:recycle_plus_app/features/r_center/presentation/pages/r_center_map_view.dart';

class RecyclingCenterPage extends StatelessWidget {
  const RecyclingCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Centers Nearby'),
      ),
      body: const MapView(),
    );
  }
}
