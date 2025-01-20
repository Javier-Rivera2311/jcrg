// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     const initializationSettings = InitializationSettings(
//       windows: WindowsInitializationSettings(),
//     );

//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         print('Notificación recibida: ${response.payload}');
//       },
//     );
//   }

//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const notificationDetails = NotificationDetails(
//       windows: WindowsNotificationDetails(
//         icon: null,
//       ),
//     );

//     await _notificationsPlugin.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
// }
