import 'package:run/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

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
  final player = AudioPlayer();

//Timer Starts with the run time, then it starts a countdown for the walk timer, then it loops that until stopped.
  void startTimer(){
  const oneSec = Duration(seconds: 1);
  _timer = Timer.periodic(oneSec, (timer){
    if(!done){
  //when the timer is 0, it checks if it was the running timer or the walking timer, then starts the next timer
      if(remainingTime == 1){
      //Keeps the audio from stopping other media playing
      player.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          //gainTransientMayDuck makes it so that the audio fades out a little when the alarm is playing.
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ));
      //plays the sound whenever there is 1 second left(1 turning into 0)
        player.play(AssetSource('sound.mp3'));
      }
      
      if (remainingTime <= 0) {
          setState(() {
            timer.cancel();
            if(activity == "Run"){
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
        child: Center(
          child: SingleChildScrollView(
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
                    //goes back to the home screen
                    Navigator.pop(context);
                    done = true;
                  },
                  child: Text('Stop'),
                ),
              ],
            ),
          ),
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
