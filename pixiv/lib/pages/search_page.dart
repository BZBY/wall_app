import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pixiv/pages/image_detail.dart';

import 'flutter_cache_manager_self.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  double _searchBarHeight = 1 / 3;
  final ScrollController _scrollController = ScrollController();

  void _search() async {
    final response = await http.get(Uri.parse(
        'https://28.0.0.1/search_by_tag?word=${_controller.text}&page_start=1&page_end=5'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _results = List<Map<String, dynamic>>.from(data);
        _searchBarHeight = 1 / 5;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search by Tag')),
      body: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(seconds: 1),
            height: MediaQuery.of(context).size.height * _searchBarHeight,
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _search,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                    onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDetailPage(
                                  id: item['id'],
                                  tags: item['tags'].toString().split(',')),
                            ),
                          ),
                        },
                    title: Text(item['id']),
                    subtitle: Text(item['tags'].join(', ')),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // 圆角半径
                      child: SizedBox(
                        child: CachedNetworkImage(url: item['url']),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
