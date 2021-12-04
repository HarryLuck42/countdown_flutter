import 'dart:async';

import 'package:countdown_app/database/database_helper.dart';
import 'package:countdown_app/notification/notification_api.dart';
import 'package:countdown_app/widgets/button_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'model/count_down.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    NotificationApi.initialized();
    listenedNotification();
  }

  void listenedNotification() =>
      NotificationApi.onNotification.stream.listen(onClickNotification);

  void onClickNotification(String? payload) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DiagramPage(payload: payload),
    ));
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

  Future saveDate() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    await DatabaseHelper.instance
        .addCountDowns(CountDown(seconds: seconds, date: formattedDate));
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
          NotificationApi.showNotification(
              title: 'Finished Clockdown',
              message: 'Finished in $minutesResult minutes',
              payload: 'harry.countdown');
          saveDate();
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
            colorBackground: Color(0xFF283593),
          )
        : ButtonWidget(
            title: 'Start',
            colorText: Colors.white,
            onClicked: () {
              startTime();
            },
            colorBackground: Color(0xFF3722f6),
          );
  }

  Widget buttonReset() {
    return ButtonWidget(
      title: 'Reset',
      colorText: Colors.white,
      onClicked: () {
        stopTime(isReset: true);
      },
      colorBackground: Color(0xFFd602ee),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFeee6ff),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  const Color(0xFF3722f6),
                  const Color(0xFF714cfe),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Text(
          'CountDown App',
          style: TextStyle(
              fontFamily: 'Caveat',
              fontWeight: FontWeight.bold,
              fontSize: 27.0),
        ),
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
                  valueColor: AlwaysStoppedAnimation(Color(0xFF3722f6)),
                  strokeWidth: 12.0,
                  backgroundColor: Color(0xFFb39afd),
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
            activeColor: Color(0xFFd602ee),
            inactiveColor: Color(0xFFf2bcf8),
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

class DiagramPage extends StatefulWidget {
  final String? payload;
  const DiagramPage({Key? key, required this.payload}) : super(key: key);

  @override
  _DiagramPageState createState() => _DiagramPageState(payload: payload);
}

class _DiagramPageState extends State<DiagramPage> {
  final String? payload;
  _DiagramPageState({required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFeee6ff),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  const Color(0xFF3722f6),
                  const Color(0xFF714cfe),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Text(
          'Diagram Track',
          style: TextStyle(
              fontFamily: 'Caveat',
              fontWeight: FontWeight.bold,
              fontSize: 27.0),
        ),
      ),
      body: FutureBuilder<List<CountDown>>(
        future: DatabaseHelper.instance.getCountDowns(),
        builder:
            (BuildContext context, AsyncSnapshot<List<CountDown>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('Loading...'),
            );
          } else {
            return snapshot.data!.isEmpty
                ? Center(
                    child: Text('Data is Empty'),
                  )
                : BarChart(
                    BarChartData(
                      barTouchData: barTouchData,
                      titlesData: titlesData,
                      borderData: borderData,
                      barGroups: getDatas(snapshot.data ?? []),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 20,
                    ),
                  );
          }
        },
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.y.round().toString(),
              const TextStyle(
                color: Color(0xFF283593),
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xFF283593),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          margin: 20,
          getTitles: (double value) {
            int result = value.round();
            return '$result';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xFF283593),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (double value) {
            int result = value.round() * 3;
            return '$result';
          },
          margin: 3,
          reservedSize: 20,
          interval: 10,
        ),
        topTitles: SideTitles(showTitles: true, margin: 12),
        rightTitles: SideTitles(showTitles: false),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  List<BarChartGroupData> getDatas(List<CountDown> data) {
    List<BarChartGroupData> result = [];
    for (var value in data) {
      result.add(
        BarChartGroupData(
          x: value.id ?? 0,
          barRods: [
            BarChartRodData(
                y: (value.seconds! / 180),
                colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)])
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return result;
  }
}
