import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_event.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';

/// Learning Notes:
/// Form Key
/// - A GlobalKey<FormState> is used to uniquely identify the Form widget
/// - Allows us to validate the form fields and manage their state.
/// Text Controllers
/// - Each input field needs its own controller to read/clear the value.
/// - Seperate the controllers to avoid conflicts.
/// Focus Nodes
/// - FocusNodes let us programmatically move the focus of input fields.
/// - Without these, user would have to manually tap each field.
/// Lifecycle: dispose
/// - Every controller and focus node allocates native resources.
/// - If we don't dispose them, they stay in memory even after

enum AuthTab { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthTab _currentTab = AuthTab.login;
  late final PageController _pageController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  final _loginEmailFocusNode = FocusNode();
  final _loginPasswordFocusNode = FocusNode();

  final _registerUsernameFocusNode = FocusNode();
  final _registerEmailFocusNode = FocusNode();
  final _registerPasswordFocusNode = FocusNode();
  final _registerConfirmPasswordFocusNode = FocusNode();

  bool _loginObscurePassword = true;
  bool _registerObscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _loginHasSubmitted = false;
  bool _registerHasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _loginEmailFocusNode.dispose();
    _loginPasswordFocusNode.dispose();
    _registerUsernameFocusNode.dispose();
    _registerEmailFocusNode.dispose();
    _registerPasswordFocusNode.dispose();
    _registerConfirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _switchTab(AuthTab tab) {
    if (tab == _currentTab) return;
    setState(() {
      _currentTab = tab;
    });
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(
      tab == AuthTab.login ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-\+]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
    );
    if (!passwordRegex.hasMatch(value.trim())) {
      return 'Password must be at least 8 characters,\ninclude uppercase, lowercase, number and special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _registerPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // How the validation flow works end-to end:
  //
  // User taps "Login" button
  // │
  // ├── setState: _hasSubmitted = true
  // │   (triggers rebuild, validators now return errors)
  // │
  // ├── _ somethingFormKey.currentState.validate()
  // │   │
  // │   ├── Calls _validateSomething("") → "Something is required"
  // │   │   └── TextFormField shows red error text
  // │   │
  // │   └── Returns false (at least one validator returned non-null)
  // │
  // └── if (false) → BLoC event NOT dispatched

  void _submitLogin() {
    setState(() => _loginHasSubmitted = true);
    if (_loginFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text,
        ),
      );
    }
  }

  void _submitRegister() {
    setState(() => _registerHasSubmitted = true);
    if (_registerFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          name: _registerUsernameController.text.trim(),
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.brownEspresso,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Logo
                          Image.asset(
                            'lib/assets/images/pocketree logo.png',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Pocket',
                                  style: TextStyle(
                                    color: AppColors.darkMidnightLeaf,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'ree',
                                  style: TextStyle(
                                    color: AppColors.primarySpring,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle
                          Text(
                            _currentTab == AuthTab.login
                                ? 'Continue your journey'
                                : 'Create a new account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.brownMocha),
                          ),
                          const SizedBox(height: 28),

                          // Tab Switcher
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.neutralSand,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                // Login tab
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchTab(AuthTab.login),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        gradient: _currentTab == AuthTab.login
                                            ? AppColors.primaryGradient
                                            : null,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: _currentTab == AuthTab.login
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primaryForest
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _currentTab == AuthTab.login
                                              ? AppColors.white
                                              : AppColors.brownDriftwood,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Register tab
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchTab(AuthTab.register),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        gradient:
                                            _currentTab == AuthTab.register
                                            ? AppColors.primaryGradient
                                            : null,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow:
                                            _currentTab == AuthTab.register
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primaryForest
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _currentTab == AuthTab.register
                                              ? AppColors.white
                                              : AppColors.brownDriftwood,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Forms
                          ExpandablePageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // Login Form
                              Form(
                                key: _loginFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _loginEmailController,
                                      focusNode: _loginEmailFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autovalidateMode: _loginHasSubmitted
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: (v) =>
                                          _loginHasSubmitted ? _validateEmail(v) : null,
                                      onFieldSubmitted: (_) =>
                                          _loginPasswordFocusNode
                                              .requestFocus(),
                                      decoration: const InputDecoration(
                                        hintText: 'your_email@gmail.com',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _loginPasswordController,
                                      focusNode: _loginPasswordFocusNode,
                                      obscureText: _loginObscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autovalidateMode: _loginHasSubmitted
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: (v) =>
                                          _loginHasSubmitted ? _validatePassword(v) : null,
                                      onFieldSubmitted: (_) => _submitLogin(),
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _loginObscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                            color: AppColors.brownMocha,
                                          ),
                                          onPressed: () => setState(
                                            () => _loginObscurePassword =
                                                !_loginObscurePassword,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          // TODO: Forgot password flow
                                        },
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryForest,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: isLoading
                                              ? null
                                              : AppColors.primaryGradient,
                                          color: isLoading
                                              ? AppColors.primaryForest
                                                    .withValues(alpha: 0.4)
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: isLoading
                                              ? []
                                              : [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .primaryForest
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _submitLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: AppColors.white,
                                                      ),
                                                )
                                              : const Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Register Form
                              Form(
                                key: _registerFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Username',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _registerUsernameController,
                                      focusNode: _registerUsernameFocusNode,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      autovalidateMode: _registerHasSubmitted
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: (value) {
                                        if (!_registerHasSubmitted) return null;
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Username is required';
                                        }
                                        final usernameRegex = RegExp(
                                          r'^[a-zA-Z0-9_-]{3,20}$',
                                        );
                                        if (!usernameRegex.hasMatch(
                                          value.trim(),
                                        )) {
                                          return 'Username must be between 3 and 20 characters,\nand can only contain letters, numbers, underscores, and hyphens';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) =>
                                          _registerEmailFocusNode
                                              .requestFocus(),
                                      decoration: const InputDecoration(
                                        hintText: 'john_doe',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _registerEmailController,
                                      focusNode: _registerEmailFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autovalidateMode: _registerHasSubmitted
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: (v) =>
                                          _registerHasSubmitted ? _validateEmail(v) : null,
                                      onFieldSubmitted: (_) =>
                                          _registerPasswordFocusNode
                                              .requestFocus(),
                                      decoration: const InputDecoration(
                                        hintText: 'your_email@gmail.com',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _registerPasswordController,
                                      focusNode: _registerPasswordFocusNode,
                                      obscureText: _registerObscurePassword,
                                      textInputAction: TextInputAction.next,
                                      autovalidateMode: _registerHasSubmitted
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: (v) =>
                                          _registerHasSubmitted ? _validatePassword(v) : null,
                                      onFieldSubmitted: (_) =>
                                          _registerConfirmPasswordFocusNode
                                              .requestFocus(),
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _registerObscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                            color: AppColors.brownMocha,
                                          ),
                                          onPressed: () => setState(
                                            () => _registerObscurePassword =
                                                !_registerObscurePassword,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Confirm Password',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brownDriftwood,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller:
                                          _registerConfirmPasswordController,
                                      focusNode:
                                          _registerConfirmPasswordFocusNode,
                                      obscureText: _obscureConfirmPassword,
                                      textInputAction: TextInputAction.done,
                                      autovalidateMode: _registerHasSubmitted
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: (v) =>
                                          _registerHasSubmitted ? _validateConfirmPassword(v) : null,
                                      onFieldSubmitted: (_) =>
                                          _submitRegister(),
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                            color: AppColors.brownMocha,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscureConfirmPassword =
                                                !_obscureConfirmPassword,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 26),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: isLoading
                                              ? null
                                              : AppColors.primaryGradient,
                                          color: isLoading
                                              ? AppColors.primaryForest
                                                    .withValues(alpha: 0.4)
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: isLoading
                                              ? []
                                              : [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .primaryForest
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _submitRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: AppColors.white,
                                                      ),
                                                )
                                              : const Text(
                                                  'Register',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: AppColors.neutralTaupe,
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    color: AppColors.brownMocha,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: AppColors.neutralTaupe,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Other login/register options
                          Row(
                            children: [
                              // Google
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Google sign-in
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.brownEspresso,
                                    side: const BorderSide(
                                      color: AppColors.neutralTaupe,
                                      width: 0.8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    backgroundColor: AppColors.white,
                                    minimumSize: const Size(0, 52),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Google',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.brownEspresso,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Apple
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Apple sign-in
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.brownEspresso,
                                    side: const BorderSide(
                                      color: AppColors.neutralTaupe,
                                      width: 0.8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    backgroundColor: AppColors.white,
                                    minimumSize: const Size(0, 52),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.apple,
                                        size: 20,
                                        color: AppColors.brownEspresso,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Apple',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.brownEspresso,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentTab == AuthTab.login
                                    ? "Don't have an account? "
                                    : 'Already have an account? ',
                                style: const TextStyle(
                                  color: AppColors.brownDriftwood,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _switchTab(
                                  _currentTab == AuthTab.login
                                      ? AuthTab.register
                                      : AuthTab.login,
                                ),
                                child: Text(
                                  _currentTab == AuthTab.login
                                      ? 'Sign Up'
                                      : 'Sign In',
                                  style: const TextStyle(
                                    color: AppColors.primaryForest,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                16 + MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
