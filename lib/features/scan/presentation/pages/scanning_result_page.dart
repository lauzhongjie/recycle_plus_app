import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/manage_resources/manage_recycling_items_page.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_record_cubit.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/detected_object_entity.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:path_provider/path_provider.dart';

class ScanningResultPage extends StatefulWidget {
  final Uint8List imageData;
  final List<dynamic> detections;

  const ScanningResultPage({
    super.key,
    required this.imageData,
    required this.detections,
  });

  @override
  State<ScanningResultPage> createState() => _ScanningResultPageState();
}

class _ScanningResultPageState extends State<ScanningResultPage> {
  final PanelController _panelController = PanelController();
  bool isPanelOpen = true;
  List<DetectedObjectEntity> detectedObjects = [];
  bool isScanSaved = false;

  @override
  void initState() {
    super.initState();
    if (widget.detections.isNotEmpty) {
      context.read<RCategoryCubit>().getRCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RCategoryCubit, RCategoryState>(
      builder: (context, state) {
        if (state is RCategoryStateSuccess) {
          _processDetections(state.categories);
        }
        return _buildMainScreen();
      },
    );
  }

  Future<void> _processDetections(List<RCategoryEntity> categories) async {
    detectedObjects =
        await findItemsForDetectedObjects(widget.detections, categories);
    setState(() {});
  }

  Widget _buildMainScreen() {
    var screenSize = MediaQuery.of(context).size;
    var minHeight = screenSize.height * 0.1;

    // Determine maxHeight based on the number of detected items
    double maxHeight;
    int detectionCount = detectedObjects.length;
    if (detectionCount == 0) {
      maxHeight = screenSize.height * 0.45;
    } else if (detectionCount == 1) {
      maxHeight = screenSize.height * 0.5;
    } else if (detectionCount == 2) {
      maxHeight = screenSize.height * 0.65;
    } else {
      maxHeight = screenSize.height * 0.7; // For 3 or more items
    }

    var imageWidget = Image.memory(
      widget.imageData,
      width: screenSize.width,
      height: screenSize.height,
      fit: BoxFit.cover,
    );

    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        backdropEnabled: true,
        minHeight: minHeight,
        maxHeight: maxHeight,
        defaultPanelState: PanelState.OPEN,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        panel: widget.detections.isEmpty
            ? _objNotFoundPanelContent()
            : _objFoundPanelContent(),
        collapsed: _collapsedPanelContent(),
        body: Stack(
          children: [
            Positioned.fill(child: imageWidget),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      left: 25,
      top: 50,
      child: Container(
        width: 50,
        height: 50,
        decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),
      ),
    );
  }

  Widget _collapsedPanelContent() {
    return const Center(
      child: Text("Slide up for more details"),
    );
  }

  Widget _objNotFoundPanelContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NO OBJECTS FOUND',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Unfortunately, there are no objects found in the captured photo. Please point your camera directly at the object you want to recycle.',
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 30.0,
                ),
                child: Text('TRY AGAIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _objFoundPanelContent() {
    int objectCount = widget.detections.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 80.0, 40.0, 80.0),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FOUND $objectCount OBJECTS',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildDetectedObjectsList(),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is Authenticated) {
                      return BlocBuilder<GetSingleUserCubit,
                          GetSingleUserState>(
                        builder: (context, userState) {
                          if (userState is GetSingleUserLoaded) {
                            final scanningRecordCubit =
                                BlocProvider.of<ScanningRecordCubit>(context);

                            return isScanSaved
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints.tightFor(
                                        width: 210),
                                    child: GestureDetector(
                                      onTap: () {
                                        showSnackbar(
                                            context, 'Record already saved');
                                      },
                                      child: const ElevatedButton(
                                        onPressed: null,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 15.0,
                                            horizontal: 30.0,
                                          ),
                                          child: Text('SAVED'),
                                        ),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        isScanSaved = true;
                                      });

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        showSnackbar(context,
                                            'Scanning successfully saved!');
                                      });

                                      // Convert Uint8List to File
                                      File imgFile =
                                          await _convertUint8ListToFile(
                                              widget.imageData);

                                      // Create ScanEntity
                                      ScanEntity scan = ScanEntity(
                                        user: userState.user,
                                        detectedObjectList: detectedObjects,
                                        imageUrl: null,
                                        scanDate: DateTime.now(),
                                      );

                                      // Save Scan using the captured reference
                                      try {
                                        await scanningRecordCubit.createNewScan(
                                          scan,
                                          imgFile,
                                        );

                                        // Delete the temporary file
                                        _deleteTempFile(imgFile);
                                      } catch (e) {
                                        print('Error in saving scanning: $e');
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 30.0,
                                      ),
                                      child: Text('SAVE THIS SCAN'),
                                    ),
                                  );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            PageConst.signInPage,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: grey,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 30.0,
                          ),
                          child: Text('SAVE THIS SCAN'),
                        ),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: darkerGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetectedObjectsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: detectedObjects.length,
      itemBuilder: (context, index) {
        DetectedObjectEntity detectedObject = detectedObjects[index];
        Color color =
            colorMap[detectedObject.item.name!.toLowerCase()] ?? white;
        bool isRecyclable = detectedObject.item.recyclability!;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              PageConst.recyclingItemDetailsPage,
              arguments: RecyclingItemDetailsArguments(
                item: detectedObject.item,
                rCategory: detectedObject.category,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.all(4.0),
            child: ListTile(
              leading: Icon(Icons.circle, color: color),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${detectedObject.item.name!} ',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: 'x',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    TextSpan(
                      text: '${detectedObject.count}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                isRecyclable ? "Recyclable" : "Non-recyclable",
                style: TextStyle(
                  color: isRecyclable ? colorPrimary : Colors.red,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        );
      },
    );
  }

  Future<List<DetectedObjectEntity>> findItemsForDetectedObjects(
    List<dynamic> detections,
    List<RCategoryEntity> categories,
  ) async {
    // Use a Map to keep track of detected items and their counts
    Map<String, DetectedObjectEntity> detectedObjectsMap = {};

    for (var detection in detections) {
      String detectedLabel = detection['class'].toString().toLowerCase();

      // Loop through all categories to find matching items
      for (var category in categories) {
        for (var item in category.itemList ?? []) {
          if (item.name.toString().toLowerCase() == detectedLabel) {
            // If the detected item is already in the map, increment the count
            if (detectedObjectsMap.containsKey(detectedLabel)) {
              detectedObjectsMap[detectedLabel]!.count++;
            } else {
              // Otherwise, create a new DetectedObject and add it to the map
              detectedObjectsMap[detectedLabel] = DetectedObjectEntity(
                item: item,
                category: category,
                count: 1,
              );
            }
          }
        }
      }
    }

    // Return the values of the map which are the unique DetectedObjects with their counts
    return detectedObjectsMap.values.toList();
  }

  Future<File> _convertUint8ListToFile(Uint8List imageData) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/image.jpg');
    await file.writeAsBytes(imageData);
    return file;
  }

  void _deleteTempFile(File file) {
    try {
      file.delete();
    } catch (e) {
      print('File cannot be deleted.');
    }
  }
}
