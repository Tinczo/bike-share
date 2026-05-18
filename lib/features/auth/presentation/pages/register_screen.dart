import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/widgets.dart';

/// Registration screen for new users.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
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
                  title: 'Dołącz do nas',
                  subtitle: 'Zacznij swoją przygodę z rowerami miejskimi',
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
                        passwordTextField(),
                        const SizedBox(height: 16),
                        confirmPasswordTextField(),
                        const SizedBox(height: 24),
                        registerButton(),
                        const SizedBox(height: 24),
                        loginLink(context),
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

  BlocBuilder<AuthBloc, AuthState> registerButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AuthButton(
          text: 'Zarejestruj się',
          isLoading: state is AuthLoading,
          onPressed: _onRegister,
        );
      },
    );
  }

  AuthTextField confirmPasswordTextField() {
    return AuthTextField(
      controller: _confirmPasswordController,
      label: 'Potwierdź hasło',
      hintText: 'Potwierdź swoje hasło',
      obscureText: _obscureConfirmPassword,
      prefixIcon: const Icon(
        Icons.lock_outline,
        color: AppPalette.hintColor,
        size: 20,
      ),
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
        child: Icon(
          _obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppPalette.hintColor,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Proszę potwierdzić swoje hasło';
        }
        if (value != _passwordController.text) {
          return 'Hasła nie są zgodne';
        }
        return null;
      },
    );
  }

  AuthTextField passwordTextField() {
    return AuthTextField(
      controller: _passwordController,
      label: 'Hasło',
      hintText: 'Wprowadź swoje hasło',
      obscureText: _obscurePassword,
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

  Row loginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Masz już konto? ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppPalette.paragraphColor,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Zaloguj się',
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
}
