import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'article.dart';

class ArticleCard extends StatelessWidget {

  late final Article article;

  ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl(article.url),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (article.urlToImage.isNotEmpty) ?
            Image.network(article.urlToImage,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,) :
            Image.asset('assets/images/mainafter.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,),
            Padding(
                padding: const EdgeInsets.all(8),
                child: Text(article.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.all(8),
                child: Text(article.description,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                )),
          ],
        ),
      ),
    );

  }

  _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if(await canLaunchUrl(uri)){
      await launchUrl(uri);
    } else{
      throw 'Could not launch $url';
    }
  }
}