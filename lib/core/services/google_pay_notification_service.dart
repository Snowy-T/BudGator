import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class GooglePayNotificationEvent {
  final String packageName;
  final String title;
  final String text;
  final String bigText;
  final String subText;
  final String message;
  final double? amount;
  final DateTime timestamp;

  const GooglePayNotificationEvent({
    required this.packageName,
    required this.title,
    required this.text,
    required this.bigText,
    required this.subText,
    required this.message,
    required this.amount,
    required this.timestamp,
  });

  factory GooglePayNotificationEvent.fromMap(Map<dynamic, dynamic> raw) {
    final merged = (raw['message'] as String?)?.trim();
    final title = (raw['title'] as String?)?.trim() ?? '';
    final text = (raw['text'] as String?)?.trim() ?? '';
    final bigText = (raw['bigText'] as String?)?.trim() ?? '';
    final subText = (raw['subText'] as String?)?.trim() ?? '';
    final parsedFromText = _parseAmountFromText(
      [title, text, bigText, subText].where((it) => it.isNotEmpty).join(' '),
    );
    final amount = parsedFromText ?? _toDouble(raw['amount']);
    final timestampMs = (raw['timestamp'] as num?)?.toInt();

    return GooglePayNotificationEvent(
      packageName: (raw['packageName'] as String?) ?? '',
      title: title,
      text: text,
      bigText: bigText,
      subText: subText,
      message: (merged?.isNotEmpty ?? false)
          ? merged!
          : [
              title,
              text,
              bigText,
              subText,
            ].where((it) => it.isNotEmpty).join(' '),
      amount: amount,
      timestamp: timestampMs == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
  }

  static double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      return double.tryParse(raw.replaceAll(',', '.').trim());
    }
    return null;
  }

  static double? _parseAmountFromText(String text) {
    final match = RegExp(
      r'(?:€|eur\s*)(\d{1,3}(?:[.\s]\d{3})*(?:[,\.]\d{1,2})?|\d+(?:[,\.]\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);

    final raw = match?.group(1);
    if (raw == null) return null;

    return _parseFlexibleNumber(raw);
  }

  static double? _parseFlexibleNumber(String raw) {
    final compact = raw.replaceAll(' ', '').trim();
    if (compact.isEmpty) return null;

    final hasComma = compact.contains(',');
    final hasDot = compact.contains('.');

    if (hasComma && hasDot) {
      // Last separator is decimal, the other one is thousand separator.
      final lastComma = compact.lastIndexOf(',');
      final lastDot = compact.lastIndexOf('.');
      if (lastComma > lastDot) {
        return double.tryParse(
          compact.replaceAll('.', '').replaceAll(',', '.'),
        );
      }
      return double.tryParse(compact.replaceAll(',', ''));
    }

    if (hasComma) {
      final parts = compact.split(',');
      if (parts.length > 1 && parts.last.length <= 2) {
        return double.tryParse(
          compact.replaceAll('.', '').replaceAll(',', '.'),
        );
      }
      return double.tryParse(compact.replaceAll(',', ''));
    }

    if (hasDot) {
      final parts = compact.split('.');
      if (parts.length > 1 && parts.last.length <= 2) {
        return double.tryParse(compact);
      }
      return double.tryParse(compact.replaceAll('.', ''));
    }

    return double.tryParse(compact);
  }
}

class GooglePayNotificationService {
  GooglePayNotificationService._();

  static final GooglePayNotificationService instance =
      GooglePayNotificationService._();

  static const MethodChannel _methodChannel = MethodChannel(
    'budgator/google_pay_notifications/methods',
  );
  static const EventChannel _eventChannel = EventChannel(
    'budgator/google_pay_notifications/events',
  );

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<GooglePayNotificationEvent> get events {
    if (!isSupported) {
      return const Stream<GooglePayNotificationEvent>.empty();
    }

    return _eventChannel
        .receiveBroadcastStream()
        .where((raw) => raw is Map)
        .map((raw) => GooglePayNotificationEvent.fromMap(raw as Map));
  }

  Future<bool> isNotificationAccessGranted() async {
    if (!isSupported) return false;

    try {
      final granted = await _methodChannel.invokeMethod<bool>(
        'isNotificationAccessGranted',
      );
      return granted ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openNotificationAccessSettings() {
    if (!isSupported) return Future.value();
    return _methodChannel
        .invokeMethod('openNotificationAccessSettings')
        .catchError((_) {});
  }

  Future<bool> isPostNotificationsGranted() async {
    if (!isSupported) return false;

    try {
      final granted = await _methodChannel.invokeMethod<bool>(
        'isPostNotificationsGranted',
      );
      return granted ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestPostNotificationsPermission() async {
    if (!isSupported) return false;

    try {
      final granted = await _methodChannel.invokeMethod<bool>(
        'requestPostNotificationsPermission',
      );
      return granted ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<List<GooglePayNotificationEvent>> fetchAndClearPendingEvents() async {
    if (!isSupported) return const [];

    try {
      final raw = await _methodChannel.invokeMethod<List<dynamic>>(
        'fetchAndClearPendingEvents',
      );
      if (raw == null || raw.isEmpty) return const [];

      return raw
          .whereType<Map>()
          .map((item) => GooglePayNotificationEvent.fromMap(item))
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }
}
