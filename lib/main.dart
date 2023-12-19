import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:recycle_plus_app/config/routes/app_routes.dart';
import 'package:recycle_plus_app/config/theme/app_theme.dart';
import 'package:recycle_plus_app/core/widgets/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/credential/credential_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/user_cubit.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_item_cubit.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/fetch_nearby_r_center/fetch_nearby_r_center_cubit.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/get_user_favorite_r_center/get_user_favorite_cubit.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/save_as_favorite_r_center/save_as_favorite_cubit.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_cubit.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_record_cubit.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;

List<CameraDescription> cameras = [];
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..loggedIn()),
        BlocProvider(create: (_) => di.sl<CredentialCubit>()),
        BlocProvider(create: (_) => di.sl<UserCubit>()),
        BlocProvider(create: (_) => di.sl<GetSingleUserCubit>()),
        BlocProvider(create: (_) => di.sl<FetchNearbyRCenterCubit>()),
        BlocProvider(create: (_) => di.sl<SaveAsFavoriteRCenterCubit>()),
        BlocProvider(create: (_) => di.sl<GetUserFavoriteRCenterCubit>()),
        BlocProvider(create: (_) => di.sl<RCategoryCubit>()),
        BlocProvider(create: (_) => di.sl<RCategoryItemCubit>()),
        BlocProvider(create: (_) => di.sl<ScanningCubit>()),
        BlocProvider(create: (_) => di.sl<ScanningRecordCubit>()),
      ],
      child: MaterialApp(
        
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.light,
        onGenerateRoute: OnGenerateRoute.route,
        initialRoute: "/",
        routes: {
          "/": (context) => startSplashScreen(),
        },
      ),
    );
  }
}
