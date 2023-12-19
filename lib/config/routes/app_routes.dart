import 'package:flutter/material.dart';
import 'package:recycle_plus_app/features/account/presentation/pages/edit_profile_page.dart';
import 'package:recycle_plus_app/features/account/presentation/pages/favorite_r_center_page.dart';
import 'package:recycle_plus_app/features/account/presentation/pages/saved_object_scanning_page.dart';
import 'package:recycle_plus_app/features/account/presentation/pages/saved_object_scanning_result_page.dart';
import 'package:recycle_plus_app/features/account/presentation/widgets/edit_profile_args.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/manage_resources/manage_recycling_categories_page.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/manage_resources/manage_recycling_items_page.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/reports/admin_select_report_page.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/reports/user_scanning_report_page.dart';
import 'package:recycle_plus_app/features/auth/presentation/pages/reset_password_complete_page.dart';
import 'package:recycle_plus_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:recycle_plus_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:recycle_plus_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/pages/recycling_category/recycle_category_details_page.dart';
import 'package:recycle_plus_app/features/learn/presentation/pages/recycling_category/recycle_category_selection_page.dart';
import 'package:recycle_plus_app/features/learn/presentation/pages/recycling_category/recycle_item_details_page.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/presentation/pages/r_center_details.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/presentation/pages/scanning_page.dart';
import 'package:recycle_plus_app/features/scan/presentation/pages/scanning_result_page.dart';
import 'app_routes_const.dart';

class OnGenerateRoute {
  static Route<dynamic>? route(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case PageConst.scanningPage:
        {
          return routeBuilder(const ScanningPage());
        }
      case PageConst.scanningResultPage:
        if (args is Map<String, dynamic>) {
          return routeBuilder(ScanningResultPage(
            imageData: args['imageData'],
            detections: args['detections'],
          ));
        }
        break;
      case PageConst.signInPage:
        {
          return routeBuilder(const SignInPage());
        }
      case PageConst.signUpPage:
        {
          return routeBuilder(const SignUpPage());
        }
      case PageConst.resetPasswordPage:
        {
          return routeBuilder(const ResetPasswordPage());
        }
      case PageConst.resetPasswordCompletePage:
        {
          return routeBuilder(const ResetPasswordCompletePage());
        }
      case PageConst.rcDetailsPage:
        {
          if (args is RCenterEntity) {
            return routeBuilder(RCenterDetailsPage(rCenter: args));
          }
        }
      case PageConst.editProfilePage:
        {
          if (args is EditProfileArguments) {
            return routeBuilder(EditProfilePage(
              user: args.user,
              iconUrls: args.iconUrls,
            ));
          }
        }
      case PageConst.favoriteRCenterPage:
        {
          return routeBuilder(const FavoriteRCenterPage());
        }
      case PageConst.savedObjectScanningPage:
        {
          return routeBuilder(const SavedObjectScanningPage());
        }
      case PageConst.savedObjectScanningResultPage:
        {
          if (args is ScanEntity) {
            return routeBuilder(SavedObjectScanningResultPage(scan: args));
          }
        }
      case PageConst.recyclingCategorySelectionPage:
        {
          return routeBuilder(const RecyclingCategorySelectionPage());
        }
      case PageConst.recyclingCategoryDetailsPage:
        {
          if (args is RCategoryEntity) {
            return routeBuilder(RecyclingCategoryDetailsPage(
              rCategory: args,
            ));
          }
        }
      case PageConst.recyclingItemDetailsPage:
        if (args is RecyclingItemDetailsArguments) {
          return routeBuilder(
            RecyclingItemDetailsPage(
              item: args.item,
              rCategory: args.rCategory,
            ),
          );
        }
      case PageConst.adminHomePage:
        {
          return routeBuilder(const AdminHomePage());
        }
      case PageConst.adminSelectReportPage:
        {
          return routeBuilder(const AdminSelectReportPage());
        }
      case PageConst.userScanningReportPage:
        {
          return routeBuilder(const UserScanningReportPage());
        }
      case PageConst.manageRecyclingCategoriesPage:
        {
          return routeBuilder(const ManageRecyclingCategoriesPage());
        }
      case PageConst.manageRecyclingItemsPage:
        {
          if (args is RCategoryEntity) {
            return routeBuilder(ManageRecyclingItemsPage(rCategory: args));
          }
        }
      default:
        {
          const NoPageFound();
        }
    }
    return null;
  }
}

dynamic routeBuilder(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

class NoPageFound extends StatelessWidget {
  const NoPageFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page not found'),
      ),
      body: const Center(child: Text('Page not found')),
    );
  }
}
