import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/features/auth/bloc/auth_bloc.dart';
import 'package:costbook/features/auth/widgets/login_background.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';

part 'login_page_ext.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(SavedEmailRequested());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRememberMeChanged(bool? value) {
    setState(() => _rememberMe = value ?? false);
  }

  void _fillSavedEmail(String email) {
    if (_emailController.text.isNotEmpty) return;
    _emailController.text = email;
  }

  void _onLogin() {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state.status == AppStatus.loading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    authBloc.add(
      LoginSubmitted(email: _emailController.text.trim(), password: _passwordController.text, rememberMe: _rememberMe),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current.status == AppStatus.success,
          listener: (context, state) {
            // ส่งฟอร์ม login ให้ browser ตอนนี้เลย (ก่อนเปลี่ยนหน้า) → Chrome ถามบันทึกรหัสครั้งเดียวตอน login
            // ถ้ารอให้ส่งตอนปิดหน้า Chrome จะเดาจากการเปลี่ยนหน้าแทน แล้วถามซ้ำตอนเปลี่ยนหน้า
            TextInput.finishAutofillContext();
            context.go(AppRoutes.dashboard);
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current.savedEmail.isNotEmpty,
          listener: (context, state) => _fillSavedEmail(state.savedEmail),
        ),
      ],
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const LoginBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(padding: EdgeInsets.all(_pagePadding(context)), child: _content(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
