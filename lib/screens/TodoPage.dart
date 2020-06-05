import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import 'package:todo/database/TodoDatabase.dart';

class Todos extends StatefulWidget {
  @override
  _TodosState createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  @override
  Widget build(BuildContext context) {
    Color green = Color(0xFF03DAC6);
    Color checkedColor = Color(0xFF00B5AD);
    Color blueForGradient = Color(0xFF185A9D);
    double height = MediaQuery.of(context).size.height.toDouble();
    double width = MediaQuery.of(context).size.width.toDouble();
    int completedTodaysTasks;

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

    //function to update ischecked value of task
    //notify parameter will be updated later
    void updateIsCheckedValue(int id, String title, String desc, String date,
        String time, bool isChecked, String notify) async {
      if (isChecked) {
        await TodoDatabase.updateTodo({
          'id': id,
          'title': title,
          'desc': desc,
          'date': date,
          'time': time,
          'isChecked': '0',
          'notify': notify
        });
      } else {
        await TodoDatabase.updateTodo({
          'id': id,
          'title': title,
          'desc': desc,
          'date': date,
          'time': time,
          'isChecked': '1',
          'notify': notify
        });
      }
    }

    //function that will count completed tasks for today
    int getCompletedTasksNumber(List<Map<String, dynamic>> tasks) {
      int count = 0;
      tasks.forEach((task) {
        if (task['isChecked'] == '1') {
          count++;
        }
      });
      return count;
    }

    return FutureBuilder(
        future: TodoDatabase.getTodoList(),
        builder: (context, snapShot) {
          List<Map<String, dynamic>> todo = snapShot.data;
          if (todo == null) {
            todo = [];
          }
          List<Map<String, dynamic>> tasks =
              getTasksForDate(todo, DateTime.now().toString().substring(0, 10));
          if (tasks == null) {
            tasks = [];
          }
          completedTodaysTasks = getCompletedTasksNumber(tasks);
          return SafeArea(
            child: Container(
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    child: Container(
                      height: height * 0.27,
                      width: width,
                      decoration: BoxDecoration(
                          gradient:
                              LinearGradient(colors: [green, blueForGradient])),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                  fontSize: 35.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          //function that wil return current date in string
                          Padding(
                            padding: const EdgeInsets.only(left: 35.0),
                            child: Text(
                              formatDate(
                                  DateTime.now(), [dd, ' ', M, ' ', yyyy]),
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          //function that will return todays tasks and completed tasks
                          Padding(
                            padding: const EdgeInsets.only(left: 35.0),
                            child: Text(
                              '${tasks.length} TASKS  |  $completedTodaysTasks COMPLETED',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), //Top Dashboard
                  DraggableScrollableSheet(
                    maxChildSize: 0.92,
                    initialChildSize: 0.76,
                    minChildSize: 0.76,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .bottomSheetTheme
                                .backgroundColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50.0),
                                topRight: Radius.circular(50.0))),
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15.0),
                            child: ListView.builder(
                                itemCount: tasks.length,
                                //controller: scrollController,
                                itemBuilder: (context, index) {
                                  int id = tasks[index]['id'];
                                  String title = tasks[index]['title'];
                                  String desc = tasks[index]['desc'];
                                  String date = tasks[index]['date'];
                                  String time = tasks[index]['time'];
                                  bool isChecked =
                                      tasks[index]['isChecked'] == '0'
                                          ? false
                                          : true;
                                  String notify = tasks[index]['notify'];

                                  return Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    secondaryActions: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: IconSlideAction(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          foregroundColor: Colors.red,
                                          icon: (Icons.delete),
                                          onTap: () {
                                            TodoDatabase.deleteTodo(id);
                                            SchedulerBinding.instance
                                                .addPostFrameCallback(
                                                    (_) => setState(() {}));
                                            Toast.show('Task deleted', context);
                                          },
                                        ),
                                      )
                                    ],
                                    child: Stack(
                                      overflow: Overflow.visible,
                                      alignment: AlignmentDirectional.topEnd,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                            width: 0.7,
                                            color: Theme.of(context)
                                                .bottomAppBarTheme
                                                .color,
                                          ))),
                                          child: ListTile(
                                            title: Text(
                                              title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                            ),
                                            subtitle: Text(
                                              desc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subhead,
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Center(
                                                    child: Text(time,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1)),
                                                SizedBox(width: 10.0),
                                                Icon(Icons.check_circle,
                                                    color: isChecked
                                                        ? checkedColor
                                                        : Colors.grey),
                                              ],
                                            ),
                                            onTap: () {
                                              updateIsCheckedValue(
                                                  id,
                                                  title,
                                                  desc,
                                                  date,
                                                  time,
                                                  isChecked,
                                                  notify);
                                              SchedulerBinding.instance
                                                  .addPostFrameCallback(
                                                      (_) => setState(() {}));
                                            },
                                            //check uncheck
                                            onLongPress:
                                                () {}, //multi select mode
                                          ),
                                        ),
                                        notify == '1'
                                            ? Positioned(
                                                top: -10,
                                                right: 12,
                                                child: Container(
                                                  height: 30.0,
                                                  width: 30.0,
                                                  color: Theme.of(context)
                                                      .bottomSheetTheme
                                                      .backgroundColor,
                                                  child: Icon(
                                                    Icons.notifications_active,
                                                    color: Theme.of(context)
                                                        .bottomAppBarTheme
                                                        .color.withOpacity(0.7),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  );
                                })
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        });
  }
}
