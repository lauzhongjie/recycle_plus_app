import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/features/admin/presentation/widgets/add_or_edit_recycling_category_dialog.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';

class ManageRecyclingCategoriesPage extends StatefulWidget {
  const ManageRecyclingCategoriesPage({super.key});

  @override
  State<ManageRecyclingCategoriesPage> createState() =>
      _ManageRecyclingCategoriesPageState();
}

class _ManageRecyclingCategoriesPageState
    extends State<ManageRecyclingCategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RCategoryCubit>().getRCategories();
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
                'Manage\nRecycling Categories',
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildOverlayContainer(context),
            _buildMainContentSection(),
            const SizedBox(height: 60.0),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<RCategoryCubit, RCategoryState>(
        builder: (context, state) {
          if (state is RCategoryStateSuccess) {
            return FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddOrEditRecyclingCategoryDialog(
                    allCategories: state.categories,
                  ),
                );
              },
              child: const Icon(
                Icons.add,
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildMainContentSection() {
    return BlocBuilder<RCategoryCubit, RCategoryState>(
      builder: (context, state) {
        if (state is RCategoryStateSuccess) {
          var sortedCategories = List<RCategoryEntity>.from(state.categories)
            ..sort((a, b) => a.name!.compareTo(b.name!));

          return Column(
            children: sortedCategories.map((category) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    PageConst.manageRecyclingItemsPage,
                    arguments: category,
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
                      leading: category.imageUrl != null
                          ? Image.network(
                              category.imageUrl!,
                              width: 50,
                              height: 50,
                            )
                          : const Icon(
                              Icons.category,
                              size: 30,
                            ),
                      title: Text(
                        category.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${category.itemList?.length ?? 0} items'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AddOrEditRecyclingCategoryDialog(
                                  allCategories: sortedCategories,
                                  rCategory: category,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              if (category.itemList == null ||
                                  category.itemList!.isEmpty) {
                                _confirmDeleteDialog(context, category);
                              } else {
                                _disableDeleteDialog(context, category);
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
        } else if (state is RCategoryStateLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Container();
        }
      },
    );
  }

  Transform _buildOverlayContainer(BuildContext context) {
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
        child: BlocBuilder<RCategoryCubit, RCategoryState>(
          builder: (context, state) {
            if (state is RCategoryStateSuccess) {
              return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        ImageConst.threeRecycleBinIcon,
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        state.categories.length.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          color: colorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Recycling\nCategories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is RCategoryStateLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDialog(
      BuildContext context, RCategoryEntity category) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete "${category.name}" Category'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: const <TextSpan>[
                TextSpan(
                    text: 'Are you sure you want to delete this category?\n'),
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
                BlocProvider.of<RCategoryCubit>(context)
                    .removeRCategory(category.id!);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted successfully'),
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

  Future<void> _disableDeleteDialog(
      BuildContext context, RCategoryEntity category) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete "${category.name}" Category'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: const <TextSpan>[
                TextSpan(text: 'This category cannot be deleted.\n'),
                TextSpan(
                  text:
                      'Please delete all the items before deleting the category.',
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
          ],
        );
      },
    );
  }

  void refreshCategories() {
    context.read<RCategoryCubit>().getRCategories();
  }
}
