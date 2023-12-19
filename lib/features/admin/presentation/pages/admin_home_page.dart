import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/root_screen.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorSecondary,
        leading: Container(),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: white),
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).loggedOut();
                Navigator.popUntil(
                    context, (route) => route.isFirst); // Pop until Root Screen
                RootScreen.rootScreenKey.currentState?.navigateToHomePage();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            decoration: const BoxDecoration(
              color: colorSecondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      icon: Icons.edit,
                      imageAsset: '',
                      label: 'Manage Resources',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          PageConst.manageRecyclingCategoriesPage,
                        );
                      },
                    ),
                    _buildButton(
                      icon: null,
                      imageAsset: ImageConst.viewReportIcon,
                      label: 'View Report',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          PageConst.adminSelectReportPage,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImageConst.appLogoSmall,
                width: 50,
                height: 50,
              ),
              const SizedBox(height: 5),
              const Text(
                'Recycle+',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData? icon,
    required String imageAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 170,
          minHeight: 170,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: colorPrimary,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 50,
                    color: white,
                  )
                else
                  Image.asset(
                    imageAsset,
                    width: 50,
                    height: 50,
                    color: white,
                  ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
