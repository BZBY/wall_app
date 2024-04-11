import 'package:flutter/material.dart';
import 'api_service.dart'; // 确保这里正确地导入了api_service.dart文件
import 'cached_Image_Decorator.dart';
import 'image_detail.dart'; // 如果你有一个用于展示图片详细信息的页面

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> images = []; // 改为直接使用列表管理图片
  bool isLoading = false; // 标记是否正在加载新图片
  int currentPage = 1; // 当前加载的页码

  @override
  void initState() {
    super.initState();
    _loadMoreImages(); // 初始加载图片
  }

  Future<void> _loadMoreImages() async {
    if (isLoading) return; // 如果已经在加载，则直接返回

    setState(() => isLoading = true);

    // 假设 fetchImages 可以接受当前页码作为参数
    var newImages = await fetchImages(currentPage);
    setState(() {
      print(newImages);
      print("????");
      images.addAll(newImages);
      print(images);
      currentPage++; // 页码增加
      isLoading = false; // 加载状态更新
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
      ),
      body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!isLoading &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              _loadMoreImages(); // 滑动到底部时加载更多图片
            }
            return true;
          },
          child: ListView.builder(
              itemCount: images.length + 1,
              itemBuilder: (context, index) {
                if (index < images.length) {
                  var imageInfo = images[index];
                  String imageUrl =
                      'https://28.0.0.1/images/${imageInfo.id}_small.jpg';

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () => onTap(context, imageInfo.id, imageInfo.tags),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0), // 图片右侧的间距
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // 圆角半径
                              child: SizedBox(
                                width: MediaQuery.of(context).size.height / 5,
                                height: MediaQuery.of(context).size.height / 4,
                                child: CachedImageDecorator(
                                  imageUrl: imageUrl,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(15.0), // 添加内边距
                                child: Text(
                                  imageInfo.tags.join(', '),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              })),
    );
  }

  void _navigateToDetail(BuildContext context, String id, List<String> tags) {
    String imageUrl = 'https://28.0.0.1/images_detail/${id}';
    // 导航到详情页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailPage(
          id: id,
          tags: tags,
        ),
      ),
    );
  }

  void onTap(BuildContext context, String id, List<String> tags) {
    _navigateToDetail(context, id, tags);
  }
}
