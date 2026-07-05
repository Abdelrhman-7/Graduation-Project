import 'dart:io';

void main() {
  final file = File('scratch/logcat.txt');
  final bytes = file.readAsBytesSync();
  final content = String.fromCharCodes(bytes.buffer.asUint16List());
  final lines = content.split('\n');
  print('Total logcat lines: ${lines.length}');
  
  final targetLines = <String>[];
  for (int i = 0; i < lines.length; i++) {
    final lower = lines[i].toLowerCase();
    if (lower.contains('getallschedules') || lower.contains('get all schedules')) {
      targetLines.add(lines[i]);
      if (i + 1 < lines.length) targetLines.add(lines[i+1]);
      if (i + 2 < lines.length) targetLines.add(lines[i+2]);
      if (i + 3 < lines.length) targetLines.add(lines[i+3]);
    }
  }

  print('Found ${targetLines.length} matching lines:');
  for (final l in targetLines.take(100)) {
    print(l);
  }
}
