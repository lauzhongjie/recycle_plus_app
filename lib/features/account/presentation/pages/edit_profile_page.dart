import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/credential/credential_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/user_cubit.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;
  final List<String> iconUrls;

  const EditProfilePage({
    super.key,
    required this.user,
    required this.iconUrls,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String tempIconUrl;
  late String email;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name ?? '';
    tempIconUrl = widget.user.imageUrl!;
    email = widget.user.email!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CredentialCubit, CredentialState>(
      listener: (context, state) {
        if (state is CredentialSuccess) {
          showSnackbar(
              context, 'Reset password link sent. Please check your email.');
        } else if (state is CredentialFailure) {
          showSnackbar(context, 'Too many attempts! Please try again later.');
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            CachedNetworkImageProvider(tempIconUrl),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: colorSecondary,
                            radius: 15,
                            child: IconButton(
                              onPressed: () {
                                _changeProfileIcon(context, widget.iconUrls);
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
                    ],
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          TextFormField(
                            initialValue: widget.user.email ?? '',
                            style: const TextStyle(color: darkGrey),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: darkGrey),
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            readOnly: true,
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  showSnackbar(
                                      context, 'Email cannot be changed');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            BlocProvider.of<CredentialCubit>(context)
                                .resetPassword(email);
                          },
                          child: const Text(
                            'Click Here To Change Password',
                            style: TextStyle(
                              color: colorPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        UserEntity updatedUser = widget.user.copyWith(
                            name: _nameController.text, imageUrl: tempIconUrl);
                        context.read<UserCubit>().updateUser(user: updatedUser);
                        showSnackbar(context, 'Profile successfully updated');
                        Navigator.pop(context);
                      }
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: const Text('SAVE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _changeProfileIcon(
      BuildContext context, List<String> imageUrls) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    var imageUrl = imageUrls[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          tempIconUrl = imageUrl; // Update temporary icon URL
                        });
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
      },
    );
  }
}
