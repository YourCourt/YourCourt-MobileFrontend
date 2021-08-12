import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/News.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'CommentsScreen.dart';
import 'login/LoginPage.dart';

class NewsPage extends StatefulWidget {

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body(){
    return Center(
      child: FutureBuilder <List<News>> (
        future: getNews(),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.done){
            return listNews(snapshot.data);
          }
          return CircularProgressIndicator();
        },
      )
    );
  }

  Widget listNews(List<News> news){

    if(news.length>0){
      return ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, int index){
            return Column(
              children: [
                Text(news.elementAt(index).name, style: TextStyle(color: Colors.black),),
                Image(
                  image: NetworkImage(news.elementAt(index).image.imageUrl),
                ),
                GestureDetector(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      Icon(
                        Icons.mode_comment_rounded,
                        size: 24.0,
                      ),
                      if (news.elementAt(index).comments.length > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: CircleAvatar(
                            radius: 6.0,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            child: Text(
                              news.elementAt(index).comments.length.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 9.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (news.elementAt(index).comments.isNotEmpty)
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) => Comments(newsId: news.elementAt(index).id,),),
                      );
                  },
                ),
                Text("Fecha de publicación: " + news.elementAt(index).creationDate, style: TextStyle(color: Colors.black),),
                Text(news.elementAt(index).description, style: TextStyle(color: Colors.black),),



              ],
            );
          }
      );
    } else {
      return Container(
        child: Text("No hay noticias"),
      );
    }

  }

  Future<List<News>> getNews() async {

    List<News> news = [];
    var jsonResponse;

    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/news");
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
      for (var item in jsonResponse) {
        news.add(News.fromJson(item));
      }
    }
    return news;
  }
}
