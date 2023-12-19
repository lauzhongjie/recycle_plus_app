import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';

class RecyclingCategorySelectionPage extends StatefulWidget {
  const RecyclingCategorySelectionPage({super.key});

  @override
  State<RecyclingCategorySelectionPage> createState() =>
      _RecyclingCategorySelectionPageState();
}

class _RecyclingCategorySelectionPageState
    extends State<RecyclingCategorySelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<RCategoryCubit>().getRCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Categories'),
      ),
      body: Container(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 40.0, bottom: 50.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Select a category',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<RCategoryCubit, RCategoryState>(
                builder: (context, state) {
                  if (state is RCategoryStateSuccess) {
                    final categories =
                        List<RCategoryEntity>.from(state.categories)
                          ..sort((a, b) => a.name!.compareTo(b.name!));

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildGridItem(
                          context,
                          rCategory: category,
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildGridItem(BuildContext context,
    {required RCategoryEntity rCategory}) {
  return Card(
    elevation: 0,
    color: white,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    ),
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, PageConst.recyclingCategoryDetailsPage,
            arguments: rCategory);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.network(rCategory.imageUrl!, height: 64),
          const SizedBox(height: 10),
          Text(rCategory.name!, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
