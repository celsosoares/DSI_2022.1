import 'dart:async';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:my_app/lista_repository.dart';

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final tabela = ListaRepository.tabela;

  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  late WordPair _wordPair;
  bool cardMode = false;

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
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
          if (index < 8) {
            return _buildRow(tabela[index].name, index);
          } else {
            return Column();
          }
        },
      );
    } else {
      return _cardVizualizaton();
    }
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
        if (index < 8) {
          return _buildRow(tabela[index].name, index);
        } else {
          return Column();
        }
      },
    );
  }

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

  Widget _buildRow(WordPair pair, int index) {
    final alreadySaved = _saved.contains(pair);

    return Dismissible(
      background: Container(
        color: Colors.black,
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
            icon: alreadySaved
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
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
          onTap: () => _toEditon(context, pair, index)),
    );
  }

  _toEditon(context, pair, int index) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      _wordPair = pair;
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit item'),
        ),
        body: Container(
            color: Colors.white, child: _buildForm(context, pair, index)),
      );
    }));
  }

  _buildForm(context, pair, int index) {
    String first = '';
    String second = '';
    return Form(
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 16.0,
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'First word'),
            onChanged: (newValue) {
              first = newValue;
            },
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Second word'),
            onChanged: (value) {
              second = value;
            },
          ),
          SizedBox(
            width: double.infinity,
          ),
          ElevatedButton(
            onPressed: () => _save(context, index, first, second),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context, int index, first, second) {
    setState(() {
      _wordPair = WordPair(first, second);
      tabela[index].name = _wordPair;
    });
  }
}
