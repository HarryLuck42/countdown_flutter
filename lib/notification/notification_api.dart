import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationApi {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static void initialized() {
    var androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);
    plugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        onNotification.add(payload);
      },
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? message,
    String? payload,
  }) async {
    var androidDetails = AndroidNotificationDetails(
        'channelId', 'channelMessage',
        channelDescription: 'channelDescription', importance: Importance.high);
    var iOSDetails = IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await plugin.show(id, title, message, generalNotificationDetails,
        payload: payload);
  }
}
