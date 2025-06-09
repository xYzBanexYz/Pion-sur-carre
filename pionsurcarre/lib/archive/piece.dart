import 'package:flutter/material.dart';

class ChessPiece extends StatelessWidget {
  final String imageAsset;

  const ChessPiece({super.key, required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(imageAsset);
  }
}
