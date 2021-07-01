import 'package:tuple/tuple.dart';
import 'dart:convert';

class ClassInfo {
  String classId = "";
  String className = "";
  String room = "";
  String notes = "";
  Set<dynamic> blocks = {};

  ClassInfo(String? inClassId, String? inClassName, String? inRoom, Set<dynamic> inBlocks, String? inNotes) :
  classId = inClassId != null ? inClassId : "",
  className = inClassName != null ? inClassName : "",
  room = inRoom != null ? inRoom : "",
  blocks = inBlocks != null ? inBlocks : {},
  notes = inNotes != null ? inNotes : "";

  String toString() {
    return "{ id: ${classId}, class: ${className}, room: ${room}, blocks: ${blocks}, notes: ${notes} }";
  }
  
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(json['id'], json['name'], json['room'], json['blocks'].toSet(), json['notes']);
  }

  factory ClassInfo.mergeClassInfos(ClassInfo first, ClassInfo second) {
    return ClassInfo(
      "", // No ID for merged classes, they aren't real
      first.className + " / " + second.className,
      first.room + " / " + second.room,
      Set.from(first.blocks).union(second.blocks),
      first.notes + " / " + second.notes);
  }
}

class ClassMap {
  // List of all classes, keyed by ID
  Map<String, ClassInfo> classes = new Map();

  // Reverse map of block to class, keyed by Block
  Map<String, ClassInfo> blockToClassMap = new Map();

  bool classMapParsed = false;

  void _updateBlockToClassMap() {
    classes.forEach((i, c) =>
      c.blocks.forEach((b) =>
        blockToClassMap[b] =
        blockToClassMap.containsKey(b) ? ClassInfo.mergeClassInfos(blockToClassMap[b]!, c) : c
    ));;
  }
  
  void addOrUpdateClass(ClassInfo newClass) {
    classes[newClass.classId] = newClass;
    _updateBlockToClassMap();
  }

  void parseClassMapFromJson(String classMapJson) {
    final parsed = json.decode(classMapJson);
    final classList = parsed.map<ClassInfo>((json) => ClassInfo.fromJson(json)).toList();
    classes = Map.fromIterable(classList, key: (e) => e.classId, value: (e) => e);
    _updateBlockToClassMap();
    classMapParsed = true;
  }

  static from(ClassMap inClassMap) {
    ClassMap classMap  = new ClassMap();
    classMap.classes = new Map.from(inClassMap.classes);
    classMap.blockToClassMap = new Map.from(inClassMap.blockToClassMap);
    return classMap;
  }
}
