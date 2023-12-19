import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:recycle_plus_app/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:recycle_plus_app/features/auth/data/datasources/remote/auth_remote_data_source_impl.dart';
import 'package:recycle_plus_app/features/auth/data/repositories/auth_firebase_repository_impl.dart';
import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/create_user_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/get_current_uid_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/get_single_user_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/get_users_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/is_admin_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/is_sign_in_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/sign_in_user_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/sign_up_user_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/credential/credential_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/user_cubit.dart';
import 'package:recycle_plus_app/features/learn/data/datasources/r_category_remote_data_source.dart';
import 'package:recycle_plus_app/features/learn/data/datasources/r_category_remote_data_source_impl.dart';
import 'package:recycle_plus_app/features/learn/data/repositories/r_category_repository_impl.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/create_new_r_category_item_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/create_new_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/get_r_categories_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/get_r_category_items_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/get_single_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/remove_r_category_item_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/remove_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/update_r_category_item_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/update_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_item_cubit.dart';
import 'package:recycle_plus_app/features/r_center/data/datasources/remote/r_center_remote_data_source.dart';
import 'package:recycle_plus_app/features/r_center/data/datasources/remote/r_center_remote_data_source_impl.dart';
import 'package:recycle_plus_app/features/r_center/data/repositories/r_center_repository_impl.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/create_new_r_center_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/get_nearby_r_center_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/get_r_centers_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/get_single_r_center_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/get_user_saved_r_centers_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/remove_user_saved_r_center_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/save_r_center_as_favorite_use_case.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/fetch_nearby_r_center/fetch_nearby_r_center_cubit.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/get_user_favorite_r_center/get_user_favorite_cubit.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/save_as_favorite_r_center/save_as_favorite_cubit.dart';
import 'package:recycle_plus_app/features/scan/data/datasources/scan_remote_data_source.dart';
import 'package:recycle_plus_app/features/scan/data/datasources/scan_remote_data_source_impl.dart';
import 'package:recycle_plus_app/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/create_new_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/get_all_scans_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/get_all_user_scans_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/get_single_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/remove_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/update_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_cubit.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_record_cubit.dart';

//sl = service locator --> Dependency injection
final sl = GetIt.instance;

Future<void> init() async {
  //--------
  // Cubits
  //--------
  // User
  sl.registerFactory(
    () => AuthCubit(
      signOutUseCase: sl.call(),
      isSignInUseCase: sl.call(),
      getCurrentUidUseCase: sl.call(),
      isAdminUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => CredentialCubit(
      signInUseCase: sl.call(),
      signUpUseCase: sl.call(),
      resetPasswordUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => UserCubit(
      getUsersUseCase: sl.call(),
      updateUserUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => GetSingleUserCubit(
      getSingleUserUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => FetchNearbyRCenterCubit(
      getNearbyRCenterUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => SaveAsFavoriteRCenterCubit(
      saveAsFavoriteUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => GetUserFavoriteRCenterCubit(
      getUserSavedRCentersUseCase: sl.call(),
      removeUserSavedRCenterUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => RCategoryCubit(
      createNewRCategoryUseCase: sl.call(),
      getRCategoriesUseCase: sl.call(),
      getSingleRCategoryUseCase: sl.call(),
      removeRCategoryUseCase: sl.call(),
      updateRCategoryUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => RCategoryItemCubit(
      createNewRCategoryItemUseCase: sl.call(),
      getRCategoryItemsUseCase: sl.call(),
      updateRCategoryItemUseCase: sl.call(),
      removeRCategoryItemUseCase: sl.call(),
    ),
  );

  sl.registerFactory(() => ScanningCubit());
  sl.registerFactory(() => ScanningRecordCubit(
        createNewScanUseCase: sl.call(),
        getAllScansUseCase: sl.call(),
        getAllUserScansUseCase: sl.call(),
        getSingleScanUseCase: sl.call(),
        removeScanUseCase: sl.call(),
        updateScanUseCase: sl.call(),
      ));

  //-----------
  // Use Cases
  //-----------

  // User
  sl.registerLazySingleton(() => SignOutUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => IsSignInUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetCurrentUidUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => SignInUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => SignUpUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetUsersUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => UpdateUserUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => CreateUserUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetSingleUserUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => IsAdminUseCase(repository: sl.call()));

  // Recycling Centers
  sl.registerLazySingleton(
      () => GetNearbyRCenterUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => CreateNewRCenterUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => GetSingleRCentersUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetRCentersUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => SaveRCenterAsFavoriteUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => GetUserSavedRCentersUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => RemoveUserSavedRCenterUseCase(repository: sl.call()));

  // Recycling Category
  sl.registerLazySingleton(
      () => CreateNewRCategoryUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetRCategoriesUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => GetSingleRCategoryUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => UpdateRCategoryUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => RemoveRCategoryUseCase(repository: sl.call()));

  // Recycling Category Item
  sl.registerLazySingleton(
      () => CreateNewRCategoryItemUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => GetRCategoryItemsUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => UpdateRCategoryItemUseCase(repository: sl.call()));
  sl.registerLazySingleton(
      () => RemoveRCategoryItemUseCase(repository: sl.call()));

  // Scanning
  sl.registerLazySingleton(() => CreateNewScanUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetAllScansUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetAllUserScansUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => GetSingleScanUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => RemoveScanUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => UpdateScanUseCase(repository: sl.call()));

  //---------------
  // Cloud Storage
  //---------------
  sl.registerLazySingleton(
      () => UploadImageToFirebaseUseCase(repository: sl.call()));

  //------------
  // Repository
  //------------
  sl.registerLazySingleton<AuthFirebaseRepository>(
    () => AuthFirebaseRepositoryImpl(
      remoteDataSource: sl.call(),
    ),
  );

  sl.registerLazySingleton<RCenterRepository>(
    () => RCenterRepositoryImpl(
      rCenterRemoteDataSource: sl.call(),
    ),
  );

  sl.registerLazySingleton<RCategoryRepository>(
    () => RCategoryRepositoryImpl(
      rCategoryRemoteDataSource: sl.call(),
    ),
  );

  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(scanRemoteDataSource: sl.call()),
  );

  //--------------------
  // Remote Data Source
  //--------------------
  sl.registerLazySingleton<AuthFirebaseRemoteDataSource>(
    () => AuthFirebaseRemoteDataSourceImpl(
      firebaseFirestore: sl.call(),
      firebaseAuth: sl.call(),
      firebaseStorage: sl.call(),
    ),
  );

  sl.registerLazySingleton<RCenterRemoteDataSource>(
    () => RCenterRemoteDataSourceImpl(
      firebaseFirestore: sl.call(),
    ),
  );

  sl.registerLazySingleton<RCategoryRemoteDataSource>(
    () => RCategoryRemoteDataSourceImpl(
      firebaseFirestore: sl.call(),
      firebaseStorage: sl.call(),
    ),
  );

  sl.registerLazySingleton<ScanRemoteDataSource>(
    () => ScanRemoteDataSourceImpl(
      firebaseFirestore: sl.call(),
      firebaseStorage: sl.call(),
    ),
  );

  //------------
  // Externals
  //------------
  final firebaseFirestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseStorage = FirebaseStorage.instance;

  sl.registerLazySingleton(() => firebaseFirestore);
  sl.registerLazySingleton(() => firebaseAuth);
  sl.registerLazySingleton(() => firebaseStorage);
}
