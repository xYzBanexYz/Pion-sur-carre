import 'package:flutter/material.dart';
import 'package:pionsurcarre/components/piece.dart';
import 'package:pionsurcarre/components/texture_pack_manager.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
 
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de la case (plateau)
            if (isSelected)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    TexturePackManager.getPlatesImage(isWhite),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    color: Colors.green.withOpacity(0.5),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ],
              )
            else if (isValidMove)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    TexturePackManager.getPlatesImage(isWhite),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              )
            else // Si la case est pas selectionnée
              Image.asset(
                TexturePackManager.getPlatesImage(isWhite),
                fit: BoxFit.cover,
              ),
            
            // Image de la pièce (si présente)
            if (piece != null)
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.7,
                  child: Image.asset(
                    piece!.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}