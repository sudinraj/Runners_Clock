import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:run/_determine_position.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:run/stats.dart';

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

  double latitude = 0;
  double longtitude = 0;

//to calculate speed and distance
  double runDistance = 0.0;
  String runD = "0.0";
  double walkDistance = 0.0;
  String walkD = "0.0";
  double runTime = 0.0;
  double walkTime = 0.0;
  String runSpeed = "0.0";
  String walkSpeed = "0.0";
  StreamSubscription? getPositionSubscription;

  String location = "Nothing yet";

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
            //sets up the walk timer if run timer had ended
            if(activity == "Run"){
              setTime = walking;
              remainingTime = walking;
              activity = 'Walk';
            }
            //sets up the run timer if walk timer had ended
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
            //keeps track of time
            if(activity == "Run"){
              runTime++;
            }
            else{
              walkTime++;
            }
          });
        }
    } else{
      timer.cancel();
    }
  });
}

@override
  void dispose() {
    getPositionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //setting the value of each variable
    walking = widget.walking;
    running = widget.running;
    if(!set){
      setUp();
      setTime = running;
      remainingTime = running;
      set = true;
      startTimer();

      //Keeps track of the location, every time the latitud or longtitude changes, it runs the code in the {}
      locationSettings = AndroidSettings(accuracy: LocationAccuracy.best, intervalDuration: const Duration(milliseconds: 5),);
      getPositionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
        if(latitude== 0 && longtitude == 0)
        {
          latitude = position.latitude;
          longtitude = position.longitude;
        }
        else{
          if(activity == "Run"){
            runDistance += Geolocator.distanceBetween(latitude, longtitude, position.latitude, position.longitude);
            //runDistance += Geolocator.distanceBetween(double.parse(latitude.toStringAsFixed(6)), double.parse(longtitude.toStringAsFixed(6)), double.parse(position.latitude.toStringAsFixed(6)), double.parse(position.longitude.toStringAsFixed(6)));
            runD = runDistance.toStringAsFixed(2);
            runSpeed = (runDistance/runTime).toStringAsFixed(2);
          }
          else{
            walkDistance += Geolocator.distanceBetween(latitude, longtitude, position.latitude, position.longitude);
            //walkDistance += Geolocator.distanceBetween(double.parse(latitude.toStringAsFixed(6)), double.parse(longtitude.toStringAsFixed(6)), double.parse(position.latitude.toStringAsFixed(6)), double.parse(position.longitude.toStringAsFixed(6)));
            walkD = walkDistance.toStringAsFixed(2);
            walkSpeed = (walkDistance/walkTime).toStringAsFixed(2);
          }
          latitude = position.latitude;
          longtitude = position.longitude;
          location = "$location \n $longtitude $latitude";
        }
      });
    }
    
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
                    //goes back to the home screen
                    //Navigator.pop(context);

                    //goes to stats page
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => Stats(runDistance, runD, walkDistance, walkD, runTime, walkTime, runSpeed, walkSpeed)));
                    done = true;
                    dispose();
                  },
                  child: Text('Stop'),
                ),

                //Display speed and distance
                SizedBox(height: 30,),
                Text("Run distance: $runD Meters",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),

                Text("Run Speed: $runSpeed m/s",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),

                SizedBox(height: 30,),

                Text("Walk distance: $walkD Meters",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),

                Text("Walk Speed: $walkSpeed m/s",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),
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
