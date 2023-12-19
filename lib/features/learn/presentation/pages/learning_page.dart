import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/apis.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/core/widgets/loading_overlay.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Recycle?'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, top: 65.0, bottom: 30.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Start Discovering !',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.arrow_downward),
                  const SizedBox(height: 10),
                  _buildCards(
                    context,
                    ImageConst.threeRecycleBinIcon,
                    'Recycling Categories',
                    PageConst.recyclingCategorySelectionPage,
                  ),
                  const SizedBox(height: 10),
                  _buildCards(
                    context,
                    ImageConst.chatbotIcon,
                    'Ask Me',
                    '',
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(
      BuildContext context, String img, String txt, String? routeName) {
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
          if (txt == 'Ask Me') {
            buildConversation(context);
          } else {
            Navigator.pushNamed(context, routeName!);
          }
        },
        child: SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  img,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  txt,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void buildConversation(BuildContext context) async {
    dynamic conversationObject = {'appId': APIConst.kommunicateAPIKey};

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return buildLoadingOverlay();
      },
    );

    try {
      var result =
          await KommunicateFlutterPlugin.buildConversation(conversationObject);
      if (kDebugMode) {
        print("Conversation builder success: $result");
      }
      // Dismiss the loading overlay
      Navigator.pop(context);
    } catch (error) {
      if (kDebugMode) {
        print("Conversation builder error occurred: $error");
      }
      // Dismiss the loading overlay
      Navigator.pop(context);
    }
  }
}
