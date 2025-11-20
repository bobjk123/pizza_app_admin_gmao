class MacrosEntity {
  int calories;
  int proteins;
  int fat;
  int carbs;

  MacrosEntity({
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbs,
  });

  Map<String, Object?> toDocument() {
    return {
      'calories': calories,
      'proteins': proteins,
      'fat': fat,
      'carbs': carbs,
    };
  }

  static MacrosEntity fromDocument(Map<String, dynamic> doc) {
    final calories = (doc['calories'] is int)
        ? doc['calories'] as int
        : int.tryParse('${doc['calories']}') ?? 0;
    final proteins = (doc['proteins'] is int)
        ? doc['proteins'] as int
        : int.tryParse('${doc['proteins']}') ?? 0;
    final fat = (doc['fat'] is int)
        ? doc['fat'] as int
        : int.tryParse('${doc['fat']}') ?? 0;
    final carbs = (doc['carbs'] is int)
        ? doc['carbs'] as int
        : int.tryParse('${doc['carbs']}') ?? 0;

    return MacrosEntity(
      calories: calories,
      proteins: proteins,
      fat: fat,
      carbs: carbs,
    );
  }
}
