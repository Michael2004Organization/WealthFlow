import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    tz.initializeTimeZones();
    try {
      final current = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(current.identifier));
    } catch (_) {
      // Unsupported platforms safely keep the timezone package's UTC fallback.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Öffnen'),
      windows: WindowsInitializationSettings(
        appName: 'WealthFlow',
        appUserModelId: 'WealthFlow.Desktop.App',
        guid: '4bbf3cc8-7171-4d53-b8e1-b1429f16f644',
      ),
      web: WebInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
  }

  Future<void> requestPermissions() async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          WebFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> schedule({
    required String id,
    required String title,
    required DateTime scheduledAt,
  }) async {
    await initialize();
    final localTime = scheduledAt.toLocal();
    if (!localTime.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: _notificationId(id),
        title: 'WealthFlow-Erinnerung',
        body: title,
        scheduledDate: tz.TZDateTime.from(localTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'wealthflow_reminders',
            'Erinnerungen',
            channelDescription: 'Geplante Erinnerungen aus WealthFlow',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: id,
      );
    } on UnsupportedError {
      // Some desktop/web notification servers cannot schedule in advance.
    }
  }

  Future<void> cancel(String id) async {
    await initialize();
    await _plugin.cancel(id: _notificationId(id));
  }

  int _notificationId(String value) => value.codeUnits.fold<int>(
    17,
    (hash, unit) => (hash * 37 + unit) & 0x7fffffff,
  );
}
