import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/models/Comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/utiles/cabeceras.dart';
import 'package:yourcourt/src/utiles/menu.dart';
import 'package:yourcourt/src/utiles/principal_structure.dart';
import 'package:http/http.dart' as http;

import 'login/LoginPage.dart';

class Comments extends StatefulWidget {

  final int newsId;
  final List<Comment> comments;

  const Comments({Key key, this.comments, this.newsId}) : super(key: key);
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
    return Principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  final TextEditingController commentController = new TextEditingController();

  Widget body(){
    return Center(
      child: FutureBuilder(
            future: getSharedPreferenceInstance(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  return Column(
                    children: [
                      ElevatedButton(
                          onPressed: widget.comments.any((element) => element.user.id==sharedPreferences.getInt("id")) ? null : () {
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
                                            setState(() {
                                              addNewComment(commentController.text, widget.newsId);
                                            });
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
                      Expanded(
                        child: listComments(widget.comments),
                      )
                    ],
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
                    Text(comments.elementAt(index).user.username, style: TextStyle(color: Colors.black),),
                    SizedBox(
                      width: 5,
                    ),
                    Text(comments.elementAt(index).creationDate, style: TextStyle(color: Colors.black),),
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
          onPressed: () {
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    content: Text("¿Seguro que quiere eliminar el comentario?"),
                    actions: [
                      ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              deleteComment(comment.id);
                            });
                          },
                          child: Text("Si")
                      ),
                      ElevatedButton(
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

}
