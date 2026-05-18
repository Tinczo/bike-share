import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/widgets.dart';

/// Login screen for user authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/settings'),
        backgroundColor: AppPalette.primaryBlue,
        child: const Icon(Icons.settings_outlined, color: Colors.white),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Header(
                  title: 'Witaj z powrotem!',
                  subtitle: 'Zaloguj się do swojego konta',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        emailTextField(),
                        const SizedBox(height: 16),
                        passTextField(),
                        const SizedBox(height: 24),
                        loginButton(),
                        const SizedBox(height: 24),
                        registerLink(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row registerLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Nie masz jeszcze konta? ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppPalette.paragraphColor,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/register'),
          child: const Text(
            'Zarejestruj się',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppPalette.primaryBlue,
              decoration: TextDecoration.underline,
              decorationColor: AppPalette.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  BlocBuilder<AuthBloc, AuthState> loginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AuthButton(
          text: 'Zaloguj się',
          onPressed: _onLogin,
          isLoading: state is AuthLoading,
        );
      },
    );
  }

  AuthTextField passTextField() {
    return AuthTextField(
      controller: _passwordController,
      label: 'Hasło',
      hintText: 'Twoje hasło',
      obscureText: _obscurePassword,
      labelSuffix: GestureDetector(
        onTap: () {
          // TODO: Navigate to forgot password
        },
        child: const Text(
          'Zapomniałeś?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppPalette.primaryBlue,
          ),
        ),
      ),
      prefixIcon: const Icon(
        Icons.lock_outline,
        color: AppPalette.hintColor,
        size: 20,
      ),
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        child: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppPalette.hintColor,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Proszę podać hasło';
        }
        if (value.length < 6) {
          return 'Hasło musi mieć co najmniej 6 znaków';
        }
        return null;
      },
    );
  }

  AuthTextField emailTextField() {
    return AuthTextField(
      controller: _emailController,
      label: 'Adres e-mail',
      hintText: 'twoj@email.com',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(
        Icons.mail_outline,
        color: AppPalette.hintColor,
        size: 20,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Proszę podać adres e-mail';
        }
        if (!value.contains('@')) {
          return 'Proszę podać poprawny adres e-mail';
        }
        return null;
      },
    );
  }
}
