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

class DailyFengShui {
  final String can;
  final String chi;
  final FengShuiElement element;
  final DateTime date;

  DailyFengShui({required this.can, required this.chi, required this.element, required this.date});

  String get name => '$can $chi';
}

class DailyAdvice {
  final DailyFengShui dailyFengShui;
  final FengShuiProfile userProfile;
  final String relation;
  final String uiAdvice;
  final String aiContext;

  DailyAdvice({
    required this.dailyFengShui,
    required this.userProfile,
    required this.relation,
    required this.uiAdvice,
    required this.aiContext,
  });
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

  static DailyFengShui getDailyFengShui(DateTime date) {
    // Anchor: 16/07/2026 is Tân Mão (Tân=7, Mão=3)
    final anchorDate = DateTime(2026, 7, 16);
    final daysDiff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(anchorDate.year, anchorDate.month, anchorDate.day))
        .inDays;

    final cans = ['Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu', 'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý'];
    final chis = ['Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ', 'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi'];

    int canIndex = (7 + daysDiff) % 10;
    if (canIndex < 0) canIndex += 10;

    int chiIndex = (3 + daysDiff) % 12;
    if (chiIndex < 0) chiIndex += 12;

    final canValues = {0: 1, 1: 1, 2: 2, 3: 2, 4: 3, 5: 3, 6: 4, 7: 4, 8: 5, 9: 5};
    final chiValues = {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2, 6: 0, 7: 0, 8: 1, 9: 1, 10: 2, 11: 2};

    int menhValue = canValues[canIndex]! + chiValues[chiIndex]!;
    if (menhValue > 5) menhValue -= 5;

    return DailyFengShui(
      can: cans[canIndex],
      chi: chis[chiIndex],
      element: _elements[menhValue]!,
      date: date,
    );
  }

  static DailyAdvice getDailyAdvice(FengShuiProfile userProfile, DateTime date) {
    final daily = getDailyFengShui(date);
    
    final userEl = userProfile.element.name;
    final dayEl = daily.element.name;
    
    String relation = '';
    String uiAdvice = '';
    String aiContext = '';
    
    // Logic Ngũ hành: Kim=1, Thủy=2, Hỏa=3, Thổ=4, Mộc=5
    // Sinh: Kim->Thủy, Thủy->Mộc, Mộc->Hỏa, Hỏa->Thổ, Thổ->Kim
    // Khắc: Kim->Mộc, Mộc->Thổ, Thổ->Thủy, Thủy->Hỏa, Hỏa->Kim
    
    bool isSinh(String a, String b) {
      return (a == 'Kim' && b == 'Thủy') || (a == 'Thủy' && b == 'Mộc') ||
             (a == 'Mộc' && b == 'Hỏa') || (a == 'Hỏa' && b == 'Thổ') ||
             (a == 'Thổ' && b == 'Kim');
    }
    
    bool isKhac(String a, String b) {
      return (a == 'Kim' && b == 'Mộc') || (a == 'Mộc' && b == 'Thổ') ||
             (a == 'Thổ' && b == 'Thủy') || (a == 'Thủy' && b == 'Hỏa') ||
             (a == 'Hỏa' && b == 'Kim');
    }

    if (userEl == dayEl) {
      relation = 'Bình Hòa';
      uiAdvice = 'Ngày năng lượng cân bằng. Chọn màu bản mệnh ${userProfile.element.luckyColors} để tự tin tỏa sáng.';
      aiContext = 'Hôm nay là ngày ${daily.name} (Mệnh $dayEl). Người dùng mệnh $userEl. Ngày bình hòa. AI PHẢI ưu tiên chọn trang phục có màu: ${userProfile.element.luckyColors}.';
    } else if (isSinh(dayEl, userEl)) {
      relation = 'Đại Cát (Ngày sinh Mệnh)';
      uiAdvice = 'Ngày rất tốt! Ngày $dayEl tương sinh cho mệnh $userEl của bạn. Mặc màu ${daily.element.luckyColors} để nhận tài lộc.';
      aiContext = 'Hôm nay là ngày ${daily.name} (Mệnh $dayEl). Mệnh ngày TƯƠNG SINH cho người dùng (mệnh $userEl). AI PHẢI ưu tiên màu của ngày: ${daily.element.luckyColors} kết hợp màu bản mệnh để thu hút vượng khí tối đa.';
    } else if (isSinh(userEl, dayEl)) {
      relation = 'Sinh Xuất (Hao Tổn)';
      uiAdvice = 'Ngày sinh xuất, năng lượng của bạn dễ bị hao hụt. Hãy bù đắp bằng màu bản mệnh: ${userProfile.element.luckyColors}.';
      aiContext = 'Hôm nay là ngày ${daily.name} (Mệnh $dayEl). Người dùng (mệnh $userEl) bị Sinh Xuất, tiêu hao năng lượng. AI PHẢI ưu tiên TỐI ĐA các màu bản mệnh: ${userProfile.element.luckyColors} để bù đắp, tránh các màu kỵ.';
    } else if (isKhac(dayEl, userEl)) {
      relation = 'Xung Khắc (Ngày khắc Mệnh)';
      uiAdvice = 'Ngày $dayEl khắc mệnh $userEl. Mặc ngay màu Hóa Giải (Tương sinh với cả 2) hoặc màu bản mệnh để bảo vệ trường năng lượng.';
      aiContext = 'Hôm nay là ngày ${daily.name} (Mệnh $dayEl). Ngày XUNG KHẮC với người dùng (mệnh $userEl). AI TUYỆT ĐỐI tránh màu của ngày (${daily.element.luckyColors}). HÃY dùng màu bản mệnh của người dùng (${userProfile.element.luckyColors}) để hóa giải sát khí.';
    } else if (isKhac(userEl, dayEl)) {
      relation = 'Khắc Xuất (Chế Ngự)';
      uiAdvice = 'Bạn khắc chế được trường năng lượng ngày. Mặc màu bản mệnh ${userProfile.element.luckyColors} để làm chủ tình thế.';
      aiContext = 'Hôm nay là ngày ${daily.name} (Mệnh $dayEl). Người dùng (mệnh $userEl) Khắc Xuất ngày. Khuyên mặc màu bản mệnh ${userProfile.element.luckyColors} để phát huy uy quyền và tự tin.';
    }

    return DailyAdvice(
      dailyFengShui: daily,
      userProfile: userProfile,
      relation: relation,
      uiAdvice: uiAdvice,
      aiContext: aiContext,
    );
  }
}
