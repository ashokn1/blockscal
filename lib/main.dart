import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'package:editable/editable.dart';
import 'dart:async';
import 'dart:convert';

import 'blockinfo.dart';
import 'classmap.dart';
import 'classmap_editor.dart';
import 'test_cmap_editor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalApp Test',
      theme: ThemeData(
        primarySwatch: Colors.blue ,
      ),
      home: MyHomePage(title: 'CalApp New'),
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
  DateTime date = DateUtils.dateOnly(DateTime.utc(2021, 05, 10));
  final DateTime firstDate = DateUtils.dateOnly(DateTime.utc(2020, 06, 01));
  final DateTime lastDate = DateUtils.dateOnly(DateTime.utc(2021, 6, 30));
  int numDaysEstimate = 0;
  int startingDatePosition = 0;
  final String blockListJsonSource = 'assets/new.json';
  final String classMapOrigJsonSource = 'assets/test_classmap.json';
  final String classMapJsonSource = 'assets/classmap.json';
  final _editableKey = GlobalKey<EditableState>();

  PageController _blockPageController = PageController();

  firebase_storage.FirebaseStorage storage =
  firebase_storage.FirebaseStorage.instance;

  Blocks blockList = new Blocks();
  ClassMap classMap = new ClassMap();

  Future<String> _loadAllData() async {
    //var connection = await Firebase.initializeApp();
    //print(connection);

    final futures = <Future>[
      //_futureWaitTwoSeconds(),
      _futureLoadBlockListAsset(),
      //_futureLoadBlockListFB(),
      _futureLoadClassMap(),
      //_futureLoadOrigClassMap(),
    ];

    await Future.wait(futures);
    _blockPageController =  PageController(keepPage: true, viewportFraction: 1, initialPage: date.difference(firstDate).inDays);
    return("Done");
  }

  Future<void> _futureWaitTwoSeconds() {
    return Future.delayed(Duration(seconds: 2), () => print('WaitTwoSeconds'));
  }
  
  Future<void> _futureLoadBlockListAsset() async {
    if (!blockList.blockInfoParsed) {
      var jsonText = await DefaultAssetBundle.of(context).loadString(blockListJsonSource);
      blockList.parseBlockScheduleFromJson(jsonText);
    }
  }
  
  Future<void> _futureLoadBlockListFB() async {
    if (!blockList.blockInfoParsed) {
      print("Loading blocks from FB");
      var ref = storage.ref('/cal.json');
      var url = await ref.getDownloadURL();
      print("loading blocks from " + url);
      var jsonText = await http.get(Uri.parse(url));
      print("loaded blocks: " + jsonText.body);
      blockList.parseBlockScheduleFromJson(jsonText.body);
    }
  }
  
  Future<void> _futureLoadOrigClassMap() async {
    if (!blockList.classMapParsed) {
      var jsonText = await DefaultAssetBundle.of(context).loadString(classMapOrigJsonSource);
      blockList.parseClassMapFromJson(jsonText);
    }
  }
  
  Future<void> _futureLoadClassMap() async {
    var jsonText = await DefaultAssetBundle.of(context).loadString(classMapJsonSource);
    blockList.parseClassMapFromJson(jsonText);
    //print(classMap.classes);
    //print(classMap.blockToClassMap);
  }
  
  // Builds and returns the container with
  // - today's date
  // - list of all the classes today
  Container _blockListBuilder(List<BlockInfo> list) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(bottom: 16), 
            child: Container(
              alignment: Alignment.center,
              child: Text(DateFormat("EEEE, MMMM d, y").format(date),
                style: Theme.of(context).textTheme.headline4!,
              ),
            ),
          ),
          Expanded(child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 8),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  color: list[index].bgColor,
                  child: Center(child: Row(
                      children: <Widget>[
                        Column( children: <Widget>[
                            Text(
                              list[index].allDay ? "" :
                              DateFormat.jm().format(list[index].startTime.toLocal()),
                              style: TextStyle(fontSize: 16), textAlign: TextAlign.left), 
                            Text(
                              list[index].allDay ? "" :
                              DateFormat.jm().format(list[index].endTime.toLocal()),
                              style: TextStyle(fontSize: 16), textAlign: TextAlign.right), 
                        ]),
                        (list[index].blockSubtitle != null) ?
                        Expanded(child: Column( children: <Widget>[
                              Text(list[index].blockTitle,
                                style: list[index].textStyle, textAlign: TextAlign.center),
                              Text(list[index].blockSubtitle!,
                                style: list[index].textSubStyle, textAlign: TextAlign.center),
                        ])) : 
                        Expanded(child: Text(
                            list[index].blockTitle,
                            style: list[index].textStyle, textAlign: TextAlign.center)),
                      ]
                    )
                  )
                );
              }
            )
          )
        ]
      )
    );
  }

  // Builds and returns the top-level swipeable pageview which contains the calendar
  PageView _blockListPageView() {
    return PageView.builder(
      controller: _blockPageController,
      itemCount: lastDate.difference(firstDate).inDays + 1,
      itemBuilder: (context, position) {
        date = DateUtils.addDaysToDate(firstDate, position);
        return _blockListBuilder(blockList.forDate(date));
      },
    );
  }
  
  // The BlockList View.
  FutureBuilder _blockListView() {
    return FutureBuilder(
      // future: DefaultAssetBundle.of(context).loadString(blockListJsonSource),
      future: _loadAllData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Data is available; render it
          //return _blockListBuilder(blockList.forDate(date));
          return _blockListPageView();
        } else if (snapshot.hasError) {
          // Error loading data
          return Column( children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 64), 
                child: Icon(Icons.error_outline, color: Colors.red, size: 60)),
              Padding(padding: EdgeInsets.only(top: 16),
                child: Text('Error loading data', style: Theme.of(context).textTheme.headline2!),),
              Text(snapshot.error.toString(), style: Theme.of(context).textTheme.caption!),
            ]
          );
        } else {
          // No data available yet; render a spinner
          return Column( children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 64), child: SizedBox(
                  child: CircularProgressIndicator(), width: 60, height: 60) ),
              Padding(padding: EdgeInsets.only(top: 16),
                child: Text('Loading data', style: Theme.of(context).textTheme.headline2!) ),
            ]
          );
        }
      }
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: firstDate,
      lastDate: lastDate);
    if (picked != null && picked != date) {
      setState(() {
          date = picked;_blockPageController.jumpToPage(date.difference(firstDate).inDays); });
    }
  }

  void _showClassMapList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return TestClassMapEditor(classMap: blockList.classMap,
          onSaved: (value) {
          setState(() {
            blockList.classMap = ClassMap.from(value);
            print("CHANGED ${value}");
            print(blockList.classMap.classes);
          });
        });
      }
    );
  }
  
  /*
  void _showClassMapList() async {
    Map<String, bool> _isEditing = new Map();
    blockList.classMap.forEach((b, c) => _isEditing[b] = false);
    String valueText = "";
    Map<String, String> _replacements = {};
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: new Text("Edit Class Map"),
              content: Container(
                width: 500,
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemCount: blockList.classMap.length,
                  itemBuilder: (BuildContext context, int index) {
                    String block = blockList.classMap.keys.elementAt(index);
                    String subject = blockList.classMap[block];
                    return Container(
                      child: Center(child: Row(
                          children: <Widget>[
                            Column( children: <Widget>[
                                Text('${block}',
                                  style: TextStyle(fontSize: 18), textAlign: TextAlign.left), 
                            ]),
                            Expanded(child: Container(
                                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  child: _replacements.containsKey(block) ? Text(_replacements[block]!) : Text('${subject}'),
                                  style: _replacements.containsKey(block) ?
                                  ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow)) : null,
                                  onPressed: () {
                                    setState(() {
                                        valueText = subject;
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: Text('Change subject ${block}'),
                                            content: TextFormField(
                                              initialValue: subject,
                                              onChanged: (value) {
                                                setState(() {
                                                    valueText = value;
                                                });
                                              },
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  setState(() {
                                                      Navigator.pop(context);
                                                  });
                                                },
                                              ),
                                              ElevatedButton(
                                                child: Text('Save'),
                                                onPressed: () => {
                                                  setState(() {
                                                      _replacements[block] = valueText;
                                                      Navigator.pop(context);
                                        }) },), ], ), );
                                  } ); },
                                  
                                )
                              )
                            )
                    ])));
                  }
                )
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() {
                        _replacements.forEach((k, v) => blockList.setClass(k, v));
                        Navigator.of(context).pop(); });
                  }
                ),
              ]
      ); } ); }
    );
    setState(() { print("WERD Saving results"); });


  }

void _showClassMapTable() {
    List<TableRow> rows = [];
    blockList.classMap.forEach((b, c) => rows.add(
        TableRow(children: [
            Container(padding: EdgeInsets.fromLTRB(20, 5, 20, 5), child: Text(b)),
            Container(padding: EdgeInsets.fromLTRB(20, 5, 20, 5), child: Text(c)),
    ])));

    print(rows);

    showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: new Text("Edit Class Map"),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
                // 2: FixedColumnWidth(64),
              },
              border: TableBorder.all(color: Colors.black26, width: 1),
              children: rows)
          )
        )
      )
    );
  }
  
  void _showClassMapEditable() {
    List cols = [
      {"title": "Block", "widthFactor": 0.05, "key": "block"},
      {"title": "Class Name", "key": "class"},
    ];

    List<Map<String, String>> rows = [];
    blockList.classMap.forEach((b, c) => rows.add({"block": b, "class": c}));

    print(rows);

    showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: new Text("Edit Class Map"),
        content: Center(
          child: Editable(
            //key: _editableKey,
            columns: cols,
            rows: rows,
            //zebraStripe: true,
            //stripeColor1: Colors.blue[50]?,
            //stripeColor2: Colors.grey[200]?,
            onRowSaved: (value) {
              print(value);
            },
            onSubmitted: (value) {
              print(value);
            },
            borderColor: Colors.blueGrey,
            tdStyle: TextStyle(fontWeight: FontWeight.bold),
            //trHeight: 80,
            thStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            thAlignment: TextAlign.center,
            //thVertAlignment: CrossAxisAlignment.end,
            //thPaddingBottom: 3,
            //showSaveIcon: true,
            //saveIconColor: Colors.black,
            //showCreateButton: true,
            tdAlignment: TextAlign.left,
            //tdEditableMaxLines: 100, // don't limit and allow data to wrap
            //tdPaddingTop: 0,
            //tdPaddingBottom: 14,
            //tdPaddingLeft: 10,
            //tdPaddingRight: 8,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.all(Radius.circular(0))),
          )
        )
      )
    );
  }
*/
  
  AppBar calendarAppBar() {
    return AppBar(
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () => _blockPageController.previousPage(duration: kTabScrollDuration, curve: Curves.ease), // _decrementDate(),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(Icons.keyboard_arrow_right),
          onPressed: () => _blockPageController.nextPage(duration: kTabScrollDuration, curve: Curves.ease), //_incrementDate(),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(Icons.settings_accessibility),
          onPressed: () => _showClassMapList(),
        ),
        
      ]
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: calendarAppBar(),

      body: Center(
        child: _blockListView(),
      ),
    );
  }
}
