import 'package:flutter/material.dart';
import 'piece.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 64,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemBuilder: (context, index) {
        bool isLight = (index % 2 == 0);
        String piece = ''; // Logique pour déterminer la pièce (ex : 'king.png')
        
        return Container(
          color: isLight ? Colors.white : Colors.black,
          child: piece.isEmpty ? null : ChessPiece(imageAsset: 'assets/chess_pieces/$piece'),
        );
      },
    );
  }
}
