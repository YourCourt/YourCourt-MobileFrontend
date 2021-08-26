import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:yourcourt/src/models/User.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/screens/perfilScreens/PerfilScreen.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/toast_messages.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';

class PerfilUpdate extends StatefulWidget {
  final User user;

  const PerfilUpdate({Key key, this.user}) : super(key: key);

  @override
  _PerfilUpdateState createState() => _PerfilUpdateState();
}

class _PerfilUpdateState extends State<PerfilUpdate> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return principal(context, sharedPreferences,
        appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: textSection(),
        ),
        buttonSection(),
      ],
    ));
  }

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File _image;

  Widget textSection() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    child: _image == null
                        ? Text("Seleccione una imagen")
                        : Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: FileImage(_image), fit: BoxFit.cover),
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                  FloatingActionButton(
                      child: Icon(Icons.camera_alt_rounded),
                      onPressed: () {
                        getImageFromGallery();
                      }),
                ],
              ),
              SizedBox(height: 10.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        String emailPatter =
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                        RegExp regExp = new RegExp(emailPatter);
                        if (value == null) {
                          return 'Por favor, introduzca un email';
                        } else if (!regExp.hasMatch(value)) {
                          return 'Por favor, introduzca un email válido';
                        }
                        return null;
                      },
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        icon: Icon(Icons.email, color: Colors.black),
                        hintText: "Nuevo email",
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: _phoneController,
                      validator: (value) {
                        String mobilePattern = r'^(([+][(][0-9]{1,3}[)][ ])?([0-9]{6,12}))$';
                        RegExp regExp = new RegExp(mobilePattern);
                        if (value == null) {
                          return 'Por favor, introduzca un número de teléfono';
                        } else if (!regExp.hasMatch(value)) {
                          return 'Por favor, introduzca un número de teléfono válido';
                        }
                        return null;
                      },
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        icon: Icon(Icons.phone, color: Colors.black),
                        hintText: "Nuevo teléfono",
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFDBA58F),
        ),
        onPressed: (_emailController.text == "" || _phoneController.text == "")
            ? null
            : () {

          if (_formKey.currentState.validate()) {
            updateUser(_emailController.text, _phoneController.text);

          }

              },
        child: Text("Confirmar Cambios", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  updateUserImage(File file) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");
    // open a bytestream
    var stream = new http.ByteStream(file.openRead());
    stream.cast();
    // get file length
    var length = await file.length();

    // string to uri
    var uri = Uri.parse("https://dev-yourcourt-api.herokuapp.com/image/user/" +
        sharedPreferences.getInt("id").toString());

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('multipartFile', stream, length,
        filename: path.basename(file.path));

    // add file to multipart
    request.files.add(multipartFile);
    // add headers
    request.headers['Authorization'] = "Bearer $token";

    var response = await request.send();

    if (response.statusCode == 200) {
      print("Imagen de perfil actualizada");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Foto de perfil actualizada!')),
      );

    } else {
      print("Se ha producido un error al actualizar la imagen: " +
          response.statusCode.toString());
    }
  }

  updateUser(String email, phone) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data;

    data = {
      "phone": phone,
      "email": email,
      "birthDate": widget.user.birthDate,
    };

    var token = sharedPreferences.getString("token");
    var response = await http.put(
        "https://dev-yourcourt-api.herokuapp.com/users/" +
            sharedPreferences.getInt("id").toString(),
        body: json.encode(data),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 200) {
      showMessage('¡Perfil actualizado!', context);
      setState(() {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MyProfile()),
                (route) => false);
      });
      print("Perfil de usuario actualizado");
    } else {
      print(
          "Se ha producido un error al actualizar el usuario" + response.body);
    }
  }

  Future getImageFromGallery() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        File file = File(pickedImage.path);
        if(file.readAsBytesSync().lengthInBytes <= 4000000 && (file.path.contains('jpeg') || file.path.contains('png') || file.path.contains('jpg'))){
          _image = file;
          updateUserImage(_image);
        }
      } else {
        print("No hay imagen seleccionada");
      }
    });
  }
}
