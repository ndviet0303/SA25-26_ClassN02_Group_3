class FormatUtils {
  const FormatUtils._();

  static String formatCountShort(int? count) {
    if (count == null) return '—';
    if (count >= 1000000) return '${count ~/ 1000000}M+';
    if (count >= 1000) {
      return _trimTrailingZero((count / 1000).toStringAsFixed(1)) + 'K+';
    }
    return count.toString();
  }

  static String formatCount(int count) {
    if (count >= 1000000) {
      final v = (count / 1000000).toStringAsFixed(1);
      return _trimTrailingZero(v) + 'M';
    }
    if (count >= 1000) {
      final v = (count / 1000).toStringAsFixed(1);
      return _trimTrailingZero(v) + 'k';
    }
    return count.toString();
  }

  static String formatDuration(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    final s = raw.toLowerCase();
    final hMatch = RegExp(r"(\d+)\s*h").firstMatch(s);
    final mMatch = RegExp(r"(\d+)\s*m|\b(\d+)\s*min|\b(\d+)\s*phút").firstMatch(s);
    int h = 0;
    int m = 0;
    if (hMatch != null) h = int.tryParse(hMatch.group(1)!) ?? 0;
    if (mMatch != null) {
      final g = mMatch.group(1) ?? mMatch.group(2) ?? mMatch.group(3);
      m = int.tryParse(g!) ?? 0;
    }
    if (h == 0 && m == 0) {
      final digits = String.fromCharCodes(s.codeUnits.where((c) => c >= 48 && c <= 57));
      final total = int.tryParse(digits) ?? 0;
      h = total ~/ 60;
      m = total % 60;
    }
    if (h <= 0) return '${m}p';
    if (m <= 0) return '${h}h';
    return '${h}h ${m}p';
  }

  static String formatWatched(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    final s = raw.toLowerCase().trim();
    final unitMatch = RegExp(r"(\d+[\.,]?\d*)\s*([kmb])").firstMatch(s);
    num n;
    if (unitMatch != null) {
      final numStr = unitMatch.group(1)!.replaceAll(',', '.');
      final unit = unitMatch.group(2);
      final v = double.tryParse(numStr) ?? 0.0;
      switch (unit) {
        case 'k':
          n = (v * 1000).floor();
          break;
        case 'm':
          n = (v * 1000000).floor();
          break;
        case 'b':
          n = (v * 1000000000).floor();
          break;
        default:
          n = v.floor();
      }
    } else {
      final digits = String.fromCharCodes(s.codeUnits.where((c) => c >= 48 && c <= 57));
      if (digits.isEmpty) return raw.trim();
      n = int.tryParse(digits) ?? 0;
    }
    final ni = n.toInt();
    if (ni >= 1000000) return '${ni ~/ 1000000}M+';
    if (ni >= 1000) return _trimTrailingZero((ni / 1000).toStringAsFixed(1)) + 'K+';
    return ni.toString();
  }

  static String _trimTrailingZero(String s) {
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r"\.0$"), '');
    }
    return s;
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = diff.inDays ~/ 7;
    if (weeks < 5) return '$weeks weeks ago';
    final months = diff.inDays ~/ 30;
    if (months < 12) return '$months months ago';
    final years = diff.inDays ~/ 365;
    return '$years years ago';
  }
}


