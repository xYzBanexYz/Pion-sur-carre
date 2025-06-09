import 'package:flutter/material.dart';
import 'package:pionsurcarre/game_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pion sur Carré',
      theme: ThemeData.dark(), // Mode sombre
      home: GameBoard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

