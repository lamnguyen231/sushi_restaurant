import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/sushi_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cccdController = TextEditingController();

  bool _isLoading = false;
  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            uid: uid,
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            cccd: _cccdController.text.trim().isEmpty
                ? null
                : _cccdController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: AppTheme.moss,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.vermilion,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Vui lòng đăng nhập'));
          }

          if (!_isInit) {
            _nameController.text = user.displayName ?? '';
            _phoneController.text = user.phoneNumber ?? '';
            _addressController.text = user.address ?? '';
            _cccdController.text = user.cccd ?? '';
            _isInit = true;
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.paper,
                  border: Border.all(color: AppTheme.rice),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'HỒ SƠ CÁ NHÂN',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Email (readonly)
                      TextFormField(
                        initialValue: user.email,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: AppTheme.rice,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên *',
                          hintText: 'Nhập họ tên của bạn',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bắt buộc nhập họ tên'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại *',
                          hintText: 'Nhập số điện thoại',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bắt buộc nhập số điện thoại'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ nhận hàng *',
                          hintText: 'Nhập địa chỉ giao hàng',
                        ),
                        maxLines: 2,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bắt buộc nhập địa chỉ'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // CCCD
                      TextFormField(
                        controller: _cccdController,
                        decoration: const InputDecoration(
                          labelText: 'CCCD (không bắt buộc)',
                          hintText: 'Nhập số CCCD',
                        ),
                      ),
                      const SizedBox(height: 32),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              label: 'CẬP NHẬT THÔNG TIN',
                              onPressed: () => _updateProfile(user.id),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
