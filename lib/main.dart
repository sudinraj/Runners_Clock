import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:run/pages/log_page.dart';
import 'package:run/pages/running_page_state.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:device_info_plus/device_info_plus.dart';


final FlutterLocalNotificationsPlugin flutterLocalPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'run_location', // id
    'Tracking speed', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await initializeService();
  // Register a background task
  //Workmanager().registerPeriodicTask(
  //  "uniqueTaskName",
  //  "backgroundTask",
  //  frequency: Duration(seconds: 1), // Minimum interval for Android
  //);
  runApp(MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'run_location',
      initialNotificationTitle: 'RUNNING SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 90,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();


  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalPlugin.show(
          90,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'run_location',
              'Tracking Speed',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }
    }

    /// you can see this log in logcat
    //debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    //adds an observer that checks if the enviroment has changed
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //checks if the user has completely closed the app
    if (state == AppLifecycleState.detached) {
      //if it is closed, then it kills all processes(including the background process)
        exit(0);
    }
  }

  @override
  void dispose() {
    //removes the observer to avoid memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Runners Clock',
        initialRoute: '/',
        routes: {
          '/logs':(context) => LogPage()
        },

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
  int _currentWalkMinValue = 0;
  int _currentRunMinValue = 0;

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Select how much time to run, and walk:',
                style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 189, 5, 5),), 
                textAlign: TextAlign.center,
                ),
            //Sized Box adds whitespace
                SizedBox(height: 30),
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
                                  selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 255, 7, 7), fontSize: 35,fontWeight: FontWeight.bold,),
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
                                  selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 255, 7, 7), fontSize: 35,fontWeight: FontWeight.bold,),
                                  value: _currentRunMinValue,
                                  minValue: 0,
                                  maxValue: 60,
                                  onChanged: (value) =>setState(() =>_currentRunMinValue = value),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]
                    ),
            
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
                                  selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 7, 85, 255), fontSize: 35,fontWeight: FontWeight.bold,),
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
                                  textStyle: TextStyle(color: const Color.fromARGB(255, 30, 186, 233), ),
                                  selectedTextStyle: TextStyle(color: const Color.fromARGB(255, 7, 85, 255), fontSize: 35,fontWeight: FontWeight.bold,),
                                  value: _currentWalkMinValue,
                                  minValue: 0,
                                  maxValue: 60,
                                  onChanged: (value) =>setState(() =>_currentWalkMinValue = value),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]
                    ),
                
                SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: () {
                    //goes to the page with tht timer
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => RunningPageState((_currentWalkValue*60 + _currentWalkMinValue), (_currentRunValue*60 + _currentRunMinValue))));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Color.fromARGB(255, 158, 0, 0),)
                    )
                  ),
                  child: Text('Start'),
                ),

                SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: () {
                    //goes to the page with tht timer
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => LogPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Color.fromARGB(255, 158, 0, 0),)
                    )
                  ),
                  child: Text('Stats'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}