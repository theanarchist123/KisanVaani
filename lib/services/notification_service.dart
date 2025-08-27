import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification(String title, String body, {
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF4CAF50),
      playSound: true,
      enableVibration: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showStatusUpdateNotification(
    String schemeName,
    String status,
    String trackingNumber,
  ) async {
    const title = 'Application Status Update';
    final body = 'Your $schemeName application status: $status';
    
    await showNotification(
      title,
      body,
      payload: 'status_update:$trackingNumber',
      type: NotificationType.statusUpdate,
    );
  }

  Future<void> showPolicyUpdateNotification(
    String policyTitle,
    bool isImportant,
  ) async {
    final title = isImportant ? '🚨 Important Policy Update' : 'New Policy Update';
    final body = policyTitle;
    
    await showNotification(
      title,
      body,
      payload: 'policy_update:$policyTitle',
      type: NotificationType.policyUpdate,
    );
  }

  Future<void> showSubsidyNotification(
    String subsidyTitle,
    String amount,
  ) async {
    const title = 'Subsidy Credited';
    final body = '$subsidyTitle: ₹$amount has been credited to your account';
    
    await showNotification(
      title,
      body,
      payload: 'subsidy:$subsidyTitle',
      type: NotificationType.subsidy,
    );
  }

  Future<void> showReminderNotification(
    String title,
    String message,
  ) async {
    await showNotification(
      title,
      message,
      type: NotificationType.reminder,
    );
  }

  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDate, {
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: Importance.max,
      priority: Priority.high,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Using zonedSchedule for scheduling notifications
    // Note: This would require timezone package in a real implementation
    // For now, we'll use a simple show method
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  void _handleNotificationPayload(String payload) {
    // Handle different types of notification taps
    if (payload.startsWith('status_update:')) {
      final trackingNumber = payload.split(':')[1];
      // Navigate to application details
      print('Navigate to application: $trackingNumber');
    } else if (payload.startsWith('policy_update:')) {
      // Navigate to policy updates
      print('Navigate to policy updates');
    } else if (payload.startsWith('subsidy:')) {
      // Navigate to subsidy tracking
      print('Navigate to subsidy tracking');
    }
  }

  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.statusUpdate:
        return 'status_updates';
      case NotificationType.policyUpdate:
        return 'policy_updates';
      case NotificationType.subsidy:
        return 'subsidy_notifications';
      case NotificationType.reminder:
        return 'reminders';
      case NotificationType.general:
        return 'general_notifications';
    }
  }

  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.statusUpdate:
        return 'Status Updates';
      case NotificationType.policyUpdate:
        return 'Policy Updates';
      case NotificationType.subsidy:
        return 'Subsidy Notifications';
      case NotificationType.reminder:
        return 'Reminders';
      case NotificationType.general:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.statusUpdate:
        return 'Notifications about application status changes';
      case NotificationType.policyUpdate:
        return 'Updates about new government policies and schemes';
      case NotificationType.subsidy:
        return 'Notifications about subsidy payments and benefits';
      case NotificationType.reminder:
        return 'Reminder notifications for important deadlines';
      case NotificationType.general:
        return 'General app notifications';
    }
  }
}

enum NotificationType {
  statusUpdate,
  policyUpdate,
  subsidy,
  reminder,
  general,
}
