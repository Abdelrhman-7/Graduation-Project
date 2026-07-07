import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var content = file.readAsStringSync();
    
    // Find backgroundImage: NetworkImage(...) and append onBackgroundImageError
    var newContent = content.replaceAllMapped(
      RegExp(r'backgroundImage:\s*(.*?NetworkImage\(.*?\)),\s*(?!\s*onBackgroundImageError)', dotAll: true),
      (match) {
        String matchStr = match.group(0)!;
        if (matchStr.contains('onBackgroundImageError')) return matchStr;
        return '${match.group(1)},\nonBackgroundImageError: (e, s) {},';
      }
    );

    // Find image: NetworkImage(...) and append onError
    newContent = newContent.replaceAllMapped(
      RegExp(r'image:\s*(.*?NetworkImage\(.*?\)),\s*(?!\s*onError)', dotAll: true),
      (match) {
        String matchStr = match.group(0)!;
        if (matchStr.contains('onError')) return matchStr;
        return '${match.group(1)},\nonError: (e, s) {},';
      }
    );

    if (content != newContent) {
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
    }
  }
}
