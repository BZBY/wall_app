import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedNetworkImage extends StatelessWidget {
  final String url;

  const CachedNetworkImage({Key? key, required this.url}) : super(key: key);

  Future<String> _getImageFilePath() async {
    FileInfo? cacheFile = await DefaultCacheManager().getFileFromCache(url);
    if (cacheFile != null) {
      // 如果缓存中已有此文件，直接返回文件路径
      return cacheFile.file.path;
    } else {
      // 如果缓存中没有，使用 dio 下载并缓存文件
      try {
        var dio = Dio();

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
        var response = await dio.get(url,
            options: Options(responseType: ResponseType.bytes));
        final file = await DefaultCacheManager()
            .putFile(url, response.data, fileExtension: "jpg");
        return file.path;
      } catch (e) {
        print(e.toString());
        throw Exception('Error fetching image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImageFilePath(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Icon(Icons.error);
        } else {
          return Image.file(File(snapshot.data!));
        }
      },
    );
  }
}
