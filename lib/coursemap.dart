import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';


class CourseMap {
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
  };

  final List<Color> _blockDefaultColors = [Colors.grey[500]!, Colors.grey[200]!];

  Tuple2<TextStyle, Color> getColors() {
    RegExp exp = RegExp("^[ABCDEFGH][0-9]", caseSensitive: true, multiLine: false);
    var now = DateTime.now();
    bool isActive = startTime.isBefore(now) && endTime.isAfter(now);
    if (!exp.hasMatch(blockName)) {
      //print("No match for " + blockName);
      return Tuple2<TextStyle, Color>(
        TextStyle(
          fontWeight: FontWeight.normal,
          fontStyle : allDay ? FontStyle.italic : FontStyle.normal,
          fontSize: 24,
          color: _blockDefaultColors[0]),
        _blockDefaultColors[1]);
    }
    List<Color> myColor = _blockColors[blockName[0]]![isActive]!;
    //print("COLOR match for " + blockName + ": " + blockName[0]);
    return Tuple2<TextStyle, Color>(
      TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: myColor[0]),
      myColor[1]);
  }
  
  BlockInfo(String inBlockName, String inStartTime, String inEndTime, String? inAllDay) :
  blockName = inBlockName,
  startTime = DateTime.parse(inStartTime),
  endTime = DateTime.parse(inEndTime),
  allDay = (inAllDay != null),
  durationMinutes = DateTime.parse(inEndTime).difference(DateTime.parse(inStartTime)).inMinutes;
  
  factory BlockInfo.fromJson(Map<String, dynamic> json) {
    //print("Loading " + json.toString());
    return BlockInfo(json['name'], json['startTime'], json['endTime'], json['allDay']);
  }
}


List<BlockInfo> parseBlockInfoList(String blockInfoListJson) {
  final parsed = json.decode(blockInfoListJson).cast<Map<String, dynamic>>();
  
  return parsed.map<BlockInfo>((json) => BlockInfo.fromJson(json)).toList();
}

Map<DateTime, List<BlockInfo>> parseBlockInfo(String blockInfoListJson) {
  final blockList = parseBlockInfoList(blockInfoListJson);
  Map<DateTime, List<BlockInfo>> blockInfo = new Map();
  //parsed.forEach((json) {
  //    print("Hello");
  //    BlockInfo block = BlockInfo.fromJson(json);
  //    blockInfo[DateUtils.dateOnly(block.startTime)].add(block);
  //});
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
  
  return blockInfo;
}
