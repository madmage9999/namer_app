import 'dart:js';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  
}
// MyHomePage is the navigation bar
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('No Widget for selected index');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A random idea:'),
            Text('Hi Emma'),
            SizedBox(height: 20,),
            BigCard(pair: pair),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  }, 
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Next'),
                  ),
                  
                ),
                SizedBox(width: 20,),
                ElevatedButton.icon(onPressed: () {
                  appState.toggleFavorites();
                },
                icon: Icon(icon),
                label: Text('Add'),
                )
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final List<WordPair> favorite = appState.favorites;
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Favorites here"),
          Padding(
            padding:const EdgeInsets.all(20),
            child: Text('You have ' '${favorite.length} favorites'),
          ),
          SizedBox(height: 20,),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            itemCount: favorite.length,
            itemBuilder: (BuildContext context, int index) {
              return ElevatedButton(onPressed: () {
                appState.toggleFavorites(); 
              },
                child: Center(child: Text('${favorite[index]}'))
              );

              // return Container(
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //       color: Color(0xFFFF5FFF), // Border colors
              //     ),
              //     borderRadius: BorderRadius.all(Radius.circular(20)) // Rounded Edges
              //   ),
              //   height: 50,
              //   child: Center(child: Text('${favorite[index]}')),
              // );
            })
        ],
      ),)
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(color: theme.colorScheme.onPrimary,);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(27.0),
        child: Text(pair.asCamelCase,
        style: style,
        semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}