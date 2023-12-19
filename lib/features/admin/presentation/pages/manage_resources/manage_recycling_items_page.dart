import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/features/admin/presentation/widgets/add_or_edit_recycling_category_item_dialog.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_item_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ManageRecyclingItemsPage extends StatefulWidget {
  final RCategoryEntity rCategory;

  const ManageRecyclingItemsPage({
    super.key,
    required this.rCategory,
  });

  @override
  State<ManageRecyclingItemsPage> createState() =>
      _ManageRecyclingItemsPageState();
}

class _ManageRecyclingItemsPageState extends State<ManageRecyclingItemsPage> {
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
        backgroundColor: colorSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: colorSecondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Text(
                'Manage\nRecycling Items',
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildOverlayContainer(context),
            _buildMainContentSection(context),
            const SizedBox(height: 60.0),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<RCategoryItemCubit, RCategoryItemState>(
        builder: (context, state) {
          if (state is RCategoryItemSuccess) {
            return FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddOrEditRecyclingCategoryItemDialog(
                    rCategory: widget.rCategory,
                    rCategoryItems: state.items,
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildMainContentSection(BuildContext context) {
    return BlocBuilder<RCategoryItemCubit, RCategoryItemState>(
      builder: (context, state) {
        if (state is RCategoryItemSuccess) {
          var sortedItems = List<RCategoryItemEntity>.from(state.items)
            ..sort((a, b) => a.name!.compareTo(b.name!));

          return Column(
            children: sortedItems.map((item) {
              // Check if the item is in object detection classes
              // If yes, do not allow editing the name or deletion
              bool isInObjectDetection =
                  colorMap.containsKey(item.name!.toLowerCase());

              return GestureDetector(
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
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 14.0,
                      bottom: 14.0,
                      left: 8.0,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.category),
                      title: Text(
                        item.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item.recyclability! ? 'Recyclable' : 'Non-Recyclable',
                        style: TextStyle(
                          color:
                              item.recyclability! ? colorPrimary : Colors.red,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit action
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AddOrEditRecyclingCategoryItemDialog(
                                  rCategory: widget.rCategory,
                                  item: item,
                                  isInObjectDetection: isInObjectDetection,
                                  rCategoryItems: sortedItems,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: isInObjectDetection
                                ? ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                    child: SvgPicture.asset(
                                      ImageConst.binDisable,
                                      height: 20.0,
                                    ),
                                  )
                                : const Icon(Icons.delete),
                            onPressed: () {
                              if (isInObjectDetection) {
                                _disabledDeleteDialog(context, item);
                              } else {
                                _confirmDeleteDialog(context, item);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        } else if (state is RCategoryItemLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Failed to load items'));
        }
      },
    );
  }

  Widget _buildOverlayContainer(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Container(
        height: 120,
        width: MediaQuery.sizeOf(context).width * 0.8,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: BlocBuilder<RCategoryItemCubit, RCategoryItemState>(
          builder: (context, state) {
            if (state is RCategoryItemSuccess) {
              return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        widget.rCategory.imageUrl!,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        state.items.length.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          color: colorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${widget.rCategory.name!}\nItems",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is RCategoryItemLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Failed to load items'));
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDialog(
      BuildContext context, RCategoryItemEntity item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete "${item.name}" Item'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: const <TextSpan>[
                TextSpan(
                    text:
                        'Are you sure you want to delete this item forever?\n'),
                TextSpan(
                  text: 'Warning! This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                BlocProvider.of<RCategoryItemCubit>(context)
                    .removeRCategoryItem(
                  widget.rCategory.id!,
                  item.id!,
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _disabledDeleteDialog(
      BuildContext context, RCategoryItemEntity item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete "${item.name}" Item'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: const <TextSpan>[
                TextSpan(
                  text: 'This item cannot be deleted.\n',
                ),
                TextSpan(
                  text: 'Please contact the developer for further support.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class RecyclingItemDetailsArguments {
  final RCategoryItemEntity item;
  final RCategoryEntity rCategory;

  RecyclingItemDetailsArguments({required this.item, required this.rCategory});
}
