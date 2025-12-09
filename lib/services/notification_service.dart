import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling local push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    log('NotificationService initialized', name: 'NotificationService');
  }

  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}', name: 'NotificationService');
    // Handle navigation based on payload
  }

  /// Request notification permissions (iOS/Android 13+)
  Future<bool> requestPermissions() async {
    try {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }

      final ios = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      log('Error requesting permissions: $e', name: 'NotificationService');
      return false;
    }
  }

  /// Schedule a daily reminder notification
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Time to tend your garden 🌿',
    String body = 'Take a moment to check in with yourself.',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Reminders to check in with your garden',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next occurrence of the time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0, // ID for daily reminder
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    log('Daily reminder scheduled for $hour:$minute', name: 'NotificationService');
  }

  /// Cancel the daily reminder
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
    log('Daily reminder cancelled', name: 'NotificationService');
  }

  /// Show an immediate notification (for testing or events)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Show streak reminder notification
  Future<void> showStreakReminder(int currentStreak) async {
    await showNotification(
      title: 'Don\'t break your streak! 🔥',
      body: 'You\'re on a $currentStreak day streak. Check in to keep it going!',
      payload: 'streak_reminder',
    );
  }

  /// Show milestone notification
  Future<void> showMilestoneNotification(String milestoneName, int xpReward) async {
    await showNotification(
      title: 'Achievement Unlocked! 🎉',
      body: 'You earned "$milestoneName" and gained $xpReward XP!',
      payload: 'milestone',
    );
  }
}
