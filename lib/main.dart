import 'dart:async';

import 'package:countdown_app/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Countdown(),
    );
  }
}

class Countdown extends StatefulWidget {
  const Countdown({Key? key}) : super(key: key);

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  static const maxSeconds = 3600;
  int seconds = maxSeconds;
  int settingSeconds = maxSeconds;
  String secondsResult = "";
  String minutesResult = "";

  Timer? timer;

  @override
  void initState() {
    updateTimes();
    super.initState();
  }

  void updateTimes() {
    secondsResult = getFormatSeconds(seconds);
    minutesResult = getFormatMinutes(seconds);
  }

  String getFormatSeconds(int values) {
    int stateSeconds = values % 60;
    return stateSeconds < 10 ? '0$stateSeconds' : '$stateSeconds';
  }

  String getFormatMinutes(int values) {
    int stateMinutes = Duration(seconds: values).inMinutes;
    return stateMinutes < 10 ? '0$stateMinutes' : '$stateMinutes';
  }

  void resetTime() {
    seconds = settingSeconds;
    setState(() => updateTimes());
  }

  void playRingtone() {
    AudioCache audioCache = AudioCache();
    audioCache.play('ringtone.wav');
  }

  void startTime({bool isReset = false}) {
    if (isReset) {
      resetTime();
    }
    timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
          updateTimes();
        } else {
          stopTime(isReset: true);
          playRingtone();
        }
      });
    });
  }

  void stopTime({bool isReset = false}) {
    if (isReset) {
      resetTime();
    }
    setState(() => timer?.cancel());
  }

  Widget buttonStart() {
    final isRunning = timer == null ? false : timer!.isActive;
    final isComplete = seconds == settingSeconds || seconds == 0;
    return isRunning || !isComplete
        ? ButtonWidget(
            title: isRunning ? 'Pause' : 'Resume',
            colorText: Colors.white,
            onClicked: () {
              isRunning ? stopTime() : startTime();
            },
            colorBackground: Colors.teal,
          )
        : ButtonWidget(
            title: 'Start',
            colorText: Colors.white,
            onClicked: () {
              startTime();
            },
            colorBackground: Colors.blue,
          );
  }

  Widget buttonReset() {
    return ButtonWidget(
      title: 'Reset',
      colorText: Colors.white,
      onClicked: () {
        stopTime(isReset: true);
      },
      colorBackground: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CountDown App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: seconds / settingSeconds,
                  valueColor: AlwaysStoppedAnimation(Colors.teal),
                  strokeWidth: 12.0,
                  backgroundColor: Colors.teal.shade100,
                ),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        minutesResult,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 80.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 18.0),
                        child: Text(
                          '.$secondsResult',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: double.parse(minutesResult),
            onChanged: (newRanting) {
              setState(() {
                settingSeconds = (newRanting * 60).round();
                seconds = (newRanting * 60).round();
                updateTimes();
              });
            },
            label: '$minutesResult',
            min: 0,
            max: 60,
            divisions: 60,
            activeColor: Colors.red,
            inactiveColor: Colors.red.shade100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buttonStart(),
              SizedBox(
                width: 20.0,
              ),
              buttonReset(),
            ],
          ),
        ],
      ),
    );
  }
}
