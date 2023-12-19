import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/manage_resources/manage_recycling_items_page.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/detected_object_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SavedObjectScanningResultPage extends StatelessWidget {
  final ScanEntity scan;

  const SavedObjectScanningResultPage({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final PanelController panelController = PanelController();
    List<DetectedObjectEntity> detectedObjects = scan.detectedObjectList!;

    var screenSize = MediaQuery.of(context).size;
    var minHeight = screenSize.height * 0.1;

    // Determine maxHeight based on the number of detected items
    double maxHeight;
    int detectionCount = detectedObjects.length;
    if (detectionCount == 0) {
      maxHeight = screenSize.height * 0.3;
    } else if (detectionCount == 1) {
      maxHeight = screenSize.height * 0.4;
    } else if (detectionCount == 2) {
      maxHeight = screenSize.height * 0.5;
    } else {
      maxHeight = screenSize.height * 0.6; // For 3 or more items
    }

    var imageWidget = CachedNetworkImage(
      imageUrl: scan.imageUrl!,
      width: screenSize.width,
      height: screenSize.height,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        backdropEnabled: true,
        minHeight: minHeight,
        maxHeight: maxHeight,
        defaultPanelState: PanelState.OPEN,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        panel: _objFoundPanelContent(detectedObjects),
        collapsed: _collapsedPanelContent(),
        body: Stack(
          children: [
            Positioned.fill(child: imageWidget),
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _collapsedPanelContent() {
    return const Center(
      child: Text("Slide up for more details"),
    );
  }

  Widget _buildBackButton(BuildContext context) {
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

  Widget _objFoundPanelContent(List<DetectedObjectEntity> detectedObjects) {
    int objectCount = detectedObjects.length;
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
                  child: _buildDetectedObjectsList(detectedObjects),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetectedObjectsList(List<DetectedObjectEntity> detectedObjects) {
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
}
