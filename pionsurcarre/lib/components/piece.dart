import 'package:pionsurcarre/components/texture_pack_manager.dart';

enum ChessPieceType { pawn, tower, knight, bishop, queen, king}

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;

  ChessPiece({
    required this.type,
    required this.isWhite,
  });

  String get imagePath => TexturePackManager.getPieceImage(type, isWhite);
}
