import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  final double size;

  const DeadPiece({
    super.key,
    required this.imagePath,
    required this.isWhite,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: isWhite ? Colors.white : null,
      colorBlendMode: isWhite ? BlendMode.modulate : null,
    );
  }
}
