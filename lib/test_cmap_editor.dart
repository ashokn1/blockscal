import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import 'blockinfo.dart';
import 'classmap.dart';


class TestClassMapEditor extends StatefulWidget {
  TestClassMapEditor({
      Key? key,
      required ClassMap this.classMap,
      required this.onSaved,
  }) : super(key: key);

  final ClassMap classMap;
  final ValueChanged<ClassMap> onSaved;
  Set<String> classesChanged = {};
  Set<String> classesDeleted = {};

  _CmEditorState createState() => _CmEditorState();
}

class _CmEditorState extends State<TestClassMapEditor> {

  AlertDialog _editSingleClassDialog(BuildContext context, ClassInfo inClass) {
    ClassInfo c = ClassInfo.from(inClass);
    Map<String, List<String>> blockNames = Map();
    Map<String, List<bool>> toggleStates = new Map();

    return AlertDialog(
      title: Text('Change class information'),
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
            });
            Navigator.pop(context, c);
          }
        ),
      ]
    );
    print(c);
  }

  Widget _touchableSingleClassRow(BuildContext context, String classId) {
    return InkWell(
      onTap: () {
        print("IN" + widget.classMap.classes[classId]!.toJson());
        showDialog<ClassInfo>(
          context: context,
          builder: (BuildContext context) =>
          _editSingleClassDialog(context, widget.classMap.classes[classId]!)
        ).then((v) {
            setState(() {
                if (v != null) {
                  widget.classMap.classes[classId] = ClassInfo.from(v);
                  widget.classesChanged.add(classId);
                  print("OUT ${widget.classMap.classes}");
                } else {
                  print("Cancelled");
                }

            });
        });
      },
      child: Table(
        children: <TableRow>[
          TableRow(
            decoration: widget.classesChanged.contains(classId) ? const BoxDecoration(color: Colors.yellow) : null,
            children: <Widget>[
              TableCell(
                child: Text(widget.classMap.classes[classId]!.className),
              ),
            ]
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    //widget.classMap = ClassMap.from(widget.classMap);
    // var c = widget.classMap.classes;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: new Text("Edit Class Map"),
          content: Container(
            width: 500,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: widget.classMap.classes.length,
              itemBuilder: (BuildContext context, int index) {
                return _touchableSingleClassRow(context, widget.classMap.classes.keys.elementAt(index));
              }
            )
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                //print("CANCEL: cMap is ${c}");
                print("CANCEL: classMap is ${widget.classMap.classes}");
                Navigator.of(context).pop();
              }
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                    //_replacements.forEach((k, v) => blockList.setClass(k, v));
                    Navigator.of(context).pop(); });
                //print("OK: cMap is ${c}");
                print("OK: classMap is ${widget.classMap.classes}");
                widget.onSaved(widget.classMap);
              }
            ),
          ]
        );
      }
    );
  }
}
