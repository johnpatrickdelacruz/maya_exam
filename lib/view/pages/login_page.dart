import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_maya_exam/widget/common/common_app_bar.dart';
import 'package:new_maya_exam/widget/common/common_button.dart';
import 'package:new_maya_exam/widget/common/common_text_field.dart';
import 'package:new_maya_exam/widget/common/common_app_text.dart';
import 'package:new_maya_exam/bloc/auth/auth_bloc.dart';
import 'package:new_maya_exam/bloc/auth/auth_event.dart';
import 'package:new_maya_exam/bloc/auth/auth_state.dart';
import 'package:new_maya_exam/services/service_locator.dart';
import 'package:new_maya_exam/utils/app_strings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authBloc.close();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      _authBloc.add(AuthSignInRequested(
        email: email,
        password: password,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText.bodyMedium(
            AppStrings.errorEnterEmailPassword,
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText.bodyMedium(
                  state.errorMessage ?? AppStrings.errorLoginFailed,
                  color: Colors.white,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: CommonAppBar(context: context, title: AppStrings.titleLogin),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonTextField(
                  controller: _emailController,
                  label: AppStrings.labelEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _passwordController,
                  label: AppStrings.labelPassword,
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.loading) {
                      return const CircularProgressIndicator();
                    }
                    return CommonButton(
                      text: AppStrings.buttonLogin,
                      onPressed: _login,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
