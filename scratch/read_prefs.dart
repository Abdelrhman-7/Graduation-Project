import 'dart:io';

void main() {
  final file = File('scratch/shared_prefs.xml');
  final bytes = file.readAsBytesSync();
  // Decode utf16le
  final decoded = String.fromCharCodes(bytes.buffer.asUint16List());
  print(decoded);
}
