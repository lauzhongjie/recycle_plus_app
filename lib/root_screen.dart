import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/account/presentation/pages/account_page.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/pages/home_page.dart';
import 'package:recycle_plus_app/features/learn/presentation/pages/learning_page.dart';
import 'package:recycle_plus_app/features/r_center/presentation/pages/r_center_page.dart';

class RootScreen extends StatefulWidget {
  static final GlobalKey<_RootScreenState> rootScreenKey =
      GlobalKey<_RootScreenState>();

  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _currentTab;
  late List<Widget> screens;
  late PageController pageController;
  UserEntity? currentUser;

  @override
  void initState() {
    super.initState();
    _currentTab = 0;
    screens = [
      const HomePage(),
      const RecyclingCenterPage(),
      const LearningPage(),
      AccountPage(navigateToHomePage: navigateToHomePage),
    ];
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;

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
        body: SizedBox(
          height: MediaQuery.of(context).size.height - bottomNavBarHeight,
          child: PageView(
            physics: _currentTab == 1
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            controller: pageController,
            onPageChanged: _onPageChanged,
            children: screens,
          ),
        ),
        floatingActionButton: isKeyboardOpen
            ? Container()
            : FloatingActionButton(
                onPressed: _navigateToScanningPage,
                child: const Icon(Icons.camera_alt),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: buildBottomAppBar(),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentTab = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void navigateToHomePage() {
    setState(() {
      _currentTab = 0;
    });
    pageController.jumpToPage(0);
  }

  void _navigateToScanningPage() {
    Navigator.pushNamed(
      context,
      PageConst.scanningPage,
    );
  }

  Container buildBottomAppBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: black.withOpacity(0.3),
            width: 1.0,
          ),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                buildNavItem(0, Icons.home, 'Home'),
                buildNavItem(1, Icons.location_on_rounded, 'Center'),
              ],
            ),
            Row(
              children: <Widget>[
                buildNavItem(2, Icons.menu_book, 'Learn'),
                buildNavItem(3, Icons.account_circle, 'Account'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MaterialButton buildNavItem(int index, IconData icon, String label) {
    return MaterialButton(
      minWidth: 40,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: () => _onBottomNavItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: _currentTab == index ? colorPrimary : darkGrey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _currentTab == index ? colorPrimary : darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
