import 'package:flutter/material.dart';
import 'artcle_card.dart';
import 'article.dart';
import 'settings.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: const NewsPage(),
    );
  }
}
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Article>> futureArticles;
  final List<Article> _articles = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _country = 'kr';
  String _category = '';

  final List<Map<String, String>> categories = [
    {'title': 'Headlines'},
    {'title': 'Business'},
    {'title': 'Technology'},
    {'title': 'Entertainment'},
    {'title': 'Sports'},
    {'title': 'Science'}
  ];

  @override
  void initState() {
    super.initState();
    futureArticles = NewsService().fetchArticles();
    futureArticles.then((articles) {
      setState(() => _articles.addAll(articles));
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryTap({String category = ''}) {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      futureArticles = NewsService().fetchArticles(category: category, country: _country);
      futureArticles.then((articles) {
        setState(() => _articles.addAll(articles));
      });
    });
    _category = category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News Page',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: AssetImage('assets/news.jpeg'), fit: BoxFit.cover),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text(
                  'News Categories',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ...categories.map((category) => ListTile(
              title: Text(category['title']!),
              onTap: () {
                _onCategoryTap(category: category['title']!);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data'));
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _articles.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final article = _articles[index];
                return ArticleCard(
                    article: article, key: ValueKey(article.title));
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
        onTap: ((value) => _onNavItemTap(value, context)),
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200 && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    _currentPage++;
    List<Article> articles = await NewsService().fetchArticles(page: _currentPage);
    setState(() {
      _articles.addAll(articles);
      _isLoadingMore = false;
    });
  }

  void _onNavItemTap(int value, BuildContext context) {
    switch (value) {
      case 0:
        _showModalBottomSheet(context);
        break;
      case 1:
        break;
      case 2:
        break;
    }
  }

  void _showModalBottomSheet(BuildContext context) {
    List<Map<String, String>> items = [
      {'title': 'Korea', 'image': 'assets/kr.png', 'code': 'kr'},
      {'title': 'Japan', 'image': 'assets/jp.png', 'code': 'jp'},
      {'title': 'America', 'image': 'assets/am.png', 'code': 'am'},
    ];

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            color: Colors.white,
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              children: List.generate(items.length, (index) {
                return Container(
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _onCountryTap(country: items[index]['code']!);
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(items[index]['image']!,
                              width: 50, height: 50, fit: BoxFit.cover),
                          Text(items[index]['title']!)
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        });
  }

  void _onCountryTap({String country = 'kr'}) {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      futureArticles = NewsService().fetchArticles(country: country, category: _category);
      futureArticles.then((value) {
        setState(() {
          _articles.addAll(value);
        });
      });
      _country = country;
    });
  }
}
