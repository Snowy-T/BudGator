package com.example.budgator

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

object GooglePayNotificationBridge {
    private const val prefsName = "budgator_google_pay_notifications"
    private const val pendingEventsKey = "pending_events"

    var eventSink: EventChannel.EventSink? = null

    fun push(context: Context, event: Map<String, Any?>) {
        val sink = eventSink
        if (sink != null) {
            sink.success(event)
            return
        }

        persistPendingEvent(context, event)
    }

    fun fetchAndClearPendingEvents(context: Context): List<Map<String, Any?>> {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val raw = prefs.getString(pendingEventsKey, null) ?: return emptyList()

        val list = mutableListOf<Map<String, Any?>>()
        val array = JSONArray(raw)
        for (i in 0 until array.length()) {
            val item = array.optJSONObject(i) ?: continue
            list.add(jsonToMap(item))
        }

        prefs.edit().remove(pendingEventsKey).apply()
        return list
    }

    private fun persistPendingEvent(context: Context, event: Map<String, Any?>) {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val raw = prefs.getString(pendingEventsKey, null)
        val array = if (raw.isNullOrBlank()) JSONArray() else JSONArray(raw)

        array.put(JSONObject(event))
        prefs.edit().putString(pendingEventsKey, array.toString()).apply()
    }

    private fun jsonToMap(obj: JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        val keys = obj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val value = obj.get(key)
            map[key] = if (value == JSONObject.NULL) null else value
        }
        return map
    }
}

object GooglePayCapturePrompt {
    private const val channelId = "budgator_payment_capture"
    private const val channelName = "Budgator Zahlungen"

    fun show(context: Context, title: String, body: String, timestamp: Long) {
        ensureChannel(context)

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

        val pendingLaunchIntent = PendingIntent.getActivity(
            context,
            timestamp.toInt(),
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(pendingLaunchIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .addAction(
                0,
                "Eintragen",
                pendingLaunchIntent
            )
            .build()

        NotificationManagerCompat.from(context).notify(timestamp.toInt(), notification)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(channelId) != null) return

        val channel = NotificationChannel(
            channelId,
            channelName,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Hinweise zum schnellen Eintragen erkannter Wallet-Zahlungen"
        }

        manager.createNotificationChannel(channel)
    }
}

class GooglePayNotificationListenerService : NotificationListenerService() {

    private val allowedPackages = setOf(
        "com.google.android.apps.walletnfcrel",
        "com.google.android.apps.nbu.paisa.user"
    )

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return

        val packageName = sbn.packageName ?: return
        val extras = sbn.notification?.extras ?: Bundle.EMPTY

        val title = extras.getString("android.title").orEmpty()
        val text = extras.getCharSequence("android.text")?.toString().orEmpty()
        val bigText = extras.getCharSequence("android.bigText")?.toString().orEmpty()
        val subText = extras.getCharSequence("android.subText")?.toString().orEmpty()

        if (!isGooglePayNotification(packageName, title, text, bigText, subText)) {
            return
        }

        val mergedText = listOf(title, text, bigText, subText)
            .filter { it.isNotBlank() }
            .joinToString(" ")

        val amount = parseAmount(mergedText)

        GooglePayNotificationBridge.push(
            applicationContext,
            mapOf(
                "packageName" to packageName,
                "title" to title,
                "text" to text,
                "bigText" to bigText,
                "subText" to subText,
                "message" to mergedText,
                "amount" to amount,
                "timestamp" to sbn.postTime
            )
        )

        val promptTitle = if (title.isNotBlank()) title else "Wallet-Zahlung erkannt"
        val promptText = if (mergedText.isNotBlank()) {
            "Zum Eintragen tippen: $mergedText"
        } else {
            "Zum Eintragen tippen"
        }
        GooglePayCapturePrompt.show(applicationContext, promptTitle, promptText, sbn.postTime)
    }

    private fun isGooglePayNotification(
        packageName: String,
        title: String,
        text: String,
        bigText: String,
        subText: String
    ): Boolean {
        if (allowedPackages.contains(packageName)) return true

        val content = listOf(title, text, bigText, subText)
            .joinToString(" ")
            .lowercase(Locale.getDefault())

        return content.contains("google pay") ||
            content.contains("gpay") ||
            content.contains("wallet")
    }

    private fun parseAmount(content: String): Double? {
        val amountRegex = Regex("(?:€|eur\\s*)(\\d{1,3}(?:[.\\s]\\d{3})*(?:[,.]\\d{1,2})?|\\d+(?:[,.]\\d{1,2})?)", RegexOption.IGNORE_CASE)
        val match = amountRegex.find(content) ?: return null
        val raw = match.groupValues.getOrNull(1) ?: return null
        return raw
            .replace(" ", "")
            .replace(".", "")
            .replace(',', '.')
            .toDoubleOrNull()
    }
}
