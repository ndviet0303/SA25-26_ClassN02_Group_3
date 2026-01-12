import 'package:flutter/material.dart';
import '../../app_export.dart';

class ValidationUtils {
  static String? validateUsername(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.username.required;
    }
    if (value!.trim().length < 3) {
      return t.validation.username.minLength;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return t.validation.username.invalidChars;
    }
    return null;
  }

  static String? validateEmail(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.email.required;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!.trim())) {
      return t.validation.email.invalid;
    }
    return null;
  }


  static String? validateEmail2(String? value, BuildContext context) {
    final t = context.i18n;

    if (value
        ?.trim()
        .isEmpty ?? true) {
      return t.validation.username.required; // fallback required chung
    }

    final input = value!.trim();

    if (input.contains('@')) {
      // check email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(input)) {
        return t.validation.email.invalid;
      }
    }
    // nếu không có @ thì mặc định là username -> chỉ required, ko check gì thêm

    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.password.required;
    }
    if (value!.trim().length < 8) {
      return t.validation.password.minLength;
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value.trim())) {
      return t.validation.password.complexity;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.password.confirmRequired;
    }
    if (value!.trim() != password.trim()) {
      return t.validation.password.mismatch;
    }
    return null;
  }

  static String? validateFullName(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.name.required;
    }
    if (value!.trim().length < 2) {
      return t.validation.name.minLength;
    }
    return null;
  }

  static String? validatePhone(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.phone.required;
    }
    if (value!.trim().length < 10) {
      return t.validation.phone.minLength;
    }
    return null;
  }

  static String? validateDOB(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.dateOfBirth.required;
    }
    return null;
  }

  static String? validateCountry(String? value, BuildContext context) {
    final t = context.i18n;
    if (value?.trim().isEmpty ?? true) {
      return t.validation.country.required;
    }
    return null;
  }
}
