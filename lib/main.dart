
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/screens/bookingScreens/CourtsScreen.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/screens/transactionsScreens/ProductsScreen.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "YourCourt",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    return Stack(fit: StackFit.expand, children: [
      ColoredBox(color: Color(0xFFDBA58F)),
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home.jpg'),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Echa un vistazo a nuestro catálogo de productos",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amberAccent,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) => Products()));
                      },
                      child: Text(
                        "Ir a productos",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              decoration: BoxDecoration(color: Colors.black87),
              height: 120.0,
              width: 150.0,
            ),
            SizedBox(
              width: 50.0,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Selecciona una pista para reservar",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amberAccent,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) => CourtsPage()));
                      },
                      child: Text(
                        "Ir a pistas",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              decoration: BoxDecoration(color: Colors.black87),
              height: 105.0,
              width: 150.0,
            )
          ],
        ),
      ),
    ]);
  }
}


