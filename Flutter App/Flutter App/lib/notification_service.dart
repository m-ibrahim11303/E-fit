import 'dart:math';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> motivationalMessages = [
    "You’re stronger than you think—crush it today!",
    "Every step you take is progress. Keep going!",
    "Your goals are within reach—stay focused!",
    "Rise and grind! You’ve got this!",
    "Push yourself, because you’re worth it!",
  ];

  // Notification Channel constants for Android
  static const String _channelId = 'motivation_channel';
  static const String _channelName = 'Motivational Messages';
  static const String _channelDescription =
      'Daily motivational messages for fitness';

  Future<void> init() async {
    try {
      if (kDebugMode) {
        print('[NotificationService] Initializing timezone...');
      }
      tz.initializeTimeZones();
      tz.setLocalLocation(
          tz.getLocation('Asia/Karachi')); // Adjust timezone if needed
      if (kDebugMode) {
        print('[NotificationService] Timezone initialized: ${tz.local.name}');
      }

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // Default icon

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combine platform settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      if (kDebugMode) {
        print('[NotificationService] Initializing notification plugin...');
      }
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
      );
      if (kDebugMode) {
        print('[NotificationService] Notification plugin initialized.');
      }

      await _requestPermissions();
    } catch (e, stackTrace) {
      print('[NotificationService] Error during initialization: $e');
      print('[NotificationService] Stack trace: $stackTrace');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          final bool? granted =
              await androidPlugin.requestNotificationsPermission();
          if (kDebugMode) {
            print(
                '[NotificationService] Android notification permission granted: $granted');
          }
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final bool? granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          if (kDebugMode) {
            print(
                '[NotificationService] iOS notification permission granted: $granted');
          }
        }
      }
    } catch (e, stackTrace) {
      print('[NotificationService] Error requesting permissions: $e');
      print('[NotificationService] Stack trace: $stackTrace');
    }
  }

  void onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print(
          '[NotificationService] Notification tapped: Payload=${response.payload}, ID=${response.id}, ActionID=${response.actionId}');
    }
    // Add navigation or other actions based on payload/ID if needed
  }

  Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? canSchedule =
          await androidPlugin?.canScheduleExactNotifications();
      if (kDebugMode) {
        print('[NotificationService] Can schedule exact alarms: $canSchedule');
      }
      return canSchedule ?? false;
    } catch (e) {
      print('[NotificationService] Error checking exact alarm permission: $e');
      return false;
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();
      if (kDebugMode) {
        print('[NotificationService] Requested exact alarm permission.');
      }
    } catch (e) {
      print(
          '[NotificationService] Error requesting exact alarm permission: $e');
    }
  }

  // **************************************************************************
  // *             MODIFIED FOR TESTING - Schedules 2 minutes later           *
  // *         Remember to REVERT to use _nextInstanceOfEightAM()             *
  // *         and UNCOMMENT matchDateTimeComponents for daily 8 AM           *
  // **************************************************************************
  Future<void> scheduleDailyMotivation() async {
    try {
      final random = Random();
      final message =
          motivationalMessages[random.nextInt(motivationalMessages.length)];
      if (kDebugMode) {
        print(
            '[NotificationService] Selected message for 2-min test: $message');
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Motivation Test', // Modified ticker
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final bool canUseExact = await canScheduleExactAlarms();
      final AndroidScheduleMode androidScheduleMode = canUseExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.exact;

      // --- MODIFICATION FOR TESTING ---
      // Calculate schedule time: 2 minutes from now
      final tz.TZDateTime scheduledTime =
          tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2));
      // --- END MODIFICATION ---

      if (kDebugMode) {
        print(
            '[NotificationService] SCHEDULING TEST (2 MINS): $scheduledTime (Local: ${scheduledTime.toLocal()})');
        print(
            '[NotificationService] Using Android schedule mode: $androidScheduleMode');
      }

      await _notificationsPlugin.zonedSchedule(
        0, // Using ID 0 for this test notification
        'Motivation Test (2 Min)', // Modified title for clarity
        message,
        scheduledTime, // Use the calculated "now + 2 minutes" time
        notificationDetails,
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // --- MODIFICATION FOR TESTING ---
        // ** COMMENTED OUT ** to make it ONE-TIME for the test.
        // ** UNCOMMENT ** this for the real daily repeating notification.
        // matchDateTimeComponents: DateTimeComponents.time,
        // --- END MODIFICATION ---
        payload: 'daily_motivation_test', // Modified payload
      );
      if (kDebugMode) {
        print(
            '[NotificationService] TEST notification scheduled successfully for 2 minutes later.');
      }
    } catch (e, stackTrace) {
      print('[NotificationService] Error scheduling TEST notification: $e');
      print('[NotificationService] Stack trace: $stackTrace');
    }
  }
  // **************************************************************************
  // *                  END OF MODIFIED SECTION FOR TESTING                   *
  // **************************************************************************

  // This is the original function to calculate 8 AM. Keep it for when you revert.
  tz.TZDateTime _nextInstanceOfEightAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 8, 0); // 8:00:00 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (kDebugMode) {
      print('[NotificationService] Calculated next 8 AM: $scheduledDate');
    }
    return scheduledDate;
  }

  // Example: Schedule a one-time notification (e.g., for manual trigger testing)
  // This uses ID 2
  Future<void> scheduleOneTimeMotivation() async {
    final random = Random();
    final message =
        motivationalMessages[random.nextInt(motivationalMessages.length)];
    try {
      if (kDebugMode) {
        print('[NotificationService] Selected one-time message: $message');
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule for 1 minute from now for testing
      final scheduledTime =
          tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
      if (kDebugMode) {
        print(
            '[NotificationService] Scheduling one-time notification (ID 2) for: $scheduledTime (Local: ${scheduledTime.toLocal()})');
      }

      await _notificationsPlugin.zonedSchedule(
        2, // Unique ID for this one-time notification
        'Motivational Boost (One-Time)',
        message,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'one_time_motivation',
      );
      if (kDebugMode) {
        print('[NotificationService] One-time notification (ID 2) scheduled.');
      }
    } catch (e, stackTrace) {
      print(
          '[NotificationService] Error scheduling one-time notification (ID 2): $e');
      print('[NotificationService] Stack trace: $stackTrace');
      await showCustomNotification('Motivational Boost (Fallback)', message,
          4); // Use different ID for fallback
    }
  }

  // Show an immediate notification
  // Uses ID 3 by default, or a provided ID
  Future<void> showCustomNotification(String title, String message,
      [int id = 3]) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        message,
        notificationDetails,
        payload: 'custom_notification_$id',
      );
      if (kDebugMode) {
        print(
            '[NotificationService] Custom notification shown (ID $id): $title - $message');
      }
    } catch (e, stackTrace) {
      print(
          '[NotificationService] Error showing custom notification (ID $id): $e');
      print('[NotificationService] Stack trace: $stackTrace');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    if (kDebugMode) {
      print('[NotificationService] Canceled notification with ID: $id');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('[NotificationService] Canceled all notifications.');
    }
  }
}
