import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  bool cardMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
              onPressed: (() {
                setState(() {
                  if (cardMode == false) {
                    cardMode = true;
                    debugPrint('$cardMode');
                  } else if (cardMode == true) {
                    cardMode = false;
                    debugPrint('$cardMode');
                  }
                });
              }),
              tooltip:
                  cardMode ? 'List Vizualization' : 'Card Mode Vizualization',
              icon: const Icon(Icons.auto_fix_normal_outlined),
            ),
          ],
        ),
        body: _buildSuggestions(cardMode));
  }

  Widget _buildSuggestions(bool cardMode) {
    if (cardMode == false) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], index);
        },
      );
    } else {
      return _cardVizualizaton();
    }
  }

  Widget _buildRow(WordPair pair, int index) {
    final alreadySaved = _saved.contains(pair);

    return Dismissible(
      background: Container(
        color: Colors.purple,
      ),
      onDismissed: (direction) {
        setState(() {
          _suggestions.remove(pair);
        });
      },
      key: Key(pair.hashCode.toString()),
      child: ListTile(
        title: Text(pair.asPascalCase, style: _biggerFont),
        trailing: IconButton(
          icon:
              alreadySaved ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          color: alreadySaved ? Colors.red : null,
          onPressed: () {
            setState(() {
              if (alreadySaved) {
                Icon(
                  Icons.favorite_border,
                  color: null,
                );
                _saved.remove(pair);
              } else {
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                );
                _saved.add(pair);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _cardVizualizaton() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 8),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return Column(
          children: [_buildRow(_suggestions[index], index)],
        );
      },
    );
  }
}
