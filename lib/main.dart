import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardMatchingGame(),
    );
  }
}

class Card {
  final String imagePath;
  bool isFaceUp;
  bool isMatched;

  Card({
    required this.imagePath,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class CardMatchingGame extends StatefulWidget {
  @override
  _CardMatchingGameState createState() => _CardMatchingGameState();
}

class _CardMatchingGameState extends State<CardMatchingGame>
    with SingleTickerProviderStateMixin {
  List<Card> _cards = [];
  Card? _firstCard;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    List<String> images = [
      'assets/salad.png',
      'assets/spaghetti.png',
      'assets/task manager.png',
      'assets/visual.png',
      'assets/salad.png',
      'assets/spaghetti.png',
      'assets/task manager.png',
      'assets/visual.png',
    ];

    images.shuffle();
    _cards = images.map((image) => Card(imagePath: image)).toList();
  }

  void _onCardTap(int index) async {
    if (_isProcessing || _cards[index].isFaceUp || _cards[index].isMatched) {
      return;
    }

    setState(() {
      _cards[index].isFaceUp = true;
    });

    if (_firstCard == null) {
      // First card is tapped
      _firstCard = _cards[index];
    } else {
      // Second card is tapped
      _isProcessing = true;

      await Future.delayed(const Duration(seconds: 1));

      if (_firstCard!.imagePath == _cards[index].imagePath) {
        // Cards match
        setState(() {
          _firstCard!.isMatched = true;
          _cards[index].isMatched = true;
        });
        checkForWinCondition();
      } else {
        // Cards do not match
        setState(() {
          _firstCard!.isFaceUp = false;
          _cards[index].isFaceUp = false;
        });
      }

      _firstCard = null;
      _isProcessing = false;
    }
  }

  void checkForWinCondition() {
    if (_cards.every((card) => card.isMatched)) {
      showVictoryMessage();
    }
  }

  void showVictoryMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Congrats, Young One!"),
          content: const Text("You've managed to clear this trial!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text("Would you like to Play Again"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      _firstCard = null;
      _initializeCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 196, 2),
        title: const Text('Same - The Card Game'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
        children: [
          const SizedBox(height: 200), // Space above the grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        
                        color: _cards[index].isFaceUp
                            ? const Color.fromARGB(255, 246, 236, 144)
                            : Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _cards[index].isFaceUp || _cards[index].isMatched
                          ? Image.asset(_cards[index].imagePath)
                          : Container(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
