import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
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
        title: 'Runners Clock',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 62, 198, 247)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var button = 'Start';
  var state = true; //when true it should be showing start

  void click() {
    if(state == true){
      button = 'Stop';
    }
    else {
      button = 'Start';
    }
    state = !state;
    notifyListeners();
  }
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var buttonState = appState.button;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Select how much time to run, and how much time to walk:',
            style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),

            SizedBox(height: 10),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Minutes:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                  BigCard(pair: pair),
                ]),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Seconds:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                  BigCard(pair: pair),
                ])
              ],
            ),
            
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
                appState.click();
              },
              child: Text(buttonState),
            ),
          ],
        ),
      ),
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
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(pair.asLowerCase, style: style),
      ),
    );
  }
}