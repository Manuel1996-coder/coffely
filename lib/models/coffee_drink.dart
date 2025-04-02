class CoffeeDrink {
  final String name;
  final double caffeineAmount;
  final DateTime timestamp;
  final String? note;

  const CoffeeDrink({
    required this.name,
    required this.caffeineAmount,
    required this.timestamp,
    this.note,
  });

  // Vordefinierte Kaffeegetränke
  static final espresso = CoffeeDrink(
    name: 'Espresso',
    caffeineAmount: 60,
    timestamp: DateTime(2023, 1, 1),
  );

  static final cappuccino = CoffeeDrink(
    name: 'Cappuccino',
    caffeineAmount: 60,
    timestamp: DateTime(2023, 1, 1),
  );

  static final latteMacchiato = CoffeeDrink(
    name: 'Latte Macchiato',
    caffeineAmount: 60,
    timestamp: DateTime(2023, 1, 1),
  );

  static final filterCoffee = CoffeeDrink(
    name: 'Filterkaffee',
    caffeineAmount: 160,
    timestamp: DateTime(2023, 1, 1),
  );
  
  static final instantCoffee = CoffeeDrink(
    name: 'Instant-Kaffee',
    caffeineAmount: 160,
    timestamp: DateTime(2023, 1, 1),
  );
  
  static final cremaCoffee = CoffeeDrink(
    name: 'Kaffee Crema',
    caffeineAmount: 120,
    timestamp: DateTime(2023, 1, 1),
  );

  CoffeeDrink copyWith({
    String? name,
    double? caffeineAmount,
    DateTime? timestamp,
    String? note,
  }) {
    return CoffeeDrink(
      name: name ?? this.name,
      caffeineAmount: caffeineAmount ?? this.caffeineAmount,
      timestamp: timestamp ?? this.timestamp,
      note: note,
    );
  }

  factory CoffeeDrink.fromJson(Map<String, dynamic> json) {
    return CoffeeDrink(
      name: json['name'] as String,
      caffeineAmount: json['caffeineAmount'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'caffeineAmount': caffeineAmount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
