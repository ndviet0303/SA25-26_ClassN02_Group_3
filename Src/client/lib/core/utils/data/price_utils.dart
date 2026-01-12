import 'package:movie_fe/i18n/translations.g.dart';
import '../../models/movie_item.dart';

class PriceUtils {
  PriceUtils._();

  /// Lấy giá trị price từ dynamic (có thể là Map hoặc num)
  /// Ưu tiên USD cho sorting/filtering
  static double? getPriceValue(dynamic price) {
    if (price == null) return null;
    if (price is num) return price.toDouble();
    if (price is Map) {
      final usd = price['usd'] as num?;
      if (usd != null) return usd.toDouble();
      final vnd = price['vnd'] as num?;
      if (vnd != null) return vnd.toDouble();
    }
    return null;
  }

  /// Format số lớn thành format ngắn gọn (K, M)
  static String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  /// Format price string theo locale (VND cho tiếng Việt, USD cho tiếng Anh)
  static String formatPrice(MovieItem movie) {
    final locale = LocaleSettings.currentLocale;
    final isVietnamese = locale == AppLocale.vi;

    if (movie.priceData != null) {
      if (isVietnamese) {
        final vnd = movie.priceData!['vnd'] as num?;
        if (vnd != null) {
          return '${_formatNumber(vnd.toDouble())} ₫';
        }
        // Nếu không có VND và locale là tiếng Việt, không hiển thị giá
        return '';
      } else {
        final usd = movie.priceData!['usd'] as num?;
        if (usd != null) {
          return '\$${usd.toStringAsFixed(2)}';
        }
        // Nếu không có USD và locale là tiếng Anh, không hiển thị giá
        return '';
      }
    } else if (movie.price != null) {
      // Nếu không có priceData, chỉ hiển thị USD cho tiếng Anh
      if (isVietnamese) {
        return '';
      }
      return '\$${movie.price!.toStringAsFixed(2)}';
    }

    return '';
  }

  /// Format price string cho button (có prefix "Buy")
  static String formatPriceForButton(MovieItem movie) {
    final locale = LocaleSettings.currentLocale;
    final priceText = formatPrice(movie);
    
    if (priceText.isEmpty) return 'Buy';
    
    if (locale != AppLocale.vi && priceText.startsWith('\$')) {
      return 'Buy USD $priceText';
    }
    
    return 'Buy $priceText';
  }

  /// Kiểm tra xem movie có free không (price = 0 hoặc không có price)
  static bool isFree(MovieItem movie) {
    final locale = LocaleSettings.currentLocale;
    final isVietnamese = locale == AppLocale.vi;

    if (movie.priceData != null) {
      if (isVietnamese) {
        final vnd = movie.priceData!['vnd'] as num?;
        return vnd == null || vnd.toDouble() == 0.0;
      } else {
        final usd = movie.priceData!['usd'] as num?;
        return usd == null || usd.toDouble() == 0.0;
      }
    }
    return movie.price == null || movie.price == 0.0;
  }
}

