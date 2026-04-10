package com.example.budgator

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

	private lateinit var methodChannel: MethodChannel
	private lateinit var eventChannel: EventChannel

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		methodChannel = MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"budgator/google_pay_notifications/methods"
		)
		methodChannel.setMethodCallHandler(this)

		eventChannel = EventChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"budgator/google_pay_notifications/events"
		)
		eventChannel.setStreamHandler(this)
	}

	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"openNotificationAccessSettings" -> {
				val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
				startActivity(intent)
				result.success(true)
			}

			"isNotificationAccessGranted" -> {
				result.success(isNotificationAccessGranted())
			}

			"fetchAndClearPendingEvents" -> {
				result.success(
					GooglePayNotificationBridge.fetchAndClearPendingEvents(applicationContext)
				)
			}

			else -> result.notImplemented()
		}
	}

	override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
		GooglePayNotificationBridge.eventSink = events
	}

	override fun onCancel(arguments: Any?) {
		GooglePayNotificationBridge.eventSink = null
	}

	private fun isNotificationAccessGranted(): Boolean {
		val enabledListeners =
			Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: return false
		val myService = ComponentName(this, GooglePayNotificationListenerService::class.java)
			.flattenToString()
		return enabledListeners.contains(myService)
	}
}
