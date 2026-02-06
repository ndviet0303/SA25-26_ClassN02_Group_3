class CountriesVi {
  static const List<Map<String, String>> all = [
    {"id": "1", "name": "Việt Nam", "slug": "viet-nam", "imageUrl": "https://images.pexels.com/photos/1161515/pexels-photo-1161515.jpeg?w=800"},
    {"id": "2", "name": "Hàn Quốc", "slug": "han-quoc", "imageUrl": "https://images.pexels.com/photos/2376696/pexels-photo-2376696.jpeg?w=800"},
    {"id": "3", "name": "Trung Quốc", "slug": "trung-quoc", "imageUrl": "https://images.pexels.com/photos/2187662/pexels-photo-2187662.jpeg?w=800"},
    {"id": "4", "name": "Thái Lan", "slug": "thai-lan", "imageUrl": "https://images.pexels.com/photos/1031659/pexels-photo-1031659.jpeg?w=800"},
    {"id": "5", "name": "Nhật Bản", "slug": "nhat-ban", "imageUrl": "https://images.pexels.com/photos/1108701/pexels-photo-1108701.jpeg?w=800"},
    {"id": "6", "name": "Âu Mỹ", "slug": "au-my", "imageUrl": "https://images.pexels.com/photos/1038916/pexels-photo-1038916.jpeg?w=800"},
    {"id": "7", "name": "Đài Loan", "slug": "dai-loan", "imageUrl": "https://images.pexels.com/photos/2187665/pexels-photo-2187665.jpeg?w=800"},
    {"id": "8", "name": "Hồng Kông", "slug": "hong-kong", "imageUrl": "https://images.pexels.com/photos/1337144/pexels-photo-1337144.jpeg?w=800"},
    {"id": "9", "name": "Ấn Độ", "slug": "an-do", "imageUrl": "https://images.pexels.com/photos/1007426/pexels-photo-1007426.jpeg?w=800"},
    {"id": "10", "name": "Anh", "slug": "anh", "imageUrl": "https://images.pexels.com/photos/77171/pexels-photo-77171.jpeg?w=800"},
    {"id": "11", "name": "Pháp", "slug": "phap", "imageUrl": "https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg?w=800"},
    {"id": "12", "name": "Canada", "slug": "canada", "imageUrl": "https://images.pexels.com/photos/210012/pexels-photo-210012.jpeg?w=800"},
    {"id": "13", "name": "Quốc Gia Khác", "slug": "quoc-gia-khac", "imageUrl": "https://images.pexels.com/photos/220768/pexels-photo-220768.jpeg?w=800"},
    {"id": "14", "name": "Đức", "slug": "duc", "imageUrl": "https://images.pexels.com/photos/109629/pexels-photo-109629.jpeg?w=800"},
    {"id": "15", "name": "Tây Ban Nha", "slug": "tay-ban-nha", "imageUrl": "https://images.pexels.com/photos/819764/pexels-photo-819764.jpeg?w=800"},
    {"id": "16", "name": "Thổ Nhĩ Kỳ", "slug": "tho-nhi-ky", "imageUrl": "https://images.pexels.com/photos/3279691/pexels-photo-3279691.jpeg?w=800"},
    {"id": "17", "name": "Indonesia", "slug": "indonesia", "imageUrl": "https://images.pexels.com/photos/2166559/pexels-photo-2166559.jpeg?w=800"},
    {"id": "18", "name": "Ba Lan", "slug": "ba-lan", "imageUrl": "https://images.pexels.com/photos/2346216/pexels-photo-2346216.jpeg?w=800"},
    {"id": "19", "name": "Úc", "slug": "uc", "imageUrl": "https://images.pexels.com/photos/2193300/pexels-photo-2193300.jpeg?w=800"},
    {"id": "20", "name": "Philippines", "slug": "philippines", "imageUrl": "https://images.pexels.com/photos/1174732/pexels-photo-1174732.jpeg?w=800"},
  ];

  static Map<String, String> findBySlug(String slug) {
    return all.firstWhere(
      (c) => c['slug'] == slug,
      orElse: () => {"name": slug, "slug": slug, "imageUrl": "https://images.pexels.com/photos/220768/pexels-photo-220768.jpeg?w=800"},
    );
  }
}
