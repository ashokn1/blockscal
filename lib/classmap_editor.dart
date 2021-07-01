import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import 'classmap.dart';

class ClassMapEditor extends StatelessWidget {
  ClassMapEditor({
      Key? key,
      required ClassMap this.classMap,
  }) : super(key: key);
  
  final ClassMap classMap;

  @override
  Widget build(BuildContext context) {
    ClassMap cMap = ClassMap.from(classMap);
    var c = cMap.classes;
    
    print(c);
    print("WERD");

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: new Text("Edit Class Map"),
          content: Container(
            width: 500,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: c.length,
              itemBuilder: (BuildContext context, int index) {
                var key = c.keys.elementAt(index);
                return Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: IntrinsicColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        TableCell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(c[key]!.className, style: TextStyle(fontSize: 18), textAlign: TextAlign.left),
                              Text(c[key]!.blocks.toList().join(','), style: TextStyle(fontSize: 12), textAlign: TextAlign.left),
                            ]
                          )
                        ),
                        TableCell(child: Column( crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                              Text('Room ' + c[key]!.room, style: TextStyle(fontSize: 12), textAlign: TextAlign.left),
                              Text(c[key]!.notes, style: TextStyle(fontSize: 12), textAlign: TextAlign.left),
                            ]
                          )
                        ),
                      ]
                    ),
                  ]
                  );
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
                      //_replacements.forEach((k, v) => blockList.setClass(k, v));
                      Navigator.of(context).pop(); });
                }
              ),
            ]
          );
        }
      );
    }
  }


/*



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
                      ]
                    )
                  )
                );
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
        );
      }
    }

*/
/*
  
  @override
  _ClassMapEditor createState() => _ClassMapEditor();
}

class _ClassMapEditor extends State<ClassMapEditor> {

  
  
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
