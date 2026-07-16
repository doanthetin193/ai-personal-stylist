class BodyProfile {
  final int heightCm;
  final int weightKg;
  
  BodyProfile({required this.heightCm, required this.weightKg});

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get shapeDescription {
    if (bmi < 18.5) return 'Dáng gầy mảnh khảnh';
    if (bmi < 25) return 'Dáng cân đối';
    return 'Dáng người đậm đà';
  }

  String get aiDescription {
    return 'Chiều cao: ${heightCm}cm, Cân nặng: ${weightKg}kg. Đặc điểm cơ thể: $shapeDescription. Hãy ưu tiên các form dáng tôn lên ưu điểm và che khuyết điểm cho vóc dáng này.';
  }

  String get displayString => 'Cao ${heightCm}cm, Nặng ${weightKg}kg (BMI: ${bmi.toStringAsFixed(1)} - $shapeDescription)';
}
