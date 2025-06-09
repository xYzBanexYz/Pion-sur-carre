import 'package:flutter/material.dart';
import 'package:pionsurcarre/components/piece.dart';

// Gestionnaire de packs de textures
class TexturePackManager {
  static final List<String> packs = ['classic', 'minecraft', 'christmas', 'invisible'];

  static String currentPack = 'classic'; // par défaut

  // Pour notifier les changements de pack aux widgets qui écoutent
  static final ValueNotifier<String> currentPackNotifier = ValueNotifier<String>(currentPack);

  // Fonction pour obtenir l'image d'une pièce en fonction du pack
  static String getPieceImage(ChessPieceType pieceType, bool isWhite) {
    final pieceName = pieceType.name; // ex: "pawn"
    final color = isWhite ? 'white' : 'black';
    final path = 'assets/textures/pieces/$currentPack/${currentPack}_${color}_$pieceName.png';
    return path;
  }

  static String getPlatesImage(bool isWhite) {
    return 'assets/textures/plates/$currentPack/${currentPack}_${isWhite ? 'white' : 'black'}_case.png';
  }

  // Fonction pour changer le pack de textures
  static void changePack(String packName) {
    currentPack = packName;
    currentPackNotifier.value = packName;
  }

  static Widget styledText(bool isWhiteTurn) {
    String text;
    String fontFamily;
    double fontSize;
    Color fillColor;

    switch (currentPack.toLowerCase()) {
      case "minecraft":
        fontFamily = "Minecraft";
        fontSize = 80;
        text = !isWhiteTurn ? "Tour de la Pierre" : "Tour de la Terre";
        fillColor = !isWhiteTurn ? const Color(0xFF888888) : const Color(0xFF7B4B20);
        break;

      case "christmas":
        fontFamily = "Christmas";
        fontSize = 100;
        text = !isWhiteTurn ? "Tour du Vert" : "Tour du Rouge";
        fillColor = !isWhiteTurn ? Colors.green : Colors.red;
        break;

      case "invisible":
        fontFamily = "Invisible";
        fontSize = 80;
        text = !isWhiteTurn ? "Tour du Haut" : "Tour du Bas";
        fillColor = !isWhiteTurn ? const Color(0xFFAAAAAA) : const Color(0xFF555555);
        break;

      case "classic":
      default:
        fontFamily = "Classic";
        fontSize = 100;
        text = isWhiteTurn ? "Tour des Blancs" : "Tour des Noirs";
        fillColor = isWhiteTurn ? Colors.white : Colors.black;
        break;
    }

    final bool noStroke = currentPack.toLowerCase() == "classic" && isWhiteTurn;

    return Stack(
      children: [
        if (!noStroke)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.white,
            ),
          ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: fillColor,
          ),
        ),
      ],
    );
  }

  static Widget logoText() {
    String fontFamily;
    double fontSize;
    Color fillColor;

    switch (currentPack.toLowerCase()) {
      case "minecraft":
        fontFamily = "Minecraft";
        fontSize = 100;
        fillColor = const Color(0xFFAAAAAA);
        break;
      case "christmas":
        fontFamily = "Christmas";
        fontSize = 100;
        fillColor = Colors.green;
        break;
      case "invisible":
        fontFamily = "Invisible";
        fontSize = 100;
        fillColor = Colors.grey;
        break;
      case "classic":
      default:
        fontFamily = "Classic";
        fontSize = 100;
        fillColor = Colors.white;
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Contour
        Text(
          "Pion sur carre",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = Colors.black,
          ),
        ),
        // Remplissage
        Text(
          "Pion sur carre",
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
