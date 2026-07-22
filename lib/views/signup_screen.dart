import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../viewmodels/signup_view_model.dart';
import '../widgets/ink_frame.dart';
import '../widgets/primary_button.dart';
import '../widgets/sushi_nav_bar.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signUpViewModelProvider, (previous, next) {
      next.whenOrNull(
        data: (state) {
          final user = state.user;
          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng ký tài khoản thành công!')),
            );
            context.go('/');
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký thất bại: $error')),
          );
        },
      );
    });

    final signUpState = ref.watch(signUpViewModelProvider);
    final isLoading = signUpState.isLoading;

    return Scaffold(
      appBar: const SushiNavBar(),
      body: Stack(
        children: [
          const _PaperGrid(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: InkFrame(
                  padding: const EdgeInsets.fromLTRB(34, 38, 34, 34),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'SIGN UP',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'EMAIL (*)'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập email.';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Email không hợp lệ.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'MẬT KHẨU (*)'),
                          onChanged: (_) {
                            if (_confirmPasswordController.text.isNotEmpty) {
                              _formKey.currentState?.validate();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu.';
                            }
                            if (value.length < 8) {
                              return 'Mật khẩu phải có ít nhất 8 ký tự.';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Mật khẩu phải chứa ít nhất 1 chữ hoa.';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Mật khẩu phải chứa ít nhất 1 chữ số.';
                            }
                            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                              return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (!@#%^&*...).';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'XÁC NHẬN MẬT KHẨU (*)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu.';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu không khớp.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(labelText: 'HỌ VÀ TÊN'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'SỐ ĐIỆN THOẠI'),
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              if (!RegExp(r'^0\d{9}$').hasMatch(value.trim())) {
                                return 'Số điện thoại không hợp lệ (10 chữ số, bắt đầu bằng 0).';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 26),
                        PrimaryButton(
                          label: isLoading ? 'Đang đăng ký...' : 'Đăng ký',
                          onPressed: isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Đã có tài khoản? '),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(signUpViewModelProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          phoneNumber: _phoneController.text,
        );
  }
}

class _PaperGrid extends StatelessWidget {
  const _PaperGrid();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _PaperGridPainter()),
    );
  }
}

class _PaperGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.rice.withValues(alpha: 0.26)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 56) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
