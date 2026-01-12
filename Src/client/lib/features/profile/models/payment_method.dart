import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.brand,
    required this.last4,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String brand;
  final String last4;
  final bool isDefault;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'brand': brand,
        'last4': last4,
        'isDefault': isDefault,
      };

  PaymentMethod copyWith({
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id,
      label: label,
      brand: brand,
      last4: last4,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static const sampleMethods = <PaymentMethod>[
    PaymentMethod(
      id: 'pm_visa',
      label: 'Visa',
      brand: 'Visa',
      last4: '',
      isDefault: false,
    ),
  ];

  @override
  List<Object?> get props => [id, label, brand, last4, isDefault];
}


