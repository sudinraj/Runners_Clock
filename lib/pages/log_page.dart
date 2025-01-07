import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:run/database_helper.dart';
import 'package:run/logging.dart';
import 'package:run/pages/stats.dart';


class LogPage extends StatefulWidget{
  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
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
                    Text("Click on a session to view more details",
                    style: TextStyle(fontSize:25, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),

                    SizedBox(height: 10,),

                    //to display all the elements of the database
                    FutureBuilder<List<logging>?>(
                      future: DatabaseHelper.getAllLog(), 
                      //snapshot is used to interact with the data from futurebuilder
                      builder: (context, AsyncSnapshot<List<logging>?> snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const CircularProgressIndicator();
                        }
                        else if(snapshot.hasError){
                          return Center(child: Text(snapshot.error.toString()));
                        }
                        else if(snapshot.hasData){
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height/2),
                            child: Container(
                              width: MediaQuery.of(context).size.width/1.1,
                              //height: MediaQuery.of(context).size.height/2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 5, style: BorderStyle.none),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  //Prints out everything in the database
                                  int i = snapshot.data!.length - (index+1);
                                  return Container(decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.yellow,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [const Color.fromARGB(255, 13, 243, 255),const Color.fromARGB(255, 191, 255, 15)],
                                    ),
                                  ),
                                  child:ListTile(
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text("${(index+1)}. ",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                            
                                        SizedBox(width: (MediaQuery.of(context).size.width/1.1)/5),
                            
                                        //Displays the date and time of the session to be clicked on
                                        Text("${snapshot.data![i].id.split(" ")[0]}\n${snapshot.data![i].id.split(" ")[1]}",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,)
                                      ]
                                    ),
                                    onTap: () async{
                                      //opens the stats page for the session clicked
                                      await Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => Stats(snapshot.data![i])));
                                    },
                                    onLongPress: () {
                                      //creates a popup to ask to delete
                                      showDialog(context: context, builder: (context) => AlertDialog(
                                        title: const Text('Delete this session log?'),
                                        actions: [
                                          IconButton(
                                              onPressed: () async {
                                                //deletes the log
                                                await DatabaseHelper.deleteLog(snapshot.data![i]);
                                                //setstate sets the state of the page to the updated db
                                                setState (() {
                                                  //closes the popup
                                                  Navigator.pop(context);
                                                }
                                                );
                                              },
                                              icon: const Icon(Icons.check))
                                        ],
                                      ));
                                    },
                                  ));
                                }
                              )
                            ),
                          );
                        }
                        return const Center(
                          child: Text("No logs yet", 
                          style: TextStyle(fontSize: 50,fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center,)
                        );
                      }
                    ),

                    SizedBox(height: 20,),

                    ElevatedButton(
                      onPressed: () {
                        //goes back to the home screen
                        //Navigator.popUntil(context, ModalRoute.withName("/"));
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