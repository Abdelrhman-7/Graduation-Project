import 'dart:io';

void main() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('http://medicalsystem111.runasp.net/swagger/v1/swagger.json'));
  final response = await request.close();
  final stringData = await response.transform(const SystemEncoding().decoder).join();
  File('swagger_raw.json').writeAsStringSync(stringData);
  print('Saved swagger_raw.json');
}
