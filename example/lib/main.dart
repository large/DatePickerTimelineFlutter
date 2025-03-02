import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:date_picker_timeline/datetimehelper/datetimehelper.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Date Picker Timeline Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatePickerController _controller = DatePickerController();
  DatePickerController _controller2 = DatePickerController();

  DateTime _selectedValue = DateTime.now().dateWithoutTime();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(days: -28);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () {
            //_controller.animateToSelection(scrollOneExtraPosition: true);
            _controller.jumpToSelection(scrollOneExtraPosition: true);
            _controller2.jumpToSelection(scrollOneExtraPosition: true);
          },
        ),
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < 0) {
              // drag from right to left
              //debugPrint("Right to left ${details.primaryVelocity!}");
              if (details.primaryVelocity! < -1500)
                _controller.swipeSelection(-1);
            } else {
              //debugPrint("Left to right");
              if (details.primaryVelocity! > 1500)
                _controller.swipeSelection(1);
            }
          },
          child: Container(
            //padding: EdgeInsets.all(41.0),
            color: Colors.blueGrey[100],
            child: Column(
              children: <Widget>[
                Text("You Selected:"),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                Text(_selectedValue.toString()),
                Padding(
                  padding: EdgeInsets.all(20),
                ),
                DatePicker(
                  DateTime.now().add(duration),
                  //Removes the strech in scrolling
                  scrollBehavior: MaterialScrollBehavior().copyWith(overscroll: false),
                  daysCount: 35,
                  width: 60,
                  height: 80,
                  controller: _controller,
                  initialSelectedDate: DateTime.now(),
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  inactiveDates: [
                    DateTime.now().add(Duration(days: 3)),
                    DateTime.now().add(Duration(days: 4)),
                    DateTime.now().add(Duration(days: 7))
                  ],
                  onDateChange: (date) {
                    // New date selected
                    setState(() {
                      _selectedValue = date;
                    });
                  },
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: DatePicker(
                    DateTime.now().add(duration),
                    //Removes the strech in scrolling
                    scrollBehavior: ScrollBehavior(),
                    daysCount: 30,
                    width: 60,
                    height: 80,
                    controller: _controller2,
                    initialSelectedDate: DateTime.now(),
                    selectionColor: Colors.black,
                    selectedTextColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    inactiveDates: [
                      DateTime.now().add(Duration(days: 3)),
                      DateTime.now().add(Duration(days: 4)),
                      DateTime.now().add(Duration(days: 7))
                    ],
                    onDateChange: (date) {
                      // New date selected
                      setState(() {
                        _selectedValue = date;
                      });
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Duration duration = Duration(days: -3);
                      _controller.setDateAndAnimate(
                          DateTime.now().add(duration),
                          scrollOneExtraPosition: true);
                      _controller2.setDateAndAnimate(
                          DateTime.now().add(duration),
                          scrollOneExtraPosition: true);
                    },
                    child: Text("Select today minus 3 days")),

                TextButton(
                    onPressed: () {
                      Duration duration = Duration(days: -2);
                      _controller.setDateAndAnimate(
                          DateTime.now().add(duration),
                          scrollOneExtraPosition: false);
                      _controller2.setDateAndAnimate(
                          DateTime.now().add(duration),
                          scrollOneExtraPosition: false);
                    },
                    child: Text("Select today minus 2 days no extra pos")),
                Text("Swipe right and left to move dates"),
              ],
            ),
          ),
        ));
  }
}
