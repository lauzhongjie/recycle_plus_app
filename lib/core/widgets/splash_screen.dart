import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/root_screen.dart';

AnimatedSplashScreen startSplashScreen() {
  return AnimatedSplashScreen(
    splash: const SplashScreen(),
    nextScreen: BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        print(state);
        if (state is Authenticated) {
          if (state.role == "admin") {
            return const AdminHomePage();
          }
        }
        return RootScreen(key: RootScreen.rootScreenKey);
      },
    ),
    splashIconSize: 500,
    splashTransition: SplashTransition.fadeTransition,
    pageTransitionType: PageTransitionType.fade,
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          if (authState.role == "user") {
            BlocProvider.of<GetSingleUserCubit>(context)
                .getSingleUser(uid: authState.uid);
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(ImageConst.appLogo),
              const SizedBox(height: 20),
              const Text(
                'Recycle+',
                style: TextStyle(
                  color: colorPrimary,
                  fontSize: 50,
                  fontFamily: 'Hind Vadodara',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.50,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Path to a Greener Future!',
                style: TextStyle(
                  color: colorPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
