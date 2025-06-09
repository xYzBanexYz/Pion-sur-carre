import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Game',
      theme: ThemeData.dark(),  // Dark mode
      home: const ChessHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChessHomePage extends StatefulWidget {
  const ChessHomePage({super.key});

  @override
  _ChessHomePageState createState() => _ChessHomePageState();
}

class _ChessHomePageState extends State<ChessHomePage> {
  List<List<String>> board = List.generate(
    8,
    (index) => List.generate(8, (index) => ''),
  );

  @override
  void initState() {
    super.initState();
    setupBoard();
  }

  void setupBoard() {
    board[0] = ['tower', 'knight', 'bishop', 'queen', 'king', 'bishop', 'knight', 'tower']; // Pièces noires
    board[1] = List.generate(8, (index) => 'pawn'); // Pions noirs
    board[6] = List.generate(8, (index) => 'PAWN'); // Pions blancs
    board[7] = ['TOWER', 'KNIGHT', 'BISHOP', 'QUEEN', 'KING', 'BISHOP', 'KNIGHT', 'TOWER']; // Pièces blanches
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu d\'Échecs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Changer le pack de textures
              setState(() {
                TexturePackManager.changePack(TexturePackManager.currentPack == 'classic' ? 'christmas' : 'classic');
              });
            },
          ),
        ],
      ),
      body: ChessBoard(board: board, onPieceMoved: onPieceMoved),
    );
  }

  void onPieceMoved(int fromRow, int fromCol, int toRow, int toCol) {
    setState(() {
      board[toRow][toCol] = board[fromRow][fromCol];
      board[fromRow][fromCol] = '';
    });
  }
}


class ChessBoard extends StatelessWidget {
  final List<List<String>> board;
  final Function(int, int, int, int) onPieceMoved;

  const ChessBoard({super.key, required this.board, required this.onPieceMoved});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final col = index % 8;
          final isDark = (row + col) % 2 == 1;
          final piece = board[row][col];
          
          return GestureDetector(
            onTap: () {
              // Implémenter la logique de mouvement ici
              print('Case sélectionnée: $row, $col');
            },
            child: Container(
              color: isDark ? Colors.brown[700] : Colors.grey[300],
              child: piece.isNotEmpty
                  ? Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        heightFactor: 0.7,
                        child: Image.asset(
                          TexturePackManager.getPieceImage(
                            piece.toLowerCase(),
                            piece == piece.toUpperCase(),
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : null,
            ),

          );
        },
      ),
    );
  }
}


//! Gestionnaire de packs de textures
class TexturePackManager {
  static String currentPack = 'classic'; // Par défaut, on utilise le pack classique

  // Fonction pour obtenir l'image d'une pièce en fonction du pack
  static String getPieceImage(String pieceType, bool isWhite) {
    return 'assets/textures/pieces/$currentPack/${currentPack}_${isWhite ? 'white' : 'black'}_$pieceType.png';
  }

  // Fonction pour changer le pack de textures
  static void changePack(String packName) {
    currentPack = packName;
  }
}