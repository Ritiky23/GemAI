import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:splash_screen/geminichat.dart';
import 'package:splash_screen/config.dart';

void main() {

    Gemini.init(apiKey: geminiApiKey);
  
    runApp(new HomeScreen());

}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.red, hintColor: Colors.grey),
      debugShowCheckedModeBanner: false,
      home:GeminiChat(),
    );
  }
}