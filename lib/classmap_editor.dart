import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import 'blockinfo.dart';
import 'classmap.dart';


class ClassMapEditor extends StatefulWidget {
  ClassMapEditor({
      Key? key,
      required ClassMap this.classMap,
      required this.onChanged,
  }) : super(key: key);

  final ClassMap classMap;
  ClassMap outMap = new ClassMap();
  final ValueChanged<ClassMap> onChanged;
  Set<String> classesChanged = {};
  Set<String> classesDeleted = {};

  _CmEditorState createState() => _CmEditorState();
}

class _CmEditorState extends State<ClassMapEditor> {
  
  AlertDialog _editSingleClassDialog(BuildContext context, ClassInfo inClass) {
    ClassInfo c = ClassInfo.from(inClass);
    Map<String, List<String>> blockNames = Map();
    Map<String, List<bool>> toggleStates = new Map();
    BlockInfo.blockPrefixes.forEach((p) {
        blockNames[p] = [];
        toggleStates[p] = [];
        for (var i = 1; i <= BlockInfo.blocksPerPrefix; i++) {
          blockNames[p]!.add("${p}${i}");
          toggleStates[p]!.add(c.blocks.contains("${p}${i}"));
        }
    });

    //print(toggleStates["A"]);
    return AlertDialog(
      title: Text('Change subject'),
      content: StatefulBuilder( builder: (context, setState) {
          return Column(
            children: [
              TextFormField(
                initialValue: c.className,
                decoration: const InputDecoration(
                  icon: Icon(Icons.label_important),
                  labelText: 'Class Name',
                ),
                onChanged: (value) {
                  c.className = value;
                },
              ),
              TextFormField(
                initialValue: c.room,
                decoration: const InputDecoration(
                  icon: Icon(Icons.my_location),
                  labelText: 'Room',
                ),
                onChanged: (value) {
                  c.room = value;
                },
              ),
              TextFormField(
                initialValue: c.notes,
                decoration: const InputDecoration(
                  icon: Icon(Icons.notes),
                  labelText: 'Notes',
                ),
                onChanged: (value) {
                  c.notes = value;
                },
              ),
              Container(
                width: 10,
                height: 50
              ),
              Expanded( child: Container(
                  width: 300,
                  height: 300,
                  alignment: Alignment.centerRight,
                  child:  ListView.builder(
                    shrinkWrap: true, //just set this property
                    padding: const EdgeInsets.all(8.0),
                    itemCount: BlockInfo.blockPrefixes.length,
                    itemBuilder:  (BuildContext context, int index) {
                      var pfx = BlockInfo.blockPrefixes[index];
                      return ToggleButtons(
                        children: <Widget>[
                          Text("${pfx}1"), Text("${pfx}2"), Text("${pfx}3"), Text("${pfx}4"),
                        ],
                        isSelected: toggleStates[pfx]!,
                        onPressed: (int index) {
                          setState(() {
                              toggleStates[pfx]![index] = !toggleStates[pfx]![index];
                              for (var i = 0; i < blockNames[pfx]!.length; i++) {
                                if (toggleStates[pfx]![i]) c.blocks.add(blockNames[pfx]![i]);
                                else c.blocks.remove(blockNames[pfx]![i]);
                              }
                          });
                          print("100: C is ${c}");
                          print("101: inClass is ${inClass}");
                        },
                      );
                    }
              ) ) )
            ]
          );
        }
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            print("CANCEL: C is ${c}");
            print("CANCEL: inClass is ${inClass}");
            Navigator.pop(context, null);
          },
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            print("OK: C is ${c}");
            print("OK: inClass is ${inClass}");
            setState(() {
                inClass = ClassInfo.from(c);
                widget.classesChanged.add(c.classId);
            });
            Navigator.pop(context, c);
          }
        ),
      ] 
    );
    print(c);
  }

  Widget _touchableSingleClassRow(BuildContext context, int index) {
    var classKey = widget.outMap.classes.keys.elementAt(index);
    ClassInfo c = widget.outMap.classes[classKey]!;
    return InkWell(
      onTap: () {
        showDialog<ClassInfo>(
          context: context,
          builder: (BuildContext context) =>
          _editSingleClassDialog(context, c)
        ).then((v) {
            setState(() {
                if (v != null) {
                  print(v.toJson());
                  widget.outMap.classes[classKey] = ClassInfo.from(v);
                  c = ClassInfo.from(v);
                  //inClass = ClassInfo.from(v);
                }
            });
        });
      },
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(),
          1: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(
            decoration: widget.classesChanged.contains(c.classId) ? const BoxDecoration(color: Colors.yellow) : null,
            children: <Widget>[
              TableCell(
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.className,
                      style: TextStyle(fontSize: 18,
                        decoration: widget.classesDeleted.contains(c.classId) ? TextDecoration.lineThrough : null,
                        color: widget.classesDeleted.contains(c.classId) ? Colors.red : null,
                      ),
                      textAlign: TextAlign.left),
                    Text('Room: ' + c.room, style:
                      TextStyle(fontSize: 12,
                        decoration: widget.classesDeleted.contains(c.classId) ? TextDecoration.lineThrough : null,
                        color: widget.classesDeleted.contains(c.classId) ? Colors.red : null,
                    ), textAlign: TextAlign.left),
                  ]
                )
              ),
              TableCell(child: Column( crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                    Text((() { var r = c.blocks.toList(); r.sort(); return r.join(', ');})(), style: TextStyle(fontSize: 14), textAlign: TextAlign.left),
                    Text(c.notes, style: TextStyle(fontSize: 12), textAlign: TextAlign.left),
                  ]
                )
              ),
            ]
          ),
        ]
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    widget.outMap = ClassMap.from(widget.classMap);
    var c = widget.outMap.classes;
    
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
                return _touchableSingleClassRow(context, index);
              }
            )
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                print("CANCEL: cMap is ${c}");
                print("CANCEL: classMap is ${widget.outMap.classes}");
                Navigator.of(context).pop();
              }
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                    //_replacements.forEach((k, v) => blockList.setClass(k, v));
                    Navigator.of(context).pop(); });
                print("OK: cMap is ${c}");
                print("OK: classMap is ${widget.outMap.classes}");
              }
            ),
          ]
        );
      }
    );
  }
}

