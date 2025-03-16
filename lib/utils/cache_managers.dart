import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache manager for map marker images
/// Used to cache images used in map markers
class MapImageCacheManager extends CacheManager {
  static const key = 'mapImageCache';

  static MapImageCacheManager? _instance;

  factory MapImageCacheManager() {
    _instance ??= MapImageCacheManager._();
    return _instance!;
  }

  MapImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

/// Cache manager for club images and logos
/// Used to cache club logos and background images
class ClubImageCacheManager extends CacheManager {
  static const key = 'clubImageCache';

  static ClubImageCacheManager? _instance;

  factory ClubImageCacheManager() {
    _instance ??= ClubImageCacheManager._();
    return _instance!;
  }

  ClubImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

/// Cache manager for markdown images
/// Used to cache images used in markdown
class MarkdownImageCacheManager extends CacheManager {
  static const key = 'markdownImageCache';

  static MarkdownImageCacheManager? _instance;

  factory MarkdownImageCacheManager() {
    _instance ??= MarkdownImageCacheManager._();
    return _instance!;
  }

  MarkdownImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

/// Cache manager for profile images
/// Used to cache user profile images
class ProfileImageCacheManager extends CacheManager {
  static const key = 'profileImageCache';

  static ProfileImageCacheManager? _instance;

  factory ProfileImageCacheManager() {
    _instance ??= ProfileImageCacheManager._();
    return _instance!;
  }

  ProfileImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 5,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}