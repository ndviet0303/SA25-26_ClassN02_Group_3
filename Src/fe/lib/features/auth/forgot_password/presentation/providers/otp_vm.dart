import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/features/auth/forgot_password/domain/repositories/auth_repository.dart' as domain;
import 'package:movie_fe/features/auth/forgot_password/providers/forgot_password_repository_provider.dart';

class OtpVmState {
  const OtpVmState({
    required this.length,
    required this.digits,
    required this.secondsLeft,
    this.isLoading = false,
    this.error,
    this.resetToken,
  });

  final int length;
  final List<String> digits;
  final int secondsLeft;
  final bool isLoading;
  final String? error;
  final String? resetToken;

  String get code => digits.join();
  bool get isFilled => digits.every((e) => e.isNotEmpty) && digits.length == length;

  OtpVmState copyWith({
    List<String>? digits,
    int? secondsLeft,
    bool? isLoading,
    String? error,
    String? resetToken,
  }) =>
      OtpVmState(
        length: length,
        digits: digits ?? this.digits,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        resetToken: resetToken ?? this.resetToken,
      );

  factory OtpVmState.initial(int length, {int seconds = 60}) =>
      OtpVmState(length: length, digits: List.filled(length, ''), secondsLeft: seconds);
}

final otpVmProvider = AutoDisposeNotifierProviderFamily<
    OtpVm,
    OtpVmState,
    ({String email, int length, int initialSeconds})
>(OtpVm.new);

class OtpVm extends AutoDisposeFamilyNotifier<
    OtpVmState, ({String email, int length, int initialSeconds})> {
  Timer? _timer;

  // Lưu tham số family để dùng trong resend/verify
  late ({String email, int length, int initialSeconds}) _params;

  @override
  OtpVmState build(({String email, int length, int initialSeconds}) arg) {
    _params = arg;
    ref.onDispose(() => _timer?.cancel());

    // 1) KHỞI TẠO state TRƯỚC
    state = OtpVmState.initial(arg.length, seconds: arg.initialSeconds);

    // 2) RỒI MỚI BẮT ĐẦU ĐẾM
    _startTicking();

    return state;
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.secondsLeft; // state đã có nên đọc OK
      if (left <= 0) {
        t.cancel();
      } else {
        state = state.copyWith(secondsLeft: left - 1);
      }
    });
  }

  void restartTimer([int seconds = 60]) {
    state = state.copyWith(secondsLeft: seconds);
    _startTicking();
  }

  void setDigit(int index, String v) {
    final d = [...state.digits];
    d[index] = v;
    state = state.copyWith(digits: d);
  }

  void paste(String text) {
    final s = text.replaceAll(RegExp(r'\D'), '');
    final d = List<String>.filled(state.length, '');
    for (var i = 0; i < state.length && i < s.length; i++) {
      d[i] = s[i];
    }
    state = state.copyWith(digits: d);
  }

  Future<void> resend() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(forgotPasswordRepositoryProvider);
      await repo.resendOtp(email: _params.email);
      state = state.copyWith(digits: List.filled(state.length, ''));
      restartTimer(60);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> verify() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(forgotPasswordRepositoryProvider);
      final token = await repo.verifyOtp(email: _params.email, code: state.code);
      state = state.copyWith(isLoading: false, resetToken: token);
      return token;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}
