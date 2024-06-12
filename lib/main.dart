import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerwall_booster_beta/model/token_provider.dart';
import 'package:powerwall_booster_beta/view/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TokenProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Powerwall Booster',
      theme: ThemeData.dark().copyWith(
        hintColor: Color.fromARGB(255, 32, 169, 27),
      ),
      home: WelcomeScreen(),
    );
  }
}
