import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/core/widgets/loading_overlay.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/credential/credential_cubit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSigningUp = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<CredentialCubit, CredentialState>(
        listener: (context, state) {
          if (state is CredentialSuccess) {
            BlocProvider.of<AuthCubit>(context).loggedIn();
          } else if (state is CredentialFailure) {
            showSnackbar(context, state.errorMessage);
          }
        },
        builder: (context, credentialState) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, authState) {
              if (authState is Authenticated) {
                final previousRoute =
                    ModalRoute.of(context)!.settings.arguments as String?;
                if (previousRoute != null) {
                  Navigator.popUntil(
                      context, (route) => route.settings.name == previousRoute);
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: _signUpWidget(context),
          );
        },
      ),
    );
  }

  Widget _signUpWidget(BuildContext context) {
    return Stack(
      children: [
        buildMainContent(context),
        _isSigningUp ? buildLoadingOverlay() : Container(),
      ],
    );
  }

  Widget buildMainContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: _appBarWidget(),
        body: _bodyWidget(),
        bottomNavigationBar: _goToSignInWidget(context),
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      backgroundColor: white,
      surfaceTintColor: white,
      elevation: 0,
      iconTheme: const IconThemeData(size: 30, color: colorPrimary),
    );
  }

  Widget _goToSignInWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
          ),
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
            child: const Text(
              'Login Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              ImageConst.appLogo,
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            const Text(
              'Create your account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                focusColor: colorSecondary,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                focusColor: colorSecondary,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText:
                  !_isConfirmPasswordVisible, // Use the state variable here
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus(); // Hide keyboard
                _signUpUser();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('REGISTER'),
            ),
          ],
        ),
      ),
    );
  }

  void _signUpUser() {
    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackbar(context, 'Confirm password does not match with password.');
      return;
    } else {
      setState(() {
        _isSigningUp = true;
      });
      BlocProvider.of<CredentialCubit>(context)
          .signUpUser(
            user: UserEntity(
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
            ),
          )
          .then((value) => _clear());
    }
  }

  _clear() {
    setState(() {
      _isSigningUp = false;
    });
  }
}
