import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
import 'dart:convert';


class NewsService{

  Future<List<Article>> fetchArticles({int page = 1, String country = 'kr', String category='', String apiKey='8109720b6c894149b4ae1f5c7af80130'}) async {
    String url = 'https://newsapi.org/v2/top-headlines?';
    url += 'country=$country';

    if (category.isNotEmpty && category != 'Headlines') {
      url += '&category=$category';
    }

    if (page > 1) {
      url += '&page=$page';
    }

    url += '&apiKey=$apiKey';

    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200){
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> body = json['articles'];
      List<Article> articles = [];
      for(var item in body) {
        if (await _isUrlValid(item['urlToImage'])) {
          articles.add(Article.fromJson(item));
        }
      }
      return articles;
    } else {
      return [];
    }
  }

  Future<bool> _isUrlValid(String? urlToImage) async {
    try{
      if (urlToImage == null || urlToImage.isEmpty) {
        return false;
      }

      final response = await http.head(Uri.parse(urlToImage));
      return response.statusCode == 200;

    } catch (e) {
      return false;
    }
  }
}

class Article{
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  Article({required this.title, required this.description, required this.urlToImage, required this.url});

  factory Article.fromJson(Map<String, dynamic> json){
    return Article(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        urlToImage: json['urlToImage'] ?? '',
        url: json['url'] ?? ''
    );
  }

}