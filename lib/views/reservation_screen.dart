import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../viewmodels/reservation_view_model.dart';
import '../core/providers/firebase_providers.dart';
import '../widgets/sushi_nav_bar.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  int _selectedGuestCount = 2;
  bool _submittedSuccessfully = false;

  @override
  void initState() {
    super.initState();
    // Prefill user details if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _nameCtrl.text = user.displayName!;
        }
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
          _phoneCtrl.text = user.phoneNumber!;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.vermilion,
              onPrimary: Colors.white,
              onSurface: AppTheme.ink,
            ),
            datePickerTheme: const DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.vermilion,
              onPrimary: Colors.white,
              onSurface: AppTheme.ink,
            ),
            timePickerTheme: const TimePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(reservationViewModelProvider);

    if (_submittedSuccessfully) {
      return _ReservationSuccessScreen(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        dateTime: _combinedDateTime,
        guestCount: _selectedGuestCount,
        note: _noteCtrl.text,
        onDone: () {
          setState(() {
            _submittedSuccessfully = false;
            _nameCtrl.clear();
            _phoneCtrl.clear();
            _noteCtrl.clear();
            _selectedDate = DateTime.now().add(const Duration(days: 1));
            _selectedTime = const TimeOfDay(hour: 18, minute: 0);
            _selectedGuestCount = 2;
          });
          ref.read(reservationViewModelProvider.notifier).reset();
        },
      );
    }

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: vmState.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.vermilion),
              SizedBox(height: 16),
              Text(
                'Đang gửi yêu cầu đặt bàn...',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 16, color: AppTheme.ink),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.vermilion),
                const SizedBox(height: 12),
                Text('Lỗi đặt bàn: $e', style: const TextStyle(color: AppTheme.mutedInk)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => ref.read(reservationViewModelProvider.notifier).reset(),
                  child: const Text('THỬ LẠI'),
                ),
              ],
            ),
          ),
        ),
        data: (_) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: AppTheme.ink),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'ĐẶT BÀN TRƯỚC',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 4,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 60,
                                    height: 2,
                                    color: AppTheme.vermilion,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Đặt trước bàn để được phục vụ tốt nhất khi tới nhà hàng',
                                    style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Name Field
                            Text(
                              'HỌ VÀ TÊN *',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameCtrl,
                              keyboardType: TextInputType.name,
                              style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                              decoration: const InputDecoration(
                                hintText: 'Nhập tên của bạn',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập họ và tên';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Phone Field
                            Text(
                              'SỐ ĐIỆN THOẠI *',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                              decoration: const InputDecoration(
                                hintText: 'Nhập số điện thoại nhận thông tin',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập số điện thoại';
                                }
                                if (!RegExp(r'^[0-9+]{9,11}$').hasMatch(val.trim())) {
                                  return 'Vui lòng nhập số điện thoại hợp lệ (9-11 chữ số)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Date and Time selectors
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NGÀY ĐẶT BÀN *',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(fontSize: 11),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: _selectDate,
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppTheme.ink),
                                            color: AppTheme.paper,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                                style: const TextStyle(
                                                  fontFamily: 'Georgia',
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Icon(Icons.calendar_today,
                                                  size: 16, color: AppTheme.mutedInk),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GIỜ ĐẶT BÀN *',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(fontSize: 11),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: _selectTime,
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppTheme.ink),
                                            color: AppTheme.paper,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedTime.format(context),
                                                style: const TextStyle(
                                                  fontFamily: 'Georgia',
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Icon(Icons.access_time,
                                                  size: 16, color: AppTheme.mutedInk),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Guest Count Field
                            Text(
                              'SỐ LƯỢNG KHÁCH *',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _selectedGuestCount,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Georgia',
                                color: AppTheme.ink,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                              items: List.generate(20, (index) => index + 1).map((count) {
                                return DropdownMenuItem<int>(
                                  value: count,
                                  child: Text('$count khách'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGuestCount = val);
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // Note Field
                            Text(
                              'GHI CHÚ (TÙY CHỌN)',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _noteCtrl,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                              decoration: const InputDecoration(
                                hintText: 'Ghi chú đặc biệt (vd: bàn góc khuất, em bé...)',
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _submitReservation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vermilion,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              child: const Text('GỬI YÊU CẦU ĐẶT BÀN'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: const Text('QUAY LẠI TRANG CHỦ'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(reservationViewModelProvider.notifier)
          .createReservation(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            dateTime: _combinedDateTime,
            guestCount: _selectedGuestCount,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
      if (success && mounted) {
        setState(() => _submittedSuccessfully = true);
      }
    }
  }
}

// ── Reservation Success Screen ────────────────────────────────────────────────

class _ReservationSuccessScreen extends StatelessWidget {
  const _ReservationSuccessScreen({
    required this.name,
    required this.phone,
    required this.dateTime,
    required this.guestCount,
    required this.note,
    required this.onDone,
  });

  final String name;
  final String phone;
  final DateTime dateTime;
  final int guestCount;
  final String? note;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(dateTime);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    return Scaffold(
      backgroundColor: AppTheme.eggshell,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: AppTheme.ink),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.done_all,
                      color: AppTheme.moss,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ĐÃ GỬI YÊU CẦU!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.moss,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Yêu cầu đặt bàn của bạn đã được tiếp nhận ở trạng thái Chờ xác nhận (Pending). Chúng tôi sẽ liên hệ sớm nhất để xác nhận!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.rice),
                    const SizedBox(height: 16),

                    // Booking details
                    _buildDetailRow('Khách hàng:', name),
                    const SizedBox(height: 8),
                    _buildDetailRow('Số điện thoại:', phone),
                    const SizedBox(height: 8),
                    _buildDetailRow('Ngày đặt bàn:', dateStr),
                    const SizedBox(height: 8),
                    _buildDetailRow('Giờ đặt bàn:', timeStr),
                    const SizedBox(height: 8),
                    _buildDetailRow('Số khách:', '$guestCount khách'),
                    if (note != null && note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('Ghi chú:', note!),
                    ],
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.rice),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        onDone();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        foregroundColor: AppTheme.paper,
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text(
                        'QUAY LẠI TRANG CHỦ',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        onDone();
                        context.go('/web/menu');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('XEM THỰC ĐƠN'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.mutedInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
        ),
      ],
    );
  }
}
