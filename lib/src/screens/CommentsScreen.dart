import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/models/Comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/News.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';

import 'login/LoginPage.dart';

class Comments extends StatefulWidget {

  final int newsId;

  const Comments({Key key, this.newsId}) : super(key: key);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
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

  final TextEditingController commentController = new TextEditingController();

  Widget body(){
    return Center(
      child: FutureBuilder(
            future: getSharedPreferenceInstance(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  return FutureBuilder(
                    future: getComments(widget.newsId),
                      builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.done){
                        return Column(
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFDBA58F),
                                ),
                                onPressed: snapshot.data.any((element) => element.user.id==sharedPreferences.getInt("id")) ? null : () {
                                  showDialog(
                                      context: context,
                                      builder: (context){
                                        return AlertDialog(
                                          content: TextFormField(
                                            controller: commentController,
                                            validator: (value) {
                                              if (value.length == 0) {
                                                return 'Por favor, introduzca un comentario';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              icon: Icon(Icons.mode_comment_rounded, color: Colors.black),
                                              hintText: "Comentario",
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black)),
                                              hintStyle: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  addNewComment(commentController.text, widget.newsId);
                                                },
                                                child: Text("Comentar")
                                            ),
                                            ElevatedButton(
                                                onPressed:  () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Volver")
                                            ),
                                          ],
                                        );
                                      }
                                  );

                                },
                                child: Text("Comentar")
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Expanded(
                              child: listComments(snapshot.data),
                            )
                          ],
                        );
                      }
                      return CircularProgressIndicator();

                      }
                  );
                }
                return CircularProgressIndicator();
              }
          ),
    );
  }

  Widget listComments(List<Comment> comments){
    return ListView.builder(
      itemCount: comments.length,
        itemBuilder: (context, int index){
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Publicado por: " , style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),),
                    SizedBox(
                      width: 5,
                    ),
                    Text(comments.elementAt(index).user.username, style: TextStyle(color: Colors.black),),
                    SizedBox(
                      width: 5,
                    ),
                    Text(" en ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),),
                    SizedBox(
                      width: 5,
                    ),
                    Text(comments.elementAt(index).creationDate + ":", style: TextStyle(color: Colors.black),),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(comments.elementAt(index).content, style: TextStyle(color: Colors.black),),
                SizedBox(
                  height: 5,
                ),
                deleteCommentButton(comments.elementAt(index)),
              ],
            )
          );
        }
    );

  }

  addNewComment(String comment, int newsId) async {

    sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      "content" : comment,
      "newsId" : newsId,
    };

    var token = sharedPreferences.getString("token");

    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/comments",
        body: json.encode(data),
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        });

    if (response.statusCode == 201) {
      print("Comentario registrado con éxito");
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
    }
  }

  Widget deleteCommentButton(Comment comment) {

    if (comment.user.id == sharedPreferences.getInt("id")) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFBB856E),
        ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    content: Text("¿Seguro que quiere eliminar el comentario?"),
                    actions: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFBB856E),
                          ),
                          onPressed: () async {
                            deleteComment(comment.id);
                          },
                          child: Text("Si")
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFBB856E),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancelar")
                      ),
                    ],
                  );
                }
            );
          },
          child: Text("Eliminar comentario"),
      );
    } else {
      return SizedBox(height: 5,);
    }
  }

  deleteComment(int commentId) async {

    var token = sharedPreferences.getString("token");

    var response = await http.delete(
        "https://dev-yourcourt-api.herokuapp.com/comments/" + commentId.toString(),
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        });

    if (response.statusCode == 200) {
      print("Comentario eliminado con éxito");
      setState(() {
        Navigator.pop(context);
      });

    } else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
    }
  }

  Future<SharedPreferences> getSharedPreferenceInstance() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  Future<List<Comment>> getComments(int newsId) async {
    News news;

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/news/" + newsId.toString(),
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json",
        });

    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
      news = News.fromJson(jsonResponse);
    } else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
    }

    return news.comments;

  }

}
