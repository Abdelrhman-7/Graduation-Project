import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int replacedFilesCount = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('GoogleFonts.lexend')) {
      content = content.replaceAll('GoogleFonts.lexend', 'GoogleFonts.cairo');
      file.writeAsStringSync(content);
      replacedFilesCount++;
      print('Replaced in ${file.path}');
    }
  }

  print('Total files modified: $replacedFilesCount');
}
