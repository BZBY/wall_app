class ImageModel {
  final String id;
  final String tag;
  final String? title; // title 可能为空

  ImageModel({required this.id, required this.tag, this.title});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      tag: json['tag'],
      title: json['title'],
    );
  }
}
