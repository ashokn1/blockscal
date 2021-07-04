import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'classmap.dart';


class BlockInfo {
  static const List<String> blockPrefixes = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];
  static const int blocksPerPrefix = 4;
  

  final String blockName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final bool allDay;

  final Map<String, Map<bool, List<Color>>> _blockColors = {
    'A': {
      true:  [Colors.white, Colors.brown[700]!],
      false: [Colors.grey[200]!, Colors.brown[300]!],
    },
    'B': {
      true:  [Colors.white, Colors.orange[700]!],
      false: [Colors.grey[700]!, Colors.orange[300]!],
    },
    'C': {
      true:  [Colors.white, Colors.yellow[700]!],
      false: [Colors.grey[700]!, Colors.yellow[300]!],
    },
    'D': {
      true:  [Colors.white, Colors.green[700]!],
      false: [Colors.grey[200]!, Colors.green[300]!],
    },
    'E': {
      true:  [Colors.white, Colors.blue[700]!],
      false: [Colors.grey[200]!, Colors.blue[300]!],
    },
    'F': {
      true:  [Colors.white, Colors.purple[700]!],
      false: [Colors.grey[200]!, Colors.purple[300]!],
    },
    'G': {
      true:  [Colors.white, Colors.red[700]!],
      false: [Colors.grey[200]!, Colors.red[300]!],
    },
    'H': {
      true:  [Colors.white, Colors.cyan[700]!],
      false: [Colors.grey[200]!, Colors.cyan[300]!],
    },
    'I': {
      true:  [Colors.white, Colors.pink[700]!],
      false: [Colors.grey[200]!, Colors.pink[300]!],
    },
  };


  String? blockCode;
  String blockTitle = "";
  String? blockSubtitle;
  TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.normal,
          fontStyle : FontStyle.normal,
          fontSize: 24,
          color: Colors.grey[500]!);
  TextStyle textSubStyle = TextStyle(
          fontWeight: FontWeight.normal,
          fontStyle : FontStyle.normal,
          fontSize: 20);
  Color bgColor = Colors.grey[200]!;
  
  void updateColors() {
    if (allDay) {
      textStyle = textStyle.copyWith(fontStyle : FontStyle.italic);
    }
    
    var now = DateTime.now();
    bool isActive = startTime.isBefore(now) && endTime.isAfter(now);
    if (blockCode != null) {
      List<Color> myColor = _blockColors[blockCode![0]]![isActive]!;
      textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: myColor[0]);
      textSubStyle = textSubStyle.copyWith(color: myColor[0]);
      bgColor = myColor[1];
    }
  }

  void updateClassInfo(ClassMap classMap) {
    updateColors();
    if (blockCode != null) {
      if (classMap.blockToClassMap.containsKey(blockCode!)) {
        // Store the block name in blockSubtitle if there is more than the class code
        if (blockName.length > 2) { blockSubtitle = blockName; } else { blockSubtitle = null; }
        blockTitle = blockCode! + " : " + classMap.blockToClassMap[blockCode!]!.className;
      }
    }
  }
  
  BlockInfo(String inBlockName, String inStartTime, String inEndTime, String? inAllDay) :
  blockName = inBlockName.trim(),
  startTime = DateTime.parse(inStartTime),
  endTime = DateTime.parse(inEndTime),
  allDay = (inAllDay != null),
  durationMinutes = DateTime.parse(inEndTime).difference(DateTime.parse(inStartTime)).inMinutes,
  blockTitle = inBlockName,
  blockCode = inBlockName.startsWith(new RegExp("[A-Z][0-9]")) ? inBlockName.substring(0, 2) : null;
  
  factory BlockInfo.fromJson(Map<String, dynamic> json) {
    return BlockInfo(json['name'], json['startTime'], json['endTime'], json['allDay']);
  }
}

class Blocks {
  // Blocks list
  Map<DateTime, List<BlockInfo>> blockInfo = new Map();
  bool blockInfoParsed = false;

  // Class map
  //Map<String, dynamic> classMap = new Map();
  ClassMap classMap = new ClassMap();
  bool classMapParsed = false;

  void parseBlockScheduleFromJson(String blockInfoListJson) {
    final parsed = json.decode(blockInfoListJson).cast<Map<String, dynamic>>();
    List<BlockInfo> blockList = parsed.map<BlockInfo>((json) => BlockInfo.fromJson(json)).toList();
    
    blockList.forEach((block) => blockInfo.update(
        DateUtils.dateOnly(block.startTime),
        (dynamic blocks) => blocks + [block],
        ifAbsent: () => [block]));
    
    // Sort all the entries by time.
    blockInfo.forEach((date, blocks) =>
      blocks.sort((a, b) {
          if (a.allDay && !b.allDay) {
            return -1;
          } else if (b.allDay && !a.allDay) {
            return 1;
          } else {
            return a.startTime.compareTo(b.startTime);
          }
        }
      )
    );
    blockInfoParsed = true;
  }

  /*
  void setClass(String block, String subject) {
    classMap[block] = subject;
  }
*/
  
  void parseClassMapFromJson(String classMapJson) {
    classMap.parseClassMapFromJson(classMapJson);
    //classMap  = json.decode(classMapJson);
    classMapParsed = true;
  }

  List<BlockInfo> forDate(DateTime date) {
    if (!blockInfo.containsKey(date)) {
      return [];
    }
    blockInfo[date]!.forEach((b) => b.updateClassInfo(classMap));
    return blockInfo[date]!;
  }

  Blocks() : blockInfo = new Map();
  
  factory Blocks.fromJson(String blockInfoListJson) {
    Blocks blocks  = Blocks();
    blocks.parseBlockScheduleFromJson(blockInfoListJson);
    return blocks;
  }
}
