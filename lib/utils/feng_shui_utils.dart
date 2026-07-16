class FengShuiElement {
  final String name;
  final String luckyColors;
  final String unluckyColors;

  const FengShuiElement({
    required this.name,
    required this.luckyColors,
    required this.unluckyColors,
  });
}

class FengShuiProfile {
  final int birthYear;
  final FengShuiElement element;

  FengShuiProfile({required this.birthYear, required this.element});

  String get aiDescription {
    return 'Người dùng sinh năm $birthYear (Mệnh ${element.name}). Ưu tiên gợi ý trang phục có các màu tương sinh/bản mệnh: ${element.luckyColors} để thu hút may mắn. Tuyệt đối tránh hoặc hạn chế tối đa các màu tương khắc: ${element.unluckyColors}.';
  }

  String get displayString => 'Mệnh ${element.name} (Hợp: ${element.luckyColors})';
}

class FengShuiUtils {
  static final Map<int, FengShuiElement> _elements = {
    1: const FengShuiElement(name: 'Kim', luckyColors: 'Trắng, Xám, Bạc, Vàng, Nâu đất', unluckyColors: 'Đỏ, Hồng, Tím, Cam'),
    2: const FengShuiElement(name: 'Thủy', luckyColors: 'Đen, Xanh dương, Trắng, Xám, Bạc', unluckyColors: 'Vàng, Nâu đất'),
    3: const FengShuiElement(name: 'Hỏa', luckyColors: 'Đỏ, Hồng, Tím, Cam, Xanh lá cây', unluckyColors: 'Đen, Xanh dương'),
    4: const FengShuiElement(name: 'Thổ', luckyColors: 'Vàng, Nâu đất, Đỏ, Hồng, Tím, Cam', unluckyColors: 'Xanh lá cây'),
    5: const FengShuiElement(name: 'Mộc', luckyColors: 'Xanh lá cây, Đen, Xanh dương', unluckyColors: 'Trắng, Xám, Bạc'),
  };

  static FengShuiProfile calculateFengShui(int year) {
    // 1. Calculate Can value
    final canMap = {0: 4, 1: 4, 2: 5, 3: 5, 4: 1, 5: 1, 6: 2, 7: 2, 8: 3, 9: 3};
    final can = canMap[year % 10]!;

    // 2. Calculate Chi value
    final chiMap = {0: 1, 1: 1, 2: 2, 3: 2, 4: 0, 5: 0, 6: 1, 7: 1, 8: 2, 9: 2, 10: 0, 11: 0};
    final chi = chiMap[year % 12]!;

    // 3. Calculate Mệnh value
    int menhValue = can + chi;
    if (menhValue > 5) menhValue -= 5;

    return FengShuiProfile(
      birthYear: year,
      element: _elements[menhValue]!,
    );
  }
}
