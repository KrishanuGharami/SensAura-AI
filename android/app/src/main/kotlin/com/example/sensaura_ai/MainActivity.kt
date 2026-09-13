package com.example.sensaura_ai

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val LIGHT_CHANNEL = "sensaura/sensors/light"
    private val PROXIMITY_CHANNEL = "sensaura/sensors/proximity"
    private val CAPABILITIES_CHANNEL = "sensaura/sensors/capabilities"

    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var proximitySensor: Sensor? = null
    private val registeredListeners = mutableSetOf<SensorEventListener>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)
        proximitySensor = sensorManager?.getDefaultSensor(Sensor.TYPE_PROXIMITY)

        // MethodChannel for hardware capabilities detection
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAPABILITIES_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCapabilities" -> {
                    val capabilities = mapOf(
                        "hasLightSensor" to (lightSensor != null),
                        "hasProximitySensor" to (proximitySensor != null),
                        "hasAccelerometer" to (sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null),
                        "hasGyroscope" to (sensorManager?.getDefaultSensor(Sensor.TYPE_GYROSCOPE) != null)
                    )
                    result.success(capabilities)
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel for Ambient Light Sensor (TYPE_LIGHT)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, LIGHT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var listener: SensorEventListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (lightSensor == null || events == null) {
                        events?.error("SENSOR_UNAVAILABLE", "Ambient light sensor not available", null)
                        return
                    }
                    listener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            event?.let {
                                if (it.values.isNotEmpty()) {
                                    events.success(it.values[0].toDouble())
                                }
                            }
                        }
                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }
                    sensorManager?.registerListener(listener, lightSensor, SensorManager.SENSOR_DELAY_NORMAL)
                    listener?.let { registeredListeners.add(it) }
                }

                override fun onCancel(arguments: Any?) {
                    listener?.let {
                        sensorManager?.unregisterListener(it)
                        registeredListeners.remove(it)
                    }
                    listener = null
                }
            }
        )

        // EventChannel for Proximity Sensor (TYPE_PROXIMITY)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PROXIMITY_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var listener: SensorEventListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (proximitySensor == null || events == null) {
                        events?.error("SENSOR_UNAVAILABLE", "Proximity sensor not available", null)
                        return
                    }
                    val maxRange = proximitySensor?.maximumRange ?: 5.0f
                    listener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            event?.let {
                                if (it.values.isNotEmpty()) {
                                    val distance = it.values[0].toDouble()
                                    // Map distance: true if near (< maxRange or < 5cm)
                                    val isNear = distance < maxRange.toDouble() || distance < 1.0
                                    val result = mapOf(
                                        "distance" to distance,
                                        "isNear" to isNear
                                    )
                                    events.success(result)
                                }
                            }
                        }
                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }
                    sensorManager?.registerListener(listener, proximitySensor, SensorManager.SENSOR_DELAY_NORMAL)
                    listener?.let { registeredListeners.add(it) }
                }

                override fun onCancel(arguments: Any?) {
                    listener?.let {
                        sensorManager?.unregisterListener(it)
                        registeredListeners.remove(it)
                    }
                    listener = null
                }
            }
        )
    }

    override fun onDestroy() {
        registeredListeners.toList().forEach { sensorManager?.unregisterListener(it) }
        registeredListeners.clear()
        super.onDestroy()
    }
}
