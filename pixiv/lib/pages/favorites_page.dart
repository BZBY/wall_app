import 'dart:math';
import 'package:flutter/material.dart';
import 'cached_Image_Decorator.dart';
import 'db_helper.dart'; // 替换为你的 DBHelper 类的实际引用
import 'image_detail.dart'; // 替换为你的 ImageDetailPage 类的实际引用

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _showRandom = false;
  int _gridCrossAxisCount = 2;
  ScrollController _scrollController = ScrollController();
  int _loadedItems = 18;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _scrollController.addListener(_scrollListener);
  }

  void _fetchFavorites() async {
    List<Map<String, dynamic>> favorites = await DBHelper.getAllFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _loadedItems += 6; // 每次到达底部时加载更多图片
      });
    }
  }

  void _toggleShowMode() {
    setState(() {
      _showRandom = !_showRandom;
      _gridCrossAxisCount = _showRandom ? 2 : 1;
    });
  }

  Widget _buildFavoritesGrid() {
    final List<Map<String, dynamic>> displayList = List.from(_favorites);
    if (_showRandom) {
      displayList.shuffle();
    }
    final itemsToShow =
        displayList.take(min(_loadedItems, displayList.length)).toList();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCrossAxisCount,
        childAspectRatio: _gridCrossAxisCount == 1 ? 1 / 1.5 : 1,
      ),
      itemCount: itemsToShow.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        String id = itemsToShow[index]['id'];
        List<String> tags = (itemsToShow[index]['tags'] as String).split(', ');
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageDetailPage(id: id, tags: tags)),
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: CachedImageDecorator(
                        imageUrl: 'https://28.0.0.1/images/${id}_small.jpg',
                      ),
                    ),
                    if (_gridCrossAxisCount == 1) // 仅在 1*6 布局下显示文字信息
                      ListTile(
                        title: Text('Item $id'),
                        subtitle: Text('Tags: ${tags.join(", ")}'),
                      ),
                  ],
                ),
                Positioned(
                  left: 8,
                  bottom: _gridCrossAxisCount == 1 ? 72 : 8, // 根据是否显示文字调整位置
                  child: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      final bool confirmRemove = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm'),
                                content: Text(
                                    'Do you want to remove this item from favorites?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;

                      if (confirmRemove) {
                        await DBHelper.delete(
                            id); // 假定 DBHelper 有一个 removeFavorite 方法
                        _fetchFavorites(); // 重新加载收藏列表
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏'),
        actions: [
          IconButton(
            icon: Icon(_showRandom ? Icons.view_module : Icons.view_list),
            onPressed: _toggleShowMode,
          ),
        ],
      ),
      body: _buildFavoritesGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleShowMode,
        child: Icon(_showRandom ? Icons.shuffle : Icons.sort),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
