// Module Importations
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pionsurcarre/components/dead_piece.dart';
import 'package:pionsurcarre/components/piece.dart';
import 'package:pionsurcarre/helper/helper_methods.dart';
import 'package:pionsurcarre/components/square.dart';
import 'package:pionsurcarre/components/texture_pack_manager.dart';

// Iphone 14 Pro Max: 1170 x 2532

// Classe principale du jeu
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}
class _GameBoardState extends State<GameBoard> {

  // Liste en deux dimensions pour representer l'echequier
  late List<List<ChessPiece?>> board; 

  // Variable pour la case selectionnée
  ChessPiece? selectedPiece; // No piece selected by default

  int selectedRow = -1;
  int selectedCol = -1;

  // Liste de mouvement valide pour une pièce selectionnée - Chaque mouvement sera représenté par une liste de coordonnées
  List<List<int>> validMoves = [];

  // Liste des pièces capturées
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  // Tours de jeu
  bool isWhiteTurn = true; // Par défaut, c'est le tour des blancs

  // Position initiale des rois (pour la vérification de l'échec et mat)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false; // Indique si le roi est en échec

  // Mods
  bool modZombies = false;
  bool modFullQueen = false;
  bool modSpawn = false;

  int totalTurns = 0; // Incrémente à chaque tour

  final List<ChessPieceType> spawnableTypes = [
    ChessPieceType.pawn,
    ChessPieceType.knight,
    ChessPieceType.bishop,
    ChessPieceType.tower,
    ChessPieceType.queen,
  ];


