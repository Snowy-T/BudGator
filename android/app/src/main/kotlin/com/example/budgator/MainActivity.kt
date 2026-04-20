package com.example.budgator

import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Build
import android.content.Intent
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

	private val postNotificationsPermissionRequestCode = 22031

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

			"isPostNotificationsGranted" -> {
				result.success(isPostNotificationsGranted())
			}

			"requestPostNotificationsPermission" -> {
				result.success(requestPostNotificationsPermission())
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

	private fun isPostNotificationsGranted(): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
			return true
		}

		return ContextCompat.checkSelfPermission(
			this,
			android.Manifest.permission.POST_NOTIFICATIONS
		) == PackageManager.PERMISSION_GRANTED
	}

	private fun requestPostNotificationsPermission(): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
			return true
		}

		if (isPostNotificationsGranted()) {
			return true
		}

		ActivityCompat.requestPermissions(
			this,
			arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
			postNotificationsPermissionRequestCode
		)

		return false
	}
}
