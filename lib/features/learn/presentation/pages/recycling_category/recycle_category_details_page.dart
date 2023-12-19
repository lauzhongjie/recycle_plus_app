import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/manage_resources/manage_recycling_items_page.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_item_cubit.dart';

class RecyclingCategoryDetailsPage extends StatefulWidget {
  final RCategoryEntity rCategory;

  const RecyclingCategoryDetailsPage({super.key, required this.rCategory});

  @override
  State<RecyclingCategoryDetailsPage> createState() =>
      _RecyclingCategoryDetailsPageState();
}

class _RecyclingCategoryDetailsPageState
    extends State<RecyclingCategoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<RCategoryItemCubit>()
        .getRCategoryItems(categoryId: widget.rCategory.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Category'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
          child: Column(
            children: [
              Image.network(widget.rCategory.imageUrl!),
              const SizedBox(height: 8),
              Text(
                widget.rCategory.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.category),
                title: Text('Items'),
              ),
              BlocBuilder<RCategoryItemCubit, RCategoryItemState>(
                builder: (context, state) {
                  if (state is RCategoryItemSuccess) {
                    // Sort the items in ascending order based on the item name.
                    final sortedItems = state.items
                      ..sort((a, b) => a.name!.compareTo(b.name!));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedItems.length,
                      itemBuilder: (context, index) {
                        final item = sortedItems[index];
                        return _buildListItem(
                          context,
                          item,
                        );
                      },
                    );
                  } else {
                    return const Text('No items found!');
                  }
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, RCategoryItemEntity item) {
    return Card(
      elevation: 0,
      color: white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ListTile(
        title: Text(item.name!),
        trailing: Icon(Icons.recycling,
            color: item.recyclability! ? Colors.green : Colors.red),
        onTap: () {
          Navigator.pushNamed(
            context,
            PageConst.recyclingItemDetailsPage,
            arguments: RecyclingItemDetailsArguments(
              item: item,
              rCategory: widget.rCategory,
            ),
          );
        },
      ),
    );
  }
}