  // Initialisation de l'échiquier
  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));
  
    // Placement des pions
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false);
      newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true);
    }

    // Placement des tours
    newBoard[0][0] = ChessPiece(type: ChessPieceType.tower, isWhite: false);
    newBoard[0][7] = ChessPiece(type: ChessPieceType.tower, isWhite: false);
    newBoard[7][0] = ChessPiece(type: ChessPieceType.tower, isWhite: true,);
    newBoard[7][7] = ChessPiece(type: ChessPieceType.tower, isWhite: true,);

    // Placement des knights
    newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
    newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
    newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true);
    newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true);

    // Placement des bishops
    newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);

    // Placement de la reine
    newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false);
    newBoard[7][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true);

    // Placement du roi
    newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false);
    newBoard[7][4] = ChessPiece(type: ChessPieceType.king, isWhite: true);

    // Placement de piece aléatoire pour tester les valides mouvements
    // newBoard[4][4] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: TexturePackManager.getPieceImage(ChessPieceType.knight, true));
    // newBoard[5][5] = ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: TexturePackManager.getPieceImage(ChessPieceType.pawn, false));
    // newBoard[3][3] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: TexturePackManager.getPieceImage(ChessPieceType.bishop, true));
    // newBoard[2][2] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: TexturePackManager.getPieceImage(ChessPieceType.queen, false));
    // newBoard[1][1] = ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: TexturePackManager.getPieceImage(ChessPieceType.king, true));

    board = newBoard;
  }

  // Selection d'une piece
  void pieceSelected(int row, int col) {
    setState(() {

      // Aucune pièce n'est selectionnée
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      
      // Il y a une pièce selectionnée, mais le joueur clique sur la même case
      else if (selectedRow == row && selectedCol == col) {
        selectedPiece = null; // Désélectionner la pièce
        selectedRow = -1; // Réinitialiser la ligne sélectionnée
        selectedCol = -1; // Réinitialiser la colonne sélectionnée
        validMoves.clear(); // Effacer les mouvements valides
      }

      // Si une pièce est selectionnée, mais le joueur clique sur une case occupée par une pièce de la même couleur
      else if (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col]; // Sélectionner la nouvelle pièce
        selectedRow = row; // Mettre à jour la ligne sélectionnée
        selectedCol = col; // Mettre à jour la colonne sélectionnée
      }
      
      
      // Si une pièce est selectionné, et que le joueur clique sur une case valide, déplacer la pièce
      else if (selectedPiece != null && validMoves.any((move) => move[0] == row && move[1] == col)) {
        movePiece(row, col);
      }

      // Calculer les mouvements valides
      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  // Calculer les mouvements valides
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece, List<List<ChessPiece?>> board) {
    if (piece == null) return [];

    List<List<int>> candidateMoves = [];

    int direction = piece.isWhite ? -1 : 1; // Direction du mouvement

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Mouvement du pion 1 : Si la case devant est vide, peut avanver d'une case
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Mouvement du pion 2 : Si le pion est en position initiale, il peut avancer de deux cases
        if ((piece.isWhite && row == 6) || (!piece.isWhite && row == 1)) {
          if (isInBoard(row + 2 * direction, col)
              && board[row + 2 * direction][col] == null
              && board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Mouvement du pion 3 : Si la case diagonale est occupée par une pièce adverse, il peut capturer
        if (isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPieceType.tower:
        // Mouvement de la tour : horizontal et vertical
        var directions = [
          [-1, 0], // Haut
          [1, 0],  // Bas
          [0, -1], // Gauche
          [0, 1]   // Droite
        ];
        
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break; // Sortir si en dehors de l'échiquier
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // Ajouter la case occupée par une pièce adverse
              }
              break; // Arrêter si une pièce est rencontrée
            }
            candidateMoves.add([newRow, newCol]); // Ajouter la case vide
            i++;
          }
        }
        
        break;
      
      case ChessPieceType.knight:
        // Mouvement du cavalier : en "L"
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1]
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // Ajouter la case occupée par une pièce adverse
            }
          continue;
        }
        candidateMoves.add([newRow, newCol]); // Ajouter la case vide
        }

        break;

      case ChessPieceType.bishop:
        // Mouvement du fou : diagonale
        var directions = [
          [-1, -1], // Haut-Gauche
          [-1, 1],  // Haut-Droite
          [1, -1],  // Bas-Gauche
          [1, 1]    // Bas-Droite
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break; // Sortir si en dehors de l'échiquier

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // Ajouter la case occupée par une pièce adverse
              }
              break; // Arrêter si une pièce est rencontrée
            }

            candidateMoves.add([newRow, newCol]); // Ajouter la case vide
            i++;
          }
        }

        break;
      
      case ChessPieceType.queen:
        // Mouvement de la reine : combinaison de la tour et du fou
        var directions = [
          [-1, 0], // Haut
          [1, 0],  // Bas
          [0, -1], // Gauche
          [0, 1],  // Droite
          [-1, -1], // Haut-Gauche
          [-1, 1],  // Haut-Droite
          [1, -1],  // Bas-Gauche
          [1, 1]    // Bas-Droite
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break; // Sortir si en dehors de l'échiquier
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // Ajouter la case occupée par une pièce adverse
              }
              break; // Arrêter si une pièce est rencontrée
            }
            candidateMoves.add([newRow, newCol]); // Ajouter la case vide
            i++;
          }
        }

        break;

      case ChessPieceType.king:
        // Mouvement du roi : une case dans toutes les directions
        var directions = [
          [-1, 0], // Haut
          [1, 0],  // Bas
          [0, -1], // Gauche
          [0, 1],  // Droite
          [-1, -1], // Haut-Gauche
          [-1, 1],  // Haut-Droite
          [1, -1],  // Bas-Gauche
          [1, 1]    // Bas-Droite
        ];

        for (var move in directions) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) continue; // Sortir si en dehors de l'échiquier
          
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // Ajouter la case occupée par une pièce adverse
            }
            continue; // Ne pas ajouter la case occupée par une pièce
          }
          candidateMoves.add([newRow, newCol]); // Ajouter la case vide
        }

        break;

    }
    return candidateMoves;
  }

  // Calculer les vraies mouvements valides
  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece, board);

    // Pour chaque mouvement candidat, vérifier si le roi reste en sécurité
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // Simuler le mouvement
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move); // Ajouter le mouvement valide
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    
    return realValidMoves;
  }

  void resetGame() {
    setState(() {
      _initializeBoard(); // Réinitialiser l'échiquier
      selectedPiece = null; // Aucune pièce sélectionnée
      selectedRow = -1; // Réinitialiser la ligne sélectionnée
      selectedCol = -1; // Réinitialiser la colonne sélectionnée
      validMoves.clear(); // Effacer les mouvements valides
      whitePiecesTaken.clear(); // Effacer les pièces blanches capturées
      blackPiecesTaken.clear(); // Effacer les pièces noires capturées
      isWhiteTurn = true; // Recommencer avec le tour des blancs
      whiteKingPosition = [7, 4]; // Réinitialiser la position du roi blanc
      blackKingPosition = [0, 4]; // Réinitialiser la position du roi noir
      checkStatus = false; // Réinitialiser l'état de échec
    });
  }

  // Mod ZOMBIES - Créer une pièce à partir d'une autre
  ChessPiece createPieceFromOther(ChessPiece source, bool isWhite) {
    switch (source.type) {
      case ChessPieceType.queen:
        return ChessPiece(type: ChessPieceType.queen, isWhite: isWhite);
      case ChessPieceType.tower:
        return ChessPiece(type: ChessPieceType.tower, isWhite: isWhite);
      case ChessPieceType.bishop:
        return ChessPiece(type: ChessPieceType.bishop, isWhite: isWhite);
      case ChessPieceType.knight:
        return ChessPiece(type: ChessPieceType.knight, isWhite: isWhite);
      case ChessPieceType.pawn:
        return ChessPiece(type: ChessPieceType.pawn, isWhite: isWhite);
      default:
        return source;
    }
  }

  // Mod Full Reine
  void applyFullQueenMod() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.type != ChessPieceType.king) {
          board[row][col] = ChessPiece(type: ChessPieceType.queen, isWhite: piece.isWhite);
        }
      }
    }
    setState(() {}); // Mettre à jour l'affichage
  }

  void toggleFullQueenMod() {
    setState(() {
      modFullQueen = !modFullQueen;
      if (modFullQueen) {
        applyFullQueenMod();
      }
    });
  }

  // Mod Spawn
  ChessPiece getRandomPiece(bool isWhite) {
  final random = Random();
  final type = spawnableTypes[random.nextInt(spawnableTypes.length)];

  switch (type) {
    case ChessPieceType.pawn:
      return ChessPiece(type: ChessPieceType.pawn, isWhite: isWhite);
    case ChessPieceType.knight:
      return ChessPiece(type: ChessPieceType.knight, isWhite: isWhite);
    case ChessPieceType.bishop:
      return ChessPiece(type: ChessPieceType.bishop, isWhite: isWhite);
    case ChessPieceType.tower:
      return ChessPiece(type: ChessPieceType.tower, isWhite: isWhite);
    case ChessPieceType.queen:
      return ChessPiece(type: ChessPieceType.queen, isWhite: isWhite);
    default:
      throw Exception("Type non valide");
  }
}


  // Mouvement
  void movePiece(int newRow, int newCol) {
    ChessPiece? capturedPiece = board[newRow][newCol];
    ChessPiece? piece = selectedPiece;

    // Si la nouvelle case contient une pièce adverse : capture
    if (capturedPiece != null) {
      if (capturedPiece.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }

      // Mod ZOMBIES - La pièce prend la forme de celle qu'elle capture (sauf roi)
      if (modZombies &&
          piece != null &&
          piece.type != ChessPieceType.king &&
          capturedPiece.type != ChessPieceType.king) {
        piece = createPieceFromOther(capturedPiece, piece.isWhite);
      }
    }

    // Mise à jour des positions du roi si besoin
    if (piece != null && piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Déplacement de la pièce (modifiée ou non)
    board[newRow][newCol] = piece;
    board[selectedRow][selectedCol] = null;

    // Vérifie si le roi est en échec
    checkStatus = isKingInCheck(!isWhiteTurn);

    // Clear la sélection et les coups valides
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves.clear();
    });

    // Vérifie s’il y a échec et mat
    if (isCheckMate(!isWhiteTurn)) {
      String winner = isWhiteTurn ? "Noir" : "Blanc";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Échec et Mat"),
          content: Text("Les $winner ont gagné !"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text("Rejouer"),
            ),
          ],
        ),
      );
    }

    // Changement de tour
    isWhiteTurn = !isWhiteTurn;
    totalTurns++;

    if (modSpawn && totalTurns % 7 == 0) {
      // Blancs : colonne 7 (droite) ligne 7
      if (board[7][7] == null) {
        board[7][7] = getRandomPiece(true); // true = blanc
      }
      if (board[7][0] == null) {
        board[7][0] = getRandomPiece(true); // false = blanc
      }

      // Noirs : colonne 7 (droite) ligne 0
      if (board[0][7] == null) {
        board[0][7] = getRandomPiece(false); // false = noir
      }
      if (board[0][0] == null) {
        board[0][0] = getRandomPiece(false); // false = noir
      }
    }
  }


  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Vérifier les mouvements valides de toutes les pièces adverses
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.isWhite != isWhiteKing) {
          List<List<int>> moves = calculateRealValidMoves(row, col, piece, false);
          for (var move in moves) {
            if (move[0] == kingPosition[0] && move[1] == kingPosition[1]) {
              return true; // Le roi est en échec
            }
          }
        }
      }
    }
    return false; // Le roi n'est pas en échec
  }

  bool simulatedMoveIsSafe(ChessPiece? piece, int startRow, int startCol, int endRow, int endCol) {
    
    // Sauvegarder le plateau
    ChessPiece? originalPiece = board[endRow][endCol];

    // Si c'est le roi, sauvegarder sa position actuel et mettre à jour la nouvelle
    List<int> originalKingPosition = [];
    if (piece != null && piece.type == ChessPieceType.king) {
      
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
      
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // Simuler le mouvement
    board[endRow][endCol] = piece; // Placer la pièce à la nouvelle position
    board[startRow][startCol] = null; // Effacer l'ancienne position

    // Vérifier si le roi est en échec après le mouvement
    bool kingInCheck = isKingInCheck(piece != null && piece.isWhite);

    // Restaurer le plateau à son état initial
    board[startRow][startCol] = piece; // Remettre la pièce à sa position initiale
    board[endRow][endCol] = originalPiece; // Remettre la pièce capturée à sa position initiale

    // Si la pièce etait le roi, restaurer sa position initiale
    if (piece != null && piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition;
      } else {
        blackKingPosition = originalKingPosition;
      }
    }

    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {

    // Vérifier si le roi est en échec
    if (!isKingInCheck(isWhiteKing)) {
      return false; // Pas de échec, donc pas de échec et mat
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue; // Ignorer les cases vides ou les pièces de la couleur adverse
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);
        
        if (pieceValidMoves.isNotEmpty) {
          // Si une pièce peut se déplacer, le roi n'est pas en échec et mat
          return false;
        }
      }
    }

    return true; // Le roi est en échec et mat
  }

  Widget buildModButton(String label, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.orange : Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 18 * 2.0), // même taille que packName
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  void showGiveUpDialog(bool isWhite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${!isWhite ? 'White' : 'Black'} gives up!"),
        content: const Text("Do you want to restart or quit?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text("Restart"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: ValueListenableBuilder<String>(
        valueListenable: TexturePackManager.currentPackNotifier,
        builder: (context, currentPack, _) {
          return Column(
            children: [
              const SizedBox(height: 20),

              // 1. Logo au centre en haut
              Center(child: TexturePackManager.logoText()),

              const SizedBox(height: 20),

              // 2. Boutons pack + mods
              Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: TexturePackManager.packs.map((packName) {
                      final bool isSelected = packName == currentPack;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.orange : Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(fontSize: 36),
                        ),
                        onPressed: () {
                          TexturePackManager.changePack(packName);
                        },
                        child: Text(
                          packName[0].toUpperCase() + packName.substring(1),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      buildModButton("Zombies", modZombies, () {
                        setState(() => modZombies = !modZombies);
                      }),
                      buildModButton("Full Queen", modFullQueen, () {
                        setState(() {
                          modFullQueen = !modFullQueen;
                          if (modFullQueen) {
                            applyFullQueenMod(); // Appelle la fonction qui transforme les pièces
                          }
                        });
                      }),
                      buildModButton("Spawn", modSpawn, () {
                        setState(() => modSpawn = !modSpawn);
                      }),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                height: 70, // hauteur fixe
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.4), // fond semi-transparent
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: whitePiecesTaken.map((piece) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: DeadPiece(
                          imagePath: piece.imagePath,
                          isWhite: true,
                          size: 50, // forcer une taille constante
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Ligne au-dessus de l’échiquier
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tour des noirs/blancs (rotated)
                      Flexible(
                        child: Transform.rotate(
                          angle: 3.14159,
                          child: TexturePackManager.styledText(isWhiteTurn),
                        ),
                      ),

                      // Bouton abandon noir (rotated)
                      Transform.rotate(
                        angle: 3.14159,
                        child: ElevatedButton(
                          onPressed: () {
                            showGiveUpDialog(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text(
                            "Black Give Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Échiquier (85% largeur)
              Center(
                child: SizedBox(
                  width: screenWidth * 0.85,
                  height: screenWidth * 0.85, // carré
                  child: ValueListenableBuilder<String>(
                    valueListenable: TexturePackManager.currentPackNotifier,
                    builder: (context, currentPack, _) {
                      return GridView.builder(
                        itemCount: 64,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                        itemBuilder: (context, index) {
                          final row = index ~/ 8;
                          final col = index % 8;

                          final isSelected = selectedRow == row && selectedCol == col;
                          final isValidMove = validMoves.any((m) => m[0] == row && m[1] == col);

                          return Square(
                            isWhite: isWhite(index),
                            piece: board[row][col],
                            isSelected: isSelected,
                            isValidMove: isValidMove,
                            onTap: () => pieceSelected(row, col),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 6. Ligne sous l’échiquier
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: TexturePackManager.styledText(isWhiteTurn)),

                      ElevatedButton(
                        onPressed: () {
                          showGiveUpDialog(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          "White Give Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pions noirs capturés (en bas sous l’échiquier)
              Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: blackPiecesTaken.map((piece) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: DeadPiece(
                          imagePath: piece.imagePath,
                          isWhite: false,
                          size: 50,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }



}


