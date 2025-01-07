import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:run/_determine_position.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:run/database_helper.dart';
import 'package:run/logging.dart';
import 'package:run/pages/stats.dart';

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
  bool change = false;
  late int remainingTime;
  late int setTime;
  late int walking;
  late int running;

  final player = AudioPlayer();

  double latitude = 0;
  double longtitude = 0;

//to calculate average speed and distance
  double runDistance = 0.0;
  String runD = "0.0";
  double walkDistance = 0.0;
  String walkD = "0.0";
  double runTime = 0.0;
  double walkTime = 0.0;
  String runSpeed = "0.0";
  String walkSpeed = "0.0";
  StreamSubscription? getPositionSubscription;

  int totalMinute = 0;
  int totalSecond = 0;

//for getting the stats for the run/walk during the countdown
  double currentRunDistance = 0.0;
  double currentRunTime = 0.0;
  String currentRunSpeed = "0.0";
  String currentRunD = "0.0";
  double currentWalkDistance = 0.0;
  double currentWalkTime = 0.0;
  String currentWalkSpeed = "0.0";
  String currentWalkD = "0.0";

  late logging session;

  //String location = "Nothing yet";

//Timer Starts with the run time, then it starts a countdown for the walk timer, then it loops that until stopped.
  void startTimer(){
  const oneSec = Duration(seconds: 1);
  _timer = Timer.periodic(oneSec, (timer){
    if(!done){
  //when the timer is 0, it checks if it was the running timer or the walking timer, then starts the next timer
      if(remainingTime == 2){
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
      
      if (remainingTime <= 1 || change == true) {
          setState(() {
            if(remainingTime<=1){
              //adds a second to not lose time when changing the timers
              timerCount();
            }
            change = false;
            timer.cancel();
            //sets up the walk timer if run timer had ended
            if(activity == "Run"){
              setTime = walking;
              remainingTime = walking;
              activity = 'Walk';
              //resets the Walk stats for the cycle
              currentWalkDistance = 0.0;
              currentWalkTime = 0.0;
            }
            //sets up the run timer if walk timer had ended
            else{
              setTime = running;
              remainingTime = running;
              activity = 'Run';
              //resets the Run stats for the cycle
              currentRunDistance = 0.0;
              currentRunTime = 0.0;
            }
            startTimer();
          });
        } else {
          setState(() {
            remainingTime--;
            //keeps track of time
            timerCount();
          });
        }
    } else{
      timer.cancel();
    }
  });
}
  void timerCount(){
    if(activity == "Run"){
        runTime++;
        currentRunTime++;
      }
      else{
        walkTime++;
        currentWalkTime++;
      }
    //keeps track of total time in minutes and seconds
    totalSecond++;
    if(totalSecond >= 60){
      totalMinute++;
      totalSecond = 0;
    }
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

            currentRunDistance += Geolocator.distanceBetween(latitude, longtitude, position.latitude, position.longitude);
            currentRunD = currentRunDistance.toStringAsFixed(2);
            currentRunSpeed = (runDistance/runTime).toStringAsFixed(2);
          }
          else{
            walkDistance += Geolocator.distanceBetween(latitude, longtitude, position.latitude, position.longitude);
            //walkDistance += Geolocator.distanceBetween(double.parse(latitude.toStringAsFixed(6)), double.parse(longtitude.toStringAsFixed(6)), double.parse(position.latitude.toStringAsFixed(6)), double.parse(position.longitude.toStringAsFixed(6)));
            walkD = walkDistance.toStringAsFixed(2);
            walkSpeed = (walkDistance/walkTime).toStringAsFixed(2);

            currentWalkDistance += Geolocator.distanceBetween(latitude, longtitude, position.latitude, position.longitude);
            currentWalkD = currentWalkDistance.toStringAsFixed(2);
            currentWalkSpeed = (walkDistance/walkTime).toStringAsFixed(2);
          }
          latitude = position.latitude;
          longtitude = position.longitude;
          //location = "$location \n $longtitude $latitude";
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (totalMinute<10) ? Text("0$totalMinute : ",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,): 
                        Text("$totalMinute : ",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),

                    (totalSecond<10) ? Text("0$totalSecond",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,): 
                        Text("$totalSecond",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
                  ]
                ),
                
                SizedBox(height: 20,),

                Text(activity,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
                
                Text('Seconds Left:',
                    style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                      TimeShow(remainingTime: remainingTime),
                
                SizedBox(height: 20,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        //adds to the database
                        DateTime now = DateTime.now();
                        final logging model = logging(id: now.toString(), runD: runD, walkD: walkD, runTime: runTime, walkTime: walkTime, runSpeed: runSpeed, walkSpeed: walkSpeed, totalMinute: totalMinute, totalSecond: totalSecond);
                        send(model);
                        
                        //goes to stats page
                        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => Stats(model)));
                        done = true;
                      },
                      child: Text('  Stop  '),
                    ),
                    SizedBox(width: 20,),
                    ElevatedButton(
                      onPressed: () {
                        //changes the state from run to walk and vice versa
                        change = true;
                      },
                      child: Text('Change'),
                    ),
                  ]
                ),
                //Display speed and distance
                SizedBox(height: 30,),
                Container(decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 164, 0, 104),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [const Color.fromARGB(255, 13, 243, 255),const Color.fromARGB(255, 191, 255, 15)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Run Stats:",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 108, 65, 1),), textAlign: TextAlign.center,),
                        
                        Text("Distance(This Cycle): $currentRunD Meters",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),

                        Text("Avg Speed(This Cycle): $currentRunSpeed m/s",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),
                        
                        SizedBox(height: 20,),

                        Text("Total Distance: $runD Meters",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),

                        Text("Avg Total Run Speed: $runSpeed m/s",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),
                      ]
                    )
                  )
                ),
                SizedBox(height: 10,),

                Container(decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 98, 59, 255),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [const Color.fromARGB(255, 13, 243, 255),const Color.fromARGB(255, 191, 255, 15)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Walk Stats:",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 108, 65, 1),), textAlign: TextAlign.center,),
                        
                        Text("Distance(This Cycle): $currentWalkD Meters",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),

                        Text("Avg Speed(This Cycle): $currentWalkSpeed m/s",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),
                        
                        SizedBox(height: 20,),

                        Text("Total Distance: $walkD Meters",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),

                        Text("Avg Total Speed: $walkSpeed m/s",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),
                      ]
                    )
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> send(logging model) async {
    //adds the stats to the log
    await DatabaseHelper.addLog(model);
    logging get = await (DatabaseHelper.getData(model.id));
    session = get;
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
