import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:async';

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
        //sets the starting page
        home: MyHomePageState(),
      ),
    );
  }
}

//for when you change something and you need to notify other variables, methods, etc.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

//To turn a stateless widget stateful
class MyHomePageState extends StatefulWidget {
  const MyHomePageState({super.key});

  @override
  State<MyHomePageState> createState() => _MyHomePageStateState();
}

//main page where you set the time
class _MyHomePageStateState extends State<MyHomePageState> {
  int _currentWalkValue = 2;
  int _currentRunValue = 2;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Select how much time to run, and how much time to walk:',
            style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 189, 5, 5),), 
            textAlign: TextAlign.center,
            ),
//Sized Box adds whitespace
            SizedBox(height: 30),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Walk:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
//The number Picking Wheel
                  NumberPicker(
                    value: _currentWalkValue,
                    minValue: 1,
                    maxValue: 60,
                    onChanged: (value) =>setState(() =>_currentWalkValue = value),
                  ),
                ]),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Run:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                  NumberPicker(
                    value: _currentRunValue,
                    minValue: 1,
                    maxValue: 60,
                    onChanged: (value) =>setState(() =>_currentRunValue = value),
                  ),
                ])
              ],
            ),
            
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
                Navigator.push(context, CupertinoPageRoute(builder: (context) => RunningPageState(_currentWalkValue, _currentRunValue)));
              },
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}


class RunningPageState extends StatefulWidget {
  final int walking ;
  final int running ;
  const RunningPageState(this.walking, this.running, {super.key});

  @override
  State<RunningPageState> createState() => _RunningPageStateState();
}

class _RunningPageStateState extends State<RunningPageState> {
  
  Timer? _timer;
  bool done = false;
  bool set = false;
  late int remainingTime;
  late int SetTime;
  late int walking;
  late int running;

//TODO: Timer is not working properly; The count down is too fast, and also make it able to be restart after going to first screen

  void startTimer(){
  const oneSec = Duration(seconds: 10);
  _timer = Timer.periodic(oneSec, (Timer timer){
    if(!done){
      if (remainingTime <= 0) {
          setState(() {
            timer.cancel();
            if(SetTime == running){
              SetTime = walking;
              remainingTime = walking;
            }
            else{
              SetTime = running;
              remainingTime = running;
            }
            startTimer();
          });
        } else {
          setState(() {
            remainingTime--;
            print(remainingTime);
          });
        }
    } else{
      timer.cancel();
    }
  });
}

@override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    walking = widget.walking;
    running = widget.running;
    if(!set){
      SetTime = running;
      remainingTime = running;
      set = true;
    }
    startTimer();
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Minutes:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                //A widget that I made for displaying things
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
            
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
                Navigator.pop(context);
                done = true;
                //_timer.dispose();
              },
              child: Text('Stop'),
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