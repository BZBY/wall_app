class ImageInfos {
  final String id;
  final List<String> tags;
  final Map<String, String> urls;

  ImageInfos({required this.id, required this.tags, required this.urls});

  factory ImageInfos.fromJson(Map<String, dynamic> json) {
    return ImageInfos(
      id: json['id'] as String,
      tags: List<String>.from(json['tags']),
      urls: Map<String, String>.from(json['urls']),
    );
  }
}
