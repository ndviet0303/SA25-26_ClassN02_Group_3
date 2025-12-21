import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/providers/otp_vm.dart';

mixin OtpInputController<T extends StatefulWidget> on State<T> {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  int currentIndex = 0;
  final Set<int> _muted = <int>{};

  int get length;
  OtpVm get otpController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupFocusListeners();
    // _hideSoftKeyboard(); // Không ẩn bàn phím
    _requestInitialFocus();
  }

  void _initializeControllers() {
    controllers = List.generate(length, (_) => TextEditingController());
    focusNodes = List.generate(length, (_) => FocusNode());
  }

  void _setupFocusListeners() {
    for (var i = 0; i < focusNodes.length; i++) {
      final index = i;
      focusNodes[index].addListener(() {
        if (focusNodes[index].hasFocus) {
          setState(() => currentIndex = index);
          // Không ẩn bàn phím nữa vì dùng bàn phím hệ thống
        }
      });
    }
  }

  void _hideSoftKeyboard() {
    // Không cần ẩn bàn phím nữa
  }

  void _requestInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNodes.first.requestFocus(),
    );
  }

  void setTextSilently(int index, String text) {
    _muted.add(index);
    controllers[index].text = text;
    controllers[index].selection = TextSelection.collapsed(
      offset: text.length,
    );
    _muted.remove(index);
  }

  void commitInput(String raw, int index) {
    if (_muted.contains(index)) return;

    final sanitized = raw.replaceAll(RegExp(r'\D'), '');
    final lastIndex = length - 1;

    if (sanitized.isEmpty) {
      _handleEmptyInput(index);
      return;
    }

    if (sanitized.length > 1) {
      _handleMultipleCharacters(sanitized, index, lastIndex);
      return;
    }

    _handleSingleCharacter(sanitized, index, lastIndex);
  }

  void _handleEmptyInput(int index) {
    setTextSilently(index, '');
    otpController.setDigit(index, '');
    
    // Nếu xóa ở ô hiện tại, luôn chuyển focus về ô trước (nếu có)
    if (index > 0) {
      setState(() => currentIndex = index - 1);
      focusNodes[index - 1].requestFocus();
    }
  }

  void _handleMultipleCharacters(String sanitized, int index, int lastIndex) {
    if (index == lastIndex) {
      final lastChar = sanitized[sanitized.length - 1];
      setTextSilently(index, lastChar);
      otpController.setDigit(index, lastChar);
      

      return;
    }

    var position = index;
    for (var k = 0; k < sanitized.length && position <= lastIndex; k++, position++) {
      final char = sanitized[k];
      setTextSilently(position, char);
      otpController.setDigit(position, char);
    }

    final lastFilled = (index + sanitized.length - 1).clamp(0, lastIndex);
    setState(() => currentIndex = lastFilled);
    focusNodes[lastFilled].requestFocus();
    

  }

  void _handleSingleCharacter(String sanitized, int index, int lastIndex) {
    setTextSilently(index, sanitized);
    otpController.setDigit(index, sanitized);
    
    // Auto-focus ô tiếp theo nếu có
    if (index < lastIndex) {
      setState(() => currentIndex = index + 1);
      focusNodes[index + 1].requestFocus();
    } else {
      // Giữ focus ở ô cuối
    }
  }

  bool _isAllFieldsFilled() {
    return controllers.every((controller) => controller.text.isNotEmpty);
  }

  void onTextFromKeyboard(String char) {
    // Điền số vào ô hiện tại & nhảy focus
    if (controllers[currentIndex].text != char) {
      controllers[currentIndex].text = char;
      controllers[currentIndex].selection = const TextSelection.collapsed(offset: 1);
      otpController.setDigit(currentIndex, char);
    }
    if (currentIndex < length - 1) {
      setState(() => currentIndex = currentIndex + 1);
      focusNodes[currentIndex].requestFocus();
    }
  }

  void onBackspaceFromKeyboard() {
    if (controllers[currentIndex].text.isNotEmpty) {
      controllers[currentIndex].clear();
      otpController.setDigit(currentIndex, '');
      return;
    }
    if (currentIndex > 0) {
      setState(() => currentIndex = currentIndex - 1);
      controllers[currentIndex].clear();
      focusNodes[currentIndex].requestFocus();
      otpController.setDigit(currentIndex, '');
    }
  }

  bool handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (controllers[index].text.isEmpty && index > 0) {
        // Nếu ô hiện tại rỗng, chỉ focus về ô trước (không xóa)
        setState(() => currentIndex = index - 1);
        focusNodes[index - 1].requestFocus();
        return true;
      }
    }
    return false;
  }

  void updateFromState(List<String> digits) {
    for (var i = 0; i < length; i++) {
      final text = digits[i];
      if (controllers[i].text != text) {
        setTextSilently(i, text);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
