import 'package:flutter/material.dart';

sealed class UIState<T> {
  const UIState();
  
  bool get isIdle => this is Idle<T>;
  bool get isLoading => this is Loading<T>;
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get data => switch (this) {
    Success(data: final d) => d,
    _ => null,
  };
  
  String? get errorMessage => switch (this) {
    Error(message: final msg) => msg,
    _ => null,
  };
}

class Idle<T> extends UIState<T> {
  const Idle();
}

class Loading<T> extends UIState<T> {
  const Loading();
}

class Success<T> extends UIState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends UIState<T> {
  final String message;
  const Error(this.message);
}

extension UIStateExtension<T> on UIState<T> {
  Widget when({
    required Widget Function() idle,
    required Widget Function() loading,
    required Widget Function(T data) success,
    required Widget Function(String error) error,
  }) {
    return switch (this) {
      Idle() => idle(),
      Loading() => loading(),
      Success(data: final d) => success(d),
      Error(message: final msg) => error(msg),
    };
  }
  
  Widget whenOrNull({
    Widget Function()? idle,
    Widget Function()? loading,
    Widget Function(T data)? success,
    Widget Function(String error)? error,
    required Widget Function() orElse,
  }) {
    return switch (this) {
      Idle() => idle?.call() ?? orElse(),
      Loading() => loading?.call() ?? orElse(),
      Success(data: final d) => success?.call(d) ?? orElse(),
      Error(message: final msg) => error?.call(msg) ?? orElse(),
    };
  }
}