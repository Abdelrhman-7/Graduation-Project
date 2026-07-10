import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }
  
  int count = 0;
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      if (content.contains('clinicbook.runasp.net')) {
        final newContent = content.replaceAll('clinicbook.runasp.net', 'mediconnect.somee.com');
        entity.writeAsStringSync(newContent);
        count++;
      }
    }
  }
  print('Successfully updated URLs in $count files.');
}
