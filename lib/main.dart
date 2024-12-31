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
//initial values for the number wheel
  int _currentWalkValue = 1;
  int _currentRunValue = 1;
  int _currentWalkMinValue = 2;
  int _currentRunMinValue = 2;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color.fromARGB(255, 202, 201, 201),Colors.black],
          ),
        ),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
//The number Picking Wheel
                  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Min',
                        style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),

                        NumberPicker(
                          textStyle: TextStyle(color: const Color.fromARGB(255, 30, 186, 233)),
                          selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 7, 85, 255), fontSize: 30),
                          value: _currentWalkValue,
                          minValue: 0,
                          maxValue: 60,
                          onChanged: (value) =>setState(() =>_currentWalkValue = value),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        SizedBox(height: 25,),
                        Text(':',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sec',
                        style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),

                        NumberPicker(
                          textStyle: TextStyle(color: const Color.fromARGB(255, 30, 186, 233)),
                          selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 7, 85, 255), fontSize: 30),
                          value: _currentWalkMinValue,
                          minValue: 1,
                          maxValue: 60,
                          onChanged: (value) =>setState(() =>_currentWalkMinValue = value),
                        ),
                      ],
                    ),
                  ],
                ),
                ]),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Run:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Min',
                        style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),

                        NumberPicker(
                          textStyle: TextStyle(color: Colors.pink),
                          selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 255, 7, 7), fontSize: 30),
                          value: _currentRunValue,
                          minValue: 0,
                          maxValue: 60,
                          onChanged: (value) =>setState(() =>_currentRunValue = value),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        SizedBox(height: 25,),
                        Text(':',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text('Sec',
                        style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),

                        NumberPicker(
                          textStyle: TextStyle(color: Colors.pink),
                          selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 255, 7, 7), fontSize: 30),
                          value: _currentRunMinValue,
                          minValue: 1,
                          maxValue: 60,
                          onChanged: (value) =>setState(() =>_currentRunMinValue = value),
                        ),
                      ],
                    ),
                  ],
                ),
                ])
              ],
            ),
            
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
                Navigator.push(context, CupertinoPageRoute(builder: (context) => RunningPageState((_currentWalkValue*60 + _currentWalkMinValue), (_currentRunValue*60 + _currentRunMinValue))));
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
  String activity = 'Run';
  bool done = false;
  bool set = false;
  late int remainingTime;
  late int setTime;
  late int walking;
  late int running;

//Timer Starts with the run time, then it starts a countdown for the walk timer, then it loops that until stopped.
//TODO: Make noise when timer runs out
  void startTimer(){
  const oneSec = Duration(seconds: 1);
  _timer = Timer.periodic(oneSec, (timer){
    if(!done){
  //when the timer is 0, it checks if it was the running timer or the walking timer, then starts the next timer
      if (remainingTime <= 0) {
          setState(() {
            timer.cancel();
            if(setTime == running){
              setTime = walking;
              remainingTime = walking;
              activity = 'Walk';
            }
            else{
              setTime = running;
              remainingTime = running;
              activity = 'Run';
            }
            startTimer();
          });
        } else {
          setState(() {
            remainingTime--;
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
    //setting the value of each variable
    walking = widget.walking;
    running = widget.running;
    if(!set){
      setTime = running;
      remainingTime = running;
      set = true;
      startTimer();
    }
    
    var appState = context.watch<MyAppState>();

    return Scaffold(
//using container for background colors and stuff
      body: Container(
//sets the width and height to be the size of the screen
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color.fromARGB(255, 202, 201, 201),Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(activity,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
            Text('Seconds:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                  TimeShow(remainingTime: remainingTime),
            
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

class TimeShow extends StatelessWidget {
  const TimeShow({
    super.key,
    required this.remainingTime,
  });

  final int remainingTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onTertiary,
    );

    return Text(remainingTime.toString(), style: style);
  }
}