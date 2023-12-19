import 'package:flutter/material.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';

class RecyclingItemDetailsPage extends StatefulWidget {
  final RCategoryItemEntity item;
  final RCategoryEntity rCategory;

  const RecyclingItemDetailsPage({
    super.key,
    required this.item,
    required this.rCategory,
  });

  @override
  State<RecyclingItemDetailsPage> createState() =>
      _RecyclingItemDetailsPageState();
}

class _RecyclingItemDetailsPageState extends State<RecyclingItemDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Item'),
      ),
      body: ItemDetail(
        item: widget.item,
        cat: widget.rCategory,
      ),
    );
  }
}

class ItemDetail extends StatelessWidget {
  final RCategoryItemEntity item;
  final RCategoryEntity cat;

  const ItemDetail({
    Key? key,
    required this.item,
    required this.cat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(cat.imageUrl!),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item.recyclability! ? 'Recyclable' : 'Non-recyclable',
                    style: TextStyle(
                      fontSize: 18,
                      color: item.recyclability! ? colorPrimary : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Category'),
            Text(
              cat.name!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              item.recyclability! ? 'How to Recycle:' : 'How to Dispose:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            _buildHowToText(
                context, item.recyclingStepList!, item.recyclability!),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToText(
      BuildContext context, List<String> steps, bool isRecyclable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  steps[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
