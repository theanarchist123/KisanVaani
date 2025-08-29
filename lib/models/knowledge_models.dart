enum OfflinePackStatus { notDownloaded, downloading, downloaded, error }

class OfflinePack {
  final String id;
  final String title;
  final String description;
  final String pdfUrl;
  final String fileName;
  final int sizeBytes;
  final String category;
  final DateTime publishedDate;
  
  // Local state
  OfflinePackStatus status;
  String? localPath;
  double downloadProgress;
  DateTime? downloadedAt;

  OfflinePack({
    required this.id,
    required this.title,
    required this.description,
    required this.pdfUrl,
    required this.fileName,
    required this.sizeBytes,
    required this.category,
    required this.publishedDate,
    this.status = OfflinePackStatus.notDownloaded,
    this.localPath,
    this.downloadProgress = 0.0,
    this.downloadedAt,
  });

  factory OfflinePack.fromJson(Map<String, dynamic> json) {
    return OfflinePack(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pdfUrl: json['pdfUrl'] as String,
      fileName: json['fileName'] as String,
      sizeBytes: json['sizeBytes'] as int,
      category: json['category'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      status: OfflinePackStatus.values[json['status'] as int? ?? 0],
      localPath: json['localPath'] as String?,
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0.0,
      downloadedAt: json['downloadedAt'] != null 
          ? DateTime.parse(json['downloadedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pdfUrl': pdfUrl,
      'fileName': fileName,
      'sizeBytes': sizeBytes,
      'category': category,
      'publishedDate': publishedDate.toIso8601String(),
      'status': status.index,
      'localPath': localPath,
      'downloadProgress': downloadProgress,
      'downloadedAt': downloadedAt?.toIso8601String(),
    };
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool get isDownloaded => status == OfflinePackStatus.downloaded && localPath != null;
  bool get isDownloading => status == OfflinePackStatus.downloading;
}

class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String source;
  final String imageUrl;
  final DateTime publishedAt;
  final List<String> keywords;
  
  // Local state
  bool isBookmarked;
  bool isCached;
  DateTime? cachedAt;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.keywords,
    this.isBookmarked = false,
    this.isCached = false,
    this.cachedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      url: json['url'] as String,
      source: json['source'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isCached: json['isCached'] as bool? ?? false,
      cachedAt: json['cachedAt'] != null 
          ? DateTime.parse(json['cachedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'source': source,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'keywords': keywords,
      'isBookmarked': isBookmarked,
      'isCached': isCached,
      'cachedAt': cachedAt?.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class KnowledgeCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int articleCount;
  final int packCount;

  KnowledgeCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.articleCount,
    required this.packCount,
  });

  factory KnowledgeCategory.fromJson(Map<String, dynamic> json) {
    return KnowledgeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      articleCount: json['articleCount'] as int,
      packCount: json['packCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'articleCount': articleCount,
      'packCount': packCount,
    };
  }
}
