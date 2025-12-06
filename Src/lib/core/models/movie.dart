import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String name;
  final String originName;
  final String slug;
  final String originalId;
  final String type;
  final String status;
  final String? content;
  final String? notify;
  final String? showtimes;
  final String? trailerUrl;
  final String? posterUrl;
  final String? thumbUrl;
  final String? quality;
  final String? time;
  final String? lang;
  final int? year;
  final int? view;
  final String? episodeCurrent;
  final String? episodeTotal;
  final bool? chieurap;
  final bool? subDocquyen;
  final bool? isCopyright;
  
  // Nested objects
  final List<Map<String, dynamic>>? country;
  final List<Map<String, dynamic>>? category;
  final List<String>? director;
  final List<String>? actor;
  final List<String>? alternativeNames;
  final Map<String, dynamic>? tmdb;
  final Map<String, dynamic>? imdb;
  final Map<String, dynamic>? price;
  final List<Map<String, dynamic>>? episodes;
  
  // Timestamps
  final DateTime? originalCreatedAt;
  final DateTime? originalModifiedAt;
  final Map<String, dynamic>? createdAt;
  final Map<String, dynamic>? updatedAt;

  Movie({
    required this.id,
    required this.name,
    required this.originName,
    required this.slug,
    required this.originalId,
    required this.type,
    required this.status,
    this.content,
    this.notify,
    this.showtimes,
    this.trailerUrl,
    this.posterUrl,
    this.thumbUrl,
    this.quality,
    this.time,
    this.lang,
    this.year,
    this.view,
    this.episodeCurrent,
    this.episodeTotal,
    this.chieurap,
    this.subDocquyen,
    this.isCopyright,
    this.country,
    this.category,
    this.director,
    this.actor,
    this.alternativeNames,
    this.tmdb,
    this.imdb,
    this.price,
    this.episodes,
    this.originalCreatedAt,
    this.originalModifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Movie.fromMap(Map<String, dynamic> map, {String? id}) {
    // Parse Map safely (handle Timestamp and other types)
    Map<String, dynamic>? _safeParseMap(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) {
        return {
          '_seconds': value.seconds,
          '_nanoseconds': value.nanoseconds,
        };
      }
      if (value is Map) {
        try {
          return Map<String, dynamic>.from(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Parse DateTime từ String hoặc Timestamp
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      // Handle Firestore timestamp map format
      if (value is Map) {
        final seconds = value['_seconds'] ?? value['seconds'];
        if (seconds != null) {
          final nanoseconds = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds as num).toInt() * 1000 + ((nanoseconds as num).toInt() ~/ 1000000),
          );
        }
      }
      return null;
    }

    // Parse List<String> từ List
    List<String>? parseStringList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      return null;
    }

    // Parse List<Map> từ List
    List<Map<String, dynamic>>? parseMapList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return null;
    }

    return Movie(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      originName: map['originName']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      originalId: map['originalId']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      content: map['content']?.toString(),
      notify: map['notify']?.toString(),
      showtimes: map['showtimes']?.toString(),
      trailerUrl: map['trailerUrl']?.toString(),
      posterUrl: map['posterUrl']?.toString(),
      thumbUrl: map['thumbUrl']?.toString(),
      quality: map['quality']?.toString(),
      time: map['time']?.toString(),
      lang: map['lang']?.toString(),
      year: map['year'] is int ? map['year'] : (map['year'] as num?)?.toInt(),
      view: map['view'] is int ? map['view'] : (map['view'] as num?)?.toInt(),
      episodeCurrent: map['episodeCurrent']?.toString(),
      episodeTotal: map['episodeTotal']?.toString(),
      chieurap: map['chieurap'] as bool?,
      subDocquyen: map['subDocquyen'] as bool?,
      isCopyright: map['isCopyright'] as bool?,
      country: parseMapList(map['country']),
      category: parseMapList(map['category']),
      director: parseStringList(map['director']),
      actor: parseStringList(map['actor']),
      alternativeNames: parseStringList(map['alternativeNames']),
      tmdb: _safeParseMap(map['tmdb']),
      imdb: _safeParseMap(map['imdb']),
      price: _safeParseMap(map['price']),
      episodes: parseMapList(map['episodes']),
      originalCreatedAt: parseDateTime(map['originalCreatedAt']),
      originalModifiedAt: parseDateTime(map['originalModifiedAt']),
      createdAt: _safeParseMap(map['createdAt']),
      updatedAt: _safeParseMap(map['updatedAt']),
    );
  }

  factory Movie.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'originName': originName,
      'slug': slug,
      'originalId': originalId,
      'type': type,
      'status': status,
      'content': content,
      'notify': notify,
      'showtimes': showtimes,
      'trailerUrl': trailerUrl,
      'posterUrl': posterUrl,
      'thumbUrl': thumbUrl,
      'quality': quality,
      'time': time,
      'lang': lang,
      'year': year,
      'view': view,
      'episodeCurrent': episodeCurrent,
      'episodeTotal': episodeTotal,
      'chieurap': chieurap,
      'subDocquyen': subDocquyen,
      'isCopyright': isCopyright,
      'country': country,
      'category': category,
      'director': director,
      'actor': actor,
      'alternativeNames': alternativeNames,
      'tmdb': tmdb,
      'imdb': imdb,
      'price': price,
      'episodes': episodes,
      'originalCreatedAt': originalCreatedAt?.toIso8601String(),
      'originalModifiedAt': originalModifiedAt?.toIso8601String(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper getters để lấy dữ liệu dễ dàng
  String get imageUrl => posterUrl ?? thumbUrl ?? '';
  
  double? get rating {
    if (tmdb != null && tmdb!['vote_average'] != null) {
      return (tmdb!['vote_average'] as num).toDouble() / 2.0;
    }
    if (imdb != null && imdb!['vote_average'] != null) {
      return (imdb!['vote_average'] as num).toDouble() / 2.0;
    }
    return null;
  }
  
  int? get ratingCount {
    if (tmdb != null && tmdb!['vote_count'] != null) {
      return tmdb!['vote_count'] as int?;
    }
    if (imdb != null && imdb!['vote_count'] != null) {
      return imdb!['vote_count'] as int?;
    }
    return null;
  }
  
  double? get priceUsd {
    if (price != null && price!['usd'] != null) {
      return (price!['usd'] as num).toDouble();
    }
    return null;
  }
  
  List<String> get genres {
    if (category == null) return [];
    return category!.map((e) => e['name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
  }
  
  String get directorString {
    if (director == null || director!.isEmpty) return '';
    return director!.where((e) => e.isNotEmpty).join(', ');
  }
  
  String get viewsString {
    if (view == null) return '0';
    if (view! >= 1000000) {
      return '${(view! / 1000000).toStringAsFixed(1)}M+';
    }
    if (view! >= 1000) {
      return '${(view! / 1000).toStringAsFixed(1)}K+';
    }
    return view.toString();
  }

  String get size {
    if (quality == null || quality!.isEmpty) return 'Unknown';
    if (quality!.contains('1080') || quality!.contains('4K')) {
      return '5.0 GB';
    }
    if (quality!.contains('720')) {
      return '3.0 GB';
    }
    return '2.0 GB';
  }

  String get description {
    if (content == null || content!.isEmpty) return 'No description available.';
    if (content!.length > 200) {
      return '${content!.substring(0, 200)}...';
    }
    // Remove HTML tags if any
    return content!.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  String get metadata {
    final ratingValue = rating ?? 0.0;
    return '⭐ ${ratingValue.toStringAsFixed(1)} / 5 • ${time ?? "Unknown"} • $size • $viewsString';
  }

  String get title => name.isNotEmpty ? name : originName;

  double? get priceValue {
    if (priceUsd != null) return priceUsd;
    final priceMap = price;
    if (priceMap != null && priceMap['vnd'] != null) {
      return (priceMap['vnd'] as num).toDouble() / 23000;
    }
    return null;
  }

  String? get franchiseId {
    if (slug.isEmpty) return null;
    final parts = slug.split('-');
    if (parts.isEmpty) return null;
    return parts.first;
  }

  String? get franchiseName => name;
}

