import 'package:flutter/material.dart';


class Stats extends StatelessWidget{
  final double runDistance;
  final String runD;
  final double walkDistance;
  final String walkD;
  final double runTime;
  final double walkTime;
  final String runSpeed;
  final String walkSpeed;
  const Stats(this.runDistance, this.runD, this.walkDistance, this.walkD, this.runTime, this.walkTime, this.runSpeed, this.walkSpeed,{super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Stats for this session:",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0),), textAlign: TextAlign.center,),

                    SizedBox(height: 20,),

                    Container(decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.yellow,
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [const Color.fromARGB(255, 13, 243, 255),const Color.fromARGB(255, 255, 15, 183)],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Run Distance: $runD m \n Run Time: $runTime s \n Run Speed: $runSpeed m/s",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 7, 7),), textAlign: TextAlign.center,),

                            SizedBox(height: 30,),

                            Text("Walk Distance: $walkD m \n Walk Speed: $walkTime s \n Walk Speed: $walkSpeed m/s",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 85, 255),), textAlign: TextAlign.center,),
                            
                          ]
                        )
                      )
                    ),

                    SizedBox(height: 20,),

                    ElevatedButton(
                      onPressed: () {
                        //goes back to the home screen
                        Navigator.popUntil(context, ModalRoute.withName("/"));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color.fromARGB(255, 158, 0, 0),)
                        )
                      ),
                      child: Text('Home'),
                    ),
                  ]
                ),
            )
          )
      )
    );
  }

}