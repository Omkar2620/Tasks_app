import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';
import 'package:todo/database/TodoDatabase.dart';

class CalenderPage extends StatefulWidget {
  CalenderPage({Key key}) : super(key: key);

  @override
  _CalenderPageState createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  CalendarController _controller;
  DateTime selectedDate;
  Map<DateTime, List<dynamic>> _events;

  @override
  void initState() {
    _controller = CalendarController();
    selectedDate = DateTime.now();
    _events = {};
    super.initState();
  }

  //function to find out tasks for the day
  List<Map<String, dynamic>> getTasksForDate(
      List<Map<String, dynamic>> todo, String date) {
    List<Map<String, dynamic>> tasks = [];
    todo.forEach((todo) {
      if (todo['date'] == date) {
        tasks.add(todo);
      }
    });
    return tasks;
  }

  deletePastEvents(List<Map<String, dynamic>> todo) {
    DateTime now = DateTime.now();
    todo.forEach((task) {
      DateTime date2 = DateTime.parse(task['date']);
      if (date2.difference(now) < Duration(days: -1)) {
        TodoDatabase.deleteTodo(task['id']);
      }
    });
  }

  Map<DateTime, List<dynamic>> getEvents(List<Map<String, dynamic>> todo) {
    Map<DateTime, List<dynamic>> events = {};
    todo.forEach((task) {
      if (events[DateTime.parse(task['date'])] == null) {
        events[DateTime.parse(task['date'])] = [task['title']];
      } else {
        events[DateTime.parse(task['date'])].add([task['title']]);
      }
    });
    return events;
  }

  @override
  Widget build(BuildContext context) {
    String today = formatDate(selectedDate, [dd, '-', M, '-', yyyy]);
    Color green = Color(0xFF03DAC6);
    Color checkedColor = Color(0xFF00B5AD);
    Color blueForGradient = Color(0xFF185A9D);
    double height = MediaQuery.of(context).size.height.toDouble();
    double width = MediaQuery.of(context).size.width.toDouble();

    return Column(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Container(
            width: width,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [green, blueForGradient])),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Toast.show('Search not implemented', context);
                        }),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      today.toString().substring(0, 2),
                      // day of the selected date from calender
                      style: TextStyle(
                          fontSize: 100.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(
                          fontSize: 100.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          today.substring(3, 6).toUpperCase(),
                          //month of the selected date from calender
                          style: TextStyle(fontSize: 40.0, color: Colors.white),
                        ),
                        Text(
                          today.substring(7, 11),
                          //year of the selected date from calender
                          style: TextStyle(fontSize: 40.0, color: Colors.white),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Expanded(
            flex: 7,
            child: FutureBuilder(
                future: TodoDatabase.getTodoList(),
                builder: (context, snapShot) {
                  List<Map<String, dynamic>> todo = snapShot.data;
                  if (todo == null) {
                    todo = [];
                  }
                  deletePastEvents(todo);
                  _events = getEvents(todo);
                  List<Map<String, dynamic>> tasks = getTasksForDate(
                      todo, selectedDate.toString().substring(0, 10));

                  return Container(
                    color: Theme.of(context).bottomSheetTheme.backgroundColor,
                    height: height * 0.67,
                    width: width,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TableCalendar(
                            events: _events,
                            initialCalendarFormat: CalendarFormat.month,
                            calendarController: _controller,
                            rowHeight: 40.0,
                            calendarStyle: CalendarStyle(
                              markersMaxAmount: 1,
                              markersColor: today==formatDate(DateTime.now(), [dd, '-', M, '-', yyyy])?Theme.of(context).buttonColor:Colors.white,
                              contentPadding: EdgeInsets.all(0.0),
                              todayColor: blueForGradient,
                              selectedColor: checkedColor,
                            ),
                            headerStyle: HeaderStyle(
                                centerHeaderTitle: true,
                                formatButtonDecoration: BoxDecoration(
                                    color: checkedColor,
                                    borderRadius: BorderRadius.circular(20.0)),
                                formatButtonTextStyle:
                                    TextStyle(color: Colors.white),
                                formatButtonShowsNext: false),
                            builders: CalendarBuilders(
                              selectedDayBuilder: (context, date, events) =>
                                  Container(
                                margin: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: checkedColor,
                                    shape: BoxShape.circle),
                                child: Text(date.day.toString(),
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white)),
                              ),
                              todayDayBuilder: (context, date, events) =>
                                  Container(
                                margin: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: blueForGradient,
                                    shape: BoxShape.circle),
                                child: Text(date.day.toString(),
                                    style: TextStyle(
                                        fontSize: 13.0, color: Colors.white)),
                              ),
                            ),
                            //when date selected
                            onDaySelected: (date, events) {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, top: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: checkedColor,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 3.0),
                                  child: Text(
                                    'Tasks for ${formatDate(selectedDate, [
                                      dd,
                                      ' ',
                                      M,
                                      ' ',
                                      yyyy
                                    ])}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 10.0,
                          ),
                          ...tasks.map((task) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 22.0, top: 10.0),
                              child: Container(
                                  child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(task['title'],
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500)),
                              ))))
                        ],
                      ),
                    ),
                  );
                })),
      ],
    );
  }
}
