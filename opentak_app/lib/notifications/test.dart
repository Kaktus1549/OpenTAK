import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _player = AudioPlayer();
final fln = FlutterLocalNotificationsPlugin();

Future<void> playNotifAndShowHello(String msg) async {
  // Start sound (don’t block notification)
  _player.play(AssetSource('sounds/nokia.mp3'));

  // Show system notification text
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'hello_channel',
      'Hello notifications',
      channelDescription: 'Shows Hello notifications',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false, // sound is played by audioplayers instead
    ),
  );

  await fln.show(
    id: 1001,
    title: 'OpenTAK SOS',
    body: msg,
    notificationDetails: details,
  );
}