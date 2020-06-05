import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/screens/HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool darkThemeEnabled =false ;

  ThemeData light = ThemeData(
        canvasColor: Colors.white,
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white.withOpacity(0.95),
        //bottomNav bg
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.black, //bottomNav unselected color
        ),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
        textTheme: TextTheme(
            title: TextStyle(color: Colors.black), //title ListTile
            subhead: TextStyle(color: Colors.black), //subtitle ListTile
            body1: TextStyle(
                fontSize: 15.0, color: Colors.black.withOpacity(0.7)) //time
            ),
            dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            contentTextStyle: TextStyle(color: Colors.black)),
        inputDecorationTheme:
            InputDecorationTheme(hintStyle: TextStyle(color: Colors.grey[800])),
        buttonColor: Color(0xFF185A9D)
      );
  ThemeData dark = ThemeData(
        canvasColor: Colors.blueGrey[800],
        backgroundColor: Colors.blueGrey[800],
        //bottomNav bg
        bottomAppBarTheme:
            BottomAppBarTheme(color: Colors.white //bottomNav unselected color
                ),
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.blueGrey[700]),
        textTheme: TextTheme(
            title: TextStyle(color: Colors.white), //title ListTile
            subhead: TextStyle(color: Colors.white), //subtitle ListTile
            body1: TextStyle(
                fontSize: 15.0, color: Colors.white.withOpacity(0.6)) //time
            ),
        dialogTheme: DialogTheme(
            backgroundColor: Colors.blueGrey[800],
            contentTextStyle: TextStyle(color: Colors.white70)),
        inputDecorationTheme:
            InputDecorationTheme(hintStyle: TextStyle(color: Colors.white70)),
        buttonColor: Colors.white
        //for listTile
      );

  loadSetting()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool darkTheme = pref.getBool('darkThemeEnabled');
    setState(() {
      darkThemeEnabled = darkTheme??false;
    });
  }

  changeTheme()async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setBool('darkThemeEnabled', !darkThemeEnabled);
      darkThemeEnabled = !darkThemeEnabled;
    });
  }

  @override
  void initState() {
    loadSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: darkThemeEnabled?dark:light,
      //for listTile,
    home: MyHomePage(changeTheme,darkThemeEnabled),
    );
  }
}