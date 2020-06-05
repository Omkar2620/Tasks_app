import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toast/toast.dart';
import 'package:todo/database/TodoDatabase.dart';
import 'CalenderPage.dart';
import 'TodoPage.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  Function themeChange;
  bool isDarkTheme;

  MyHomePage(this.themeChange,this.isDarkTheme);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int _selectedBottomTab;
  Color green = Color(0xFF03DAC6);
  Color checkedColor = Color(0xFF00B5AD);
  Color blueForGradient = Color(0xFF185A9D);
  bool isnotify;

  @override
  void initState() {
    _selectedBottomTab = 0;
    _initializeNotifications();
    super.initState();
  }

  void _onTapped(int index) {
    setState(() {
      _selectedBottomTab = index;
    });
  }

  onRefresh() {
    setState(() {});
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        print('notification payload: ' + payload);
      }
    });
  }

  Future<void> scheduleNotification(
      String title, String body, DateTime dateTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: 'test5');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0, title, body, dateTime, platformChannelSpecifics);
  }

  createTodo(BuildContext context) {
    bool isPressed = false;
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.now();

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
              title: Text('Add a task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle:
                            Theme.of(context).inputDecorationTheme.hintStyle),
                  ),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle:
                            Theme.of(context).inputDecorationTheme.hintStyle),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                          color: checkedColor,
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2050));
                          }),
                      IconButton(
                          color: checkedColor,
                          icon: Icon(Icons.access_time),
                          onPressed: () async {
                            time = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now(),);
                          }),
                      IconButton(
                          icon: (isPressed)
                              ? Icon(Icons.notifications_active)
                              : Icon(Icons.notifications),
                          color: checkedColor,
                          onPressed: () {
                            setState(() {
                              isPressed = !isPressed;
                            });
                          })
                    ],
                  )
                ],
              ),
              actions: <Widget>[
                MaterialButton(
                    elevation: 5.0,
                    child: Text(
                      'Save',
                      style: Theme.of(context).dialogTheme.contentTextStyle,
                    ),
                    onPressed: () async {
                      String notify = isPressed ? '1' : '0';

                      if (titleController.text.isEmpty) {
                        Toast.show('An empty task discarded', context,
                            duration: 2);
                      } else {
                        if (descController.text.isEmpty) {
                          TodoDatabase.insertTodo({
                            'title': titleController.text,
                            'desc': '',
                            'date': date.toString().substring(0, 10),
                            'time': time.toString().substring(10, 15),
                            'isChecked': '0',
                            'notify': notify
                          });
                        } else {
                          TodoDatabase.insertTodo({
                            'title': titleController.text,
                            'desc': descController.text,
                            'date': date.toString().substring(0, 10),
                            'time': time.toString().substring(10, 15),
                            'isChecked': '0',
                            'notify': notify
                          });
                        }
                        Toast.show('Task added', context);
                        if (notify == '1') {
                          String dateString = date.toString().substring(0, 10);
                          String timeString = time.toString().substring(10, 15);
                          String dateTimeString =
                              dateString + ' ' + timeString + ':00.000000';
                          DateTime dateTime = DateTime.parse(dateTimeString);
                          await scheduleNotification(titleController.text,
                              descController.text, dateTime);
                        }
                      }
                      onRefresh();
                      Navigator.of(context).pop();
                    }),
                MaterialButton(
                    elevation: 5.0,
                    child: Text(
                      'Discard',
                      style: Theme.of(context).dialogTheme.contentTextStyle,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {

    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark ? true: false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
      ]
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    
    return Scaffold(
      drawer: Container(
        width: MediaQuery.of(context).size.width*0.65,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  child: Center(
                      child: Text('Settings',style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0
                      ),)
                  ),
                  decoration: BoxDecoration(color: checkedColor)),
              ListTile(
                title: Text('Dark Theme',
                    style: TextStyle(
                        fontSize: 17.0,
                        color: Theme.of(context).textTheme.title.color)),
                trailing: Switch(
                    value: widget.isDarkTheme,
                    onChanged: (newValue) {
                      widget.themeChange();
                      Toast.show(widget.isDarkTheme?'Switched to light theme':'Switched to dark theme', context,duration: 2);
                    }),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _selectedBottomTab == 0 ? Todos() : CalenderPage(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          backgroundColor: checkedColor,
          child: Icon(
            Icons.add,
            size: 30.0,
          ),
          onPressed: () {
            createTodo(context);
          }),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).bottomAppBarTheme.color,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 10.0,
        currentIndex: _selectedBottomTab,
        selectedItemColor: Color(0xFF00B5AD),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), title: Text('Today')),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), title: Text('Calender')),
        ],
        onTap: (index) {
          _onTapped(index);
        },
      ),
    );
  }
}
