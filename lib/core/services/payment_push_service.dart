import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PaymentPushEvent {
  final String source;
  final String title;
  final String text;
  final String message;
  final double? amount;
  final DateTime timestamp;

  const PaymentPushEvent({
    required this.source,
    required this.title,
    required this.text,
    required this.message,
    required this.amount,
    required this.timestamp,
  });

  factory PaymentPushEvent.fromData(
    Map<String, dynamic> data, {
    RemoteNotification? notification,
    DateTime? receivedAt,
  }) {
    final title =
        (data['title'] as String?)?.trim() ??
        (notification?.title?.trim() ?? 'Zahlung erkannt');
    final text =
        (data['text'] as String?)?.trim() ?? (notification?.body?.trim() ?? '');
    final source = (data['source'] as String?)?.trim() ?? 'apple_pay';
    final message =
        (data['message'] as String?)?.trim() ?? [title, text].join(' ').trim();

    return PaymentPushEvent(
      source: source,
      title: title,
      text: text,
      message: message,
      amount: _toDouble(data['amount']),
      timestamp: receivedAt ?? DateTime.now(),
    );
  }

  static double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      return double.tryParse(raw.replaceAll(',', '.').trim());
    }
    return null;
  }
}

class PaymentPushService {
  PaymentPushService._();

  static final PaymentPushService instance = PaymentPushService._();

  final StreamController<PaymentPushEvent> _controller =
      StreamController<PaymentPushEvent>.broadcast();

  bool _isInitialized = false;

  Stream<PaymentPushEvent> get events => _controller.stream;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen(_emitFromRemoteMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_emitFromRemoteMessage);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _emitFromRemoteMessage(initial);
      }

      _isInitialized = true;
      return true;
    } catch (_) {
      // Firebase is optional at runtime until platform config is added.
      return false;
    }
  }

  void _emitFromRemoteMessage(RemoteMessage message) {
    final event = PaymentPushEvent.fromData(
      message.data,
      notification: message.notification,
      receivedAt: message.sentTime?.toLocal() ?? DateTime.now(),
    );
    _controller.add(event);
  }
}
