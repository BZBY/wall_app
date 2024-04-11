import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'image_info_model.dart'; // 确保正确导入ImageInfos模型
import 'db_helper.dart'; // 导入数据库帮助类
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadImage(String url, String fileName) async {
  final dio = Dio();

  // 设置 cookies
  String cookies = [
    'first_visit_datetime_pc=2024-03-23%2013%3A44%3A09',
    'p_ab_id=9',
    // 添加剩余的 cookies
    '__cf_bm=FLcAmND7tLg4mIrBz5fahXZVu6JxkcwXdqIKtASDB.E-1712730486-1.0.1.1-I3MSVzYtuULmzPvaJ0L9iKMV2BHHjJvMMtDKiOlhD7TR6am8KktYzUCBGZVTxMzoPBPt1p.4WJsUAbBFGTab8VGHQF.q2_y1mK3SZjumaak',
    'cf_clearance=O8xQdJM4VbRhjHnwPlSAIPKsQ0HP11TiODdopV3sRtc-1712730487-1.0.1.1-Jb9ktUjoDccRBP.c9FPUGpAZRLCy0HqsyzJa6Zs6ks3qZTVK6n6iPeRuncRITODtPNdYkz_HRpxuwTRt0D3SXg',
  ].join('; ');

  // 设置 headers
  Map<String, dynamic> headers = {
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'accept-language': 'zh-CN,zh;q=0.9',
    'cache-control': 'max-age=0',
    'cookie': cookies,
    'referer': 'https://www.pixiv.net/ranking.php',
    // 添加剩余的 headers
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
  };

  // 将 headers 加入请求
  dio.options.headers = headers;

  final directory = await getApplicationDocumentsDirectory(); // 应用的文件目录
  final filePath = '${directory.path}/$fileName';

  // Android Q (API 29) 及以上版本，请参考下面的说明
  if (Platform.isAndroid) {
    final externalDirectory = await getExternalStorageDirectory(); // 外部存储目录
    final externalPath = '${externalDirectory?.path}/$fileName';
    // 使用 Dio 下载文件
    await dio.download(url, externalPath);
    print("Image saved to $externalPath");
  } else {
    // 非 Android Q 或更高版本，或其他平台
    await dio.download(url, filePath);
    print("Image saved to $filePath");
  }
}

class ImageDetailPage extends StatefulWidget {
  final String id;
  final List<String> tags;

  ImageDetailPage({required this.id, required this.tags});

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() async {
    final favorited = await DBHelper.isFavorited(widget.id);
    setState(() {
      isFavorited = favorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<ImageInfos?> getImageInfo(String id) async {
      try {
        String url = 'https://28.0.0.1/images_detail/$id';
        Response response = await Dio().get(url);
        print('Image info fetched successfully');
        return ImageInfos.fromJson(response.data);
      } catch (error) {
        print('Error fetching image info: $error');
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<ImageInfos?>(
        future: getImageInfo(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            ImageInfos? imageInfo = snapshot.data;
            String? imageUrl = 'https://28.0.0.1/images/${widget.id}_small.jpg';
            String? imageOriginUrl = imageInfo?.urls['original'];
            if (imageOriginUrl == null) {
              imageOriginUrl = imageInfo?.urls['small'];
            } else {
              print("??? ");
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 1 / 12),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300), // 添加浅色边框
                        borderRadius: BorderRadius.circular(20), // 圆角效果
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20), // 确保图片也应用了圆角效果
                        child: CachedNetworkImage(
                          imageUrl: imageUrl ?? '',
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover, // 保持图片的高宽比
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tags: ${widget.tags.join(', ')}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border, // 根据收藏状态显示不同的图标
                          color: isFavorited ? Colors.red : null, // 根据收藏状态设置颜色
                        ),
                        label:
                            Text(isFavorited ? '取消收藏' : '收藏'), // 根据收藏状态显示不同的文本
                        onPressed: () async {
                          if (isFavorited) {
                            // 如果已经收藏，执行取消收藏操作
                            await DBHelper.delete(widget.id);
                            setState(() {
                              isFavorited = false; // 更新收藏状态为未收藏
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('取消收藏成功'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // 否则执行收藏操作
                            await DBHelper.insert(widget.id, widget.tags);
                            setState(() {
                              isFavorited = true; // 更新收藏状态为已收藏
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('收藏成功'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text("download"),
                        onPressed: imageOriginUrl != null
                            ? () async {
                                await downloadImage(
                                    imageOriginUrl!, '$widget.id.jpg');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('下载成功'),
                                      duration: Duration(seconds: 2)),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
