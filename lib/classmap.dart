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

  String toJson() {
    return '''
{ 
  "id": "${classId}", 
  "name": "${className}", 
  "room": "${room}", 
  "notes": "${notes}", 
  "blocks": ["''' + blocks.toList().join('","') + '"]\n }';
  }

  factory ClassInfo.mergeClassInfos(ClassInfo first, ClassInfo second) {
    return ClassInfo(
      "", // No ID for merged classes, they aren't real
      first.className + " / " + second.className,
      first.room + " / " + second.room,
      Set.from(first.blocks).union(second.blocks),
      first.notes + " / " + second.notes);
  }

  factory ClassInfo.from(ClassInfo c) {
    return ClassInfo(c.classId, c.className, c.room, Set.from(c.blocks), c.notes);
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
      c.blocks.forEach((b) {
        blockToClassMap[b] = c;
        if (b == "B1") { print("UpdateBlockTo ${b} / ${c} in ${blockToClassMap}"); }
        //blockToClassMap.containsKey(b) ? ClassInfo.mergeClassInfos(
        //    blockToClassMap[b]!, c) : c;
      }
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
    String cmJson = ' [ ';
    List<String> cs = [];
    inClassMap.classes.forEach((k, v) => cs.add(v.toJson()));
    cmJson += cs.join(',\n ') + ']';
    classMap.parseClassMapFromJson(cmJson);
    classMap._updateBlockToClassMap();
    return classMap;
  }
}
