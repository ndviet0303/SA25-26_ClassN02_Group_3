enum SignupStep {
  gender,
  age,
  genre,
  profile,
  signup,
}

extension SignupStepExtension on SignupStep {
  String get displayName {
    switch (this) {
      case SignupStep.gender:
        return 'Gender';
      case SignupStep.age:
        return 'Age';
      case SignupStep.genre:
        return 'Genre';
      case SignupStep.profile:
        return 'Profile';
      case SignupStep.signup:
        return 'Sign Up';
    }
  }
  

  int get stepNumber => index + 1;


  static int get totalSteps => SignupStep.values.length;


  bool get isFirst => this == SignupStep.gender;
  

  bool get isLast => this == SignupStep.signup;
  

  bool get canSkip => this == SignupStep.genre;
  

  SignupStep? get next {
    final nextIndex = index + 1;
    if (nextIndex < SignupStep.values.length) {
      return SignupStep.values[nextIndex];
    }
    return null;
  }
  

  SignupStep? get previous {
    final previousIndex = index - 1;
    if (previousIndex >= 0) {
      return SignupStep.values[previousIndex];
    }
    return null;
  }
}
