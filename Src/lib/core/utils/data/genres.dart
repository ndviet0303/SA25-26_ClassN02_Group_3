class GenresVi {
  static const List<Map<String, String>> all = [
    {"id": "620a22bae0fc277084dfd585", "name": "Âm Nhạc", "slug": "am-nhac", "imageUrl": "https://images.pexels.com/photos/167636/pexels-photo-167636.jpeg?w=800"},
    {"id": "620f84d291fa4af90ab6b3f4", "name": "Bí ẩn", "slug": "bi-an", "imageUrl": "https://images.pexels.com/photos/3945317/pexels-photo-3945317.jpeg?w=800"},
    {"id": "620a2253e0fc277084dfd339", "name": "Chiến Tranh", "slug": "chien-tranh", "imageUrl": "https://images.pexels.com/photos/5239790/pexels-photo-5239790.jpeg?w=800"},
    {"id": "620f3d2b91fa4af90ab697fe", "name": "Chính kịch", "slug": "chinh-kich", "imageUrl": "https://images.pexels.com/photos/2672095/pexels-photo-2672095.jpeg?w=800"},
    {"id": "620a222fe0fc277084dfd23d", "name": "Cổ Trang", "slug": "co-trang", "imageUrl": "https://images.pexels.com/photos/2115217/pexels-photo-2115217.jpeg?w=800"},
    {"id": "620e4c0b6ba8271c5eef05a8", "name": "Gia Đình", "slug": "gia-dinh", "imageUrl": "https://images.pexels.com/photos/1461974/pexels-photo-1461974.jpeg?w=800"},
    {"id": "620a221de0fc277084dfd1c1", "name": "Hài Hước", "slug": "hai-huoc", "imageUrl": "https://images.pexels.com/photos/1404819/pexels-photo-1404819.jpeg?w=800"},
    {"id": "620a21b2e0fc277084dfd0c5", "name": "Hành Động", "slug": "hanh-dong", "imageUrl": "https://images.pexels.com/photos/1276518/pexels-photo-1276518.jpeg?w=800"},
    {"id": "620a2249e0fc277084dfd2e5", "name": "Hình Sự", "slug": "hinh-su", "imageUrl": "https://images.pexels.com/photos/5699456/pexels-photo-5699456.jpeg?w=800"},
    {"id": "62121e821f1609c9d934585c", "name": "Học Đường", "slug": "hoc-duong", "imageUrl": "https://images.pexels.com/photos/7119705/pexels-photo-7119705.jpeg?w=800"},
    {"id": "620a229be0fc277084dfd4dd", "name": "Khoa Học", "slug": "khoa-hoc", "imageUrl": "https://images.pexels.com/photos/2280568/pexels-photo-2280568.jpeg?w=800"},
    {"id": "620a22ace0fc277084dfd531", "name": "Kinh Dị", "slug": "kinh-di", "imageUrl": "https://images.pexels.com/photos/4056531/pexels-photo-4056531.jpeg?w=800"},
    {"id": "6218eb66a2d0f024a9de48d4", "name": "Kinh Điển", "slug": "kinh-dien", "imageUrl": "https://images.pexels.com/photos/1162241/pexels-photo-1162241.jpeg?w=800"},
    {"id": "620a2293e0fc277084dfd489", "name": "Phiêu Lưu", "slug": "phieu-luu", "imageUrl": "https://images.pexels.com/photos/1486222/pexels-photo-1486222.jpeg?w=800"},
    {"id": "6242b89cc78eb57bbfe29f91", "name": "Phim 18+", "slug": "phim-18", "imageUrl": "https://images.pexels.com/photos/247204/pexels-photo-247204.jpeg?w=800"},
    {"id": "68f786a9f998955ed60add6c", "name": "Short Drama", "slug": "short-drama", "imageUrl": "https://images.pexels.com/photos/1612351/pexels-photo-1612351.jpeg?w=800"},
    {"id": "620e0e64d9648f114cde7728", "name": "Tài Liệu", "slug": "tai-lieu", "imageUrl": "https://images.pexels.com/photos/1162241/pexels-photo-1162241.jpeg?w=800"},
    {"id": "620a2238e0fc277084dfd291", "name": "Tâm Lý", "slug": "tam-ly", "imageUrl": "https://images.pexels.com/photos/21686569/pexels-photo-21686569.jpeg?w=800"},
    {"id": "620a22c8e0fc277084dfd5d9", "name": "Thần Thoại", "slug": "than-thoai", "imageUrl": "https://images.pexels.com/photos/1027013/pexels-photo-1027013.jpeg?w=800"},
    {"id": "620a225fe0fc277084dfd38d", "name": "Thể Thao", "slug": "the-thao", "imageUrl": "https://images.pexels.com/photos/47356/freerider-skiing-ski-sports-47356.jpeg?w=800"},
    {"id": "620a220de0fc277084dfd16d", "name": "Tình Cảm", "slug": "tinh-cam", "imageUrl": "https://images.pexels.com/photos/169198/pexels-photo-169198.jpeg?w=800"},
    {"id": "620a2282e0fc277084dfd435", "name": "Viễn Tưởng", "slug": "vien-tuong", "imageUrl": "https://images.pexels.com/photos/163236/luxury-gold-silver-choosing-163236.jpeg?w=800"},
    {"id": "620a2279e0fc277084dfd3e1", "name": "Võ Thuật", "slug": "vo-thuat", "imageUrl": "https://images.pexels.com/photos/1789657/pexels-photo-1789657.jpeg?w=800"},
  ];

  static List<Map<String, String>> fromNames(List<String> names) {
    if (names.isEmpty) return all;
    final lowerToEntry = {
      for (final e in all) (e['name'] ?? '').toLowerCase(): e,
      for (final e in all) (e['slug'] ?? '').toLowerCase(): e,
    };
    final result = <Map<String, String>>[];
    for (final n in names) {
      final key = n.toLowerCase();
      final e = lowerToEntry[key];
      if (e != null) result.add(e);
    }
    return result.isEmpty ? all : result;
  }
}


