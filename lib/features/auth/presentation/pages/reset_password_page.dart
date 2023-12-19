import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/core/widgets/loading_overlay.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/credential/credential_cubit.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isResetingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _resetPasswordWidget(context),
          _isResetingPassword ? buildLoadingOverlay() : Container(),
        ],
      ),
    );
  }

  Widget _resetPasswordWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: BlocListener<CredentialCubit, CredentialState>(
        listener: (context, state) {
          if (state is CredentialSuccess) {
            Navigator.pushNamed(context, PageConst.resetPasswordCompletePage);
            _clear();
          } else if (state is CredentialFailure) {
            showSnackbar(context, 'Too many attempts! Please try again later.');
            _clear();
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: white,
            surfaceTintColor: white,
            elevation: 0,
            iconTheme: const IconThemeData(size: 30, color: colorPrimary),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Center(
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
                    'You\'ll receive an email to reset your password.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _resetPassword();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail),
                        SizedBox(width: 8),
                        Text('RESET PASSWORD'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _isResetingPassword = true;
      });
      FocusManager.instance.primaryFocus?.unfocus();

      BlocProvider.of<CredentialCubit>(context)
          .resetPassword(_emailController.text);
    } else {
      showSnackbar(context, 'Field cannot be empty');
    }
  }

  void _clear() {
    setState(() {
      _isResetingPassword = false;
    });
  }
}
