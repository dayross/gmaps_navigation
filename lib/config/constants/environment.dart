import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String apiKey =
      dotenv.env['API_KEY'] ?? 'No está configurado el API_KEY';
  static initEnvironment() async => await dotenv.load(fileName: '.env');
}
