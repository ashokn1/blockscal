import 'package:flutter/material.dart';
import 'blockinfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue ,
      ),
      home: MyHomePage(title: 'CalApp'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  DateTime date = DateTime.now();
  final DateTime firstDate = DateTime.utc(2020, 09, 01);
  final DateTime lastDate = DateTime.utc(2021, 6, 30);
  final List<BlockInfo> blockList = parseBlockInfoList('''
  [
    { "name": "Entry A", "startTime": "20210520T123000Z", "endTime": "20210520T131500Z"},
    { "name": "Entry B", "startTime": "20210520T142000Z", "endTime": "20210520T150500Z"},
    { "name": "Entry C", "startTime": "20210520T151500Z", "endTime": "20210520T160000Z"}
  ] ''');


  void _decrementDate() {
    setState(() {
        date = date.add(const Duration(days: -1));
        if (date.weekday == DateTime.sunday) {
          date = date.add(const Duration(days: -2));
        }
    });
  }

  void _incrementDate() {
    setState(() {
        date = date.add(const Duration(days: 1));
        if (date.weekday == DateTime.saturday) {
          date = date.add(const Duration(days: 2));
        }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null && picked != date) {
      setState(() { date = picked; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
         actions: <Widget>[

           IconButton(
             padding: EdgeInsets.all(0),
             alignment: Alignment.centerRight,
             icon: Icon(Icons.keyboard_arrow_left),
             onPressed: () => _decrementDate(),
           ),
           
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () => _selectDate(context),
            child: Text(date.toString().split(" ")[0]),
          ),

          IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerLeft,
            icon: Icon(Icons.keyboard_arrow_right),
            onPressed: () => _incrementDate(),
          ),
          
        ]
      ),

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[

            Container(
              height: 64,
              color: Colors.yellow[900],
              child: Center(child: Text(
                  'Entry A',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white))),
            ),

            Divider(),
                
            Container(
              height: 64,
              color: Colors.red[200],
              child: Center(child: Text(
                  'Entry B',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.grey[600]))),
            ),
                
            Divider(),

            Container(
              height: 64,
              color: Colors.green[200],
              child: Center(child: Text(
                  'Entry C',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.grey[600]))),
            ),
                
            
          ],
          // separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
