import 'dart:convert';

import 'package:dio/dio.dart';

import 'image_info_model.dart';

Future<List<ImageInfos>> fetchImages(int page) async {
  Dio dio = Dio();
  final response = await dio.get('https://28.0.0.1/get_ids',
      queryParameters: {'page': page, 'size': 5});
  if (response.statusCode == 200) {
    List<dynamic> dataList = response.data;
    // 假设response.data已经是一个List<dynamic>，每个元素都是一个符合ImageInfo结构的Map
    return dataList.map<ImageInfos>((item) {
      // 首先，确保item是一个Map<String, dynamic>
      Map<String, dynamic> json = item is String ? jsonDecode(item) : item;
      // 然后，使用fromJson工厂构造器来创建ImageInfo对象
      return ImageInfos.fromJson(json);
    }).toList();
  } else {
    throw Exception('Failed to load images');
  }
}
