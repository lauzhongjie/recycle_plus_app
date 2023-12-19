import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/account/presentation/widgets/edit_profile_args.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/user_cubit.dart';

class AccountPage extends StatefulWidget {
  final VoidCallback navigateToHomePage;

  const AccountPage({super.key, required this.navigateToHomePage});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<String> iconUrls = [];

  @override
  void initState() {
    super.initState();
    retrieveIcons().then((urls) {
      if (mounted) {
        setState(() {
          iconUrls = urls;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return _buildProfilePage(context);
        } else {
          return _pleaseLoginNowWidget(context);
        }
      },
    );
  }

  Widget _pleaseLoginNowWidget(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        const Text('Please login to view your account.'),
        const SizedBox(height: 5),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, PageConst.signInPage);
          },
          child: const Text(
            'Login Now',
            style: TextStyle(
              color: colorPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    ));
  }

  Widget _buildProfilePage(BuildContext context) {
    return BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
      builder: (context, state) {
        if (state is GetSingleUserLoaded) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 60.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              CachedNetworkImageProvider(state.user.imageUrl!),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              backgroundColor: colorSecondary,
                              radius: 15,
                              child: IconButton(
                                onPressed: () {
                                  _changeProfileIcon(context, state.user);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          state.user.name!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildSettingSection(state.user),
                        const SizedBox(height: 20),
                        _buildFavoriteSection(context),
                        const SizedBox(height: 25),
                        _logoutButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (state is GetSingleUserLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Oops. An error occured!'));
        }
      },
    );
  }

  Future<dynamic> _changeProfileIcon(BuildContext context, UserEntity user) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: retrieveIcons(), // Call the method to retrieve icon URLs
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 32.0, right: 32.0, bottom: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Change Profile Icon',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var imageUrl = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              UserEntity updatedUser =
                                  user.copyWith(imageUrl: imageUrl);
                              context
                                  .read<UserCubit>()
                                  .updateUser(user: updatedUser);
                            },
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // If there are no icons, display a message to the user
              return const Center(child: Text('No icons available.'));
            }
          },
        );
      },
    );
  }

  Widget _buildSettingSection(UserEntity user) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle,
                        color: colorPrimary, size: 28),
                    title: const Text('My Account'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        PageConst.editProfilePage,
                        arguments: EditProfileArguments(
                            user: user, iconUrls: iconUrls),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: colorPrimary,
                      size: 28,
                    ),
                    title: const Text('App Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      showSnackbar(
                          context, 'This feature is not yet available');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Saved Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.recycling,
                      color: colorPrimary,
                      size: 28,
                    ),
                    title: const Text('Recycling Centers'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle the tap event
                      Navigator.pushNamed(
                          context, PageConst.favoriteRCenterPage);
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      ImageConst.scanningIcon,
                      color: colorPrimary,
                      height: 28,
                      width: 28,
                    ),
                    title: const Text('Object Scanning'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                          context, PageConst.savedObjectScanningPage);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        BlocProvider.of<AuthCubit>(context).loggedOut();
        BlocProvider.of<GetSingleUserCubit>(context).disposeCurrentUser();
        widget.navigateToHomePage();
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout),
          SizedBox(width: 10),
          Text('Logout', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<List<String>> retrieveIcons() async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to the folder
    final iconsFolderRef = storageRef.child("profile_icon/");

    // List all items (files) in the folder
    ListResult results = await iconsFolderRef.listAll();

    // Get all file download URLs
    List<String> imageUrls = await Future.wait(
      results.items.map(
        (itemRef) => itemRef.getDownloadURL(),
      ),
    );

    return imageUrls;
  }
}
