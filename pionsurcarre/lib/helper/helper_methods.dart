bool isWhite(int index) {
  int x = index ~/ 8; // this gives us the interger division ie.row
  int y = index % 8; // this gives us the remainder ie. column
        
  // alternate colors for each square
  bool isWhite = (x + y) % 2 ==0;

  return isWhite;
}

bool isInBoard(int raw, int column) {
  return (raw >= 0 && raw < 8 && column >= 0 && column < 8);
}