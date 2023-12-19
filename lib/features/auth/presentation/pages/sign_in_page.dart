import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/core/widgets/loading_overlay.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/credential/credential_cubit.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSigningIn = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<CredentialCubit, CredentialState>(
        listener: (context, credentialState) {
          if (credentialState is CredentialSuccess) {
            BlocProvider.of<AuthCubit>(context).loggedIn();
          } else if (credentialState is CredentialFailure) {
            showSnackbar(context, credentialState.errorMessage);
          }
        },
        builder: (context, credentialState) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, authState) {
              // CHECK IS USER OR ADMIN LOGIN
              if (authState is Authenticated) {
                // GO TO USER SIDE
                if (authState.role == "user") {
                  final previousRoute =
                      ModalRoute.of(context)!.settings.arguments as String?;
                  if (previousRoute != null) {
                    Navigator.popUntil(context,
                        (route) => route.settings.name == previousRoute);
                  } else {
                    Navigator.pop(context);
                  }
                }
                // GO TO ADMIN SIDE
                else {
                  Navigator.pushNamed(
                    context,
                    PageConst.adminHomePage,
                  );
                }
              }
            },
            child: _signInWidget(context),
          );
        },
      ),
    );
  }

  Widget _signInWidget(BuildContext context) {
    return Stack(
      children: [
        buildMainContent(context),
        _isSigningIn ? buildLoadingOverlay() : Container(),
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
        body: _bodyWidget(context),
        bottomNavigationBar: _goToSignUpWidget(context),
      ),
    );
  }

  Padding _goToSignUpWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Don\'t have an account? ',
          ),
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pushNamed(context, PageConst.signUpPage);
            },
            child: const Text(
              'Register Now',
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

  Widget _bodyWidget(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availableHeight = constraints.maxHeight;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      ImageConst.appLogo,
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Please login to continue',
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        _signInUserWithEmailAndPassword();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('LOGIN'),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pushNamed(
                              context, PageConst.resetPasswordPage);
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: darkerGrey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  void _signInUserWithEmailAndPassword() {
    setState(() {
      _isSigningIn = true;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    BlocProvider.of<CredentialCubit>(context)
        .signInUser(
          email: _emailController.text,
          password: _passwordController.text,
        )
        .then((value) => _clear());
  }

  _clear() {
    setState(() {
      _isSigningIn = false;
    });
  }
}
