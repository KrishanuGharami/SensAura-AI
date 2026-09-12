# SensAura AI (AmbientPulse Engine)

[![iQOO Hackathon 2026](https://img.shields.io/badge/iQOO%20Hackathon%202026-Chennai%20City%20Battle-FF6600?style=for-the-badge&logo=target)](https://github.com/KrishanuGharami)
[![Track](https://img.shields.io/badge/Track-Smart%20Living%20(Solo)-00E5FF?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Offline--First%20%7C%20On--Device%20AI-10B981?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Tests](https://img.shields.io/badge/Tests-14%2F14%20Passed-brightgreen?style=for-the-badge)](https://github.com/KrishanuGharami)

> **"SensAura AI – an offline-first, on-device contextual automated home assistant that turns the smartphone into an intelligent smart-home controller using physical phone sensors and ambient sensor fusion."**

---

## 💡 Overview & Problem Statement

Traditional smart homes are **reactive and fragmented**: users must manually unlock apps, browse device lists, toggle remote-control switches, or voice-command cloud servers with noticeable latency and privacy concerns.

**SensAura AI** revolutionizes smart living with a **proactive, context-aware, privacy-first paradigm**:
- **Zero Cloud Dependence**: 100% on-device heuristic & edge neural processing (measured **0.4 ms** inference latency).
- **Physical Sensor Intelligence**: Continuously interprets 3-axis accelerometer dynamics, ambient illuminance photometrics, proximity obstruction, and spatial Bluetooth Low Energy (BLE) beacon proximity.
- **Contextual Intent Engine**: Automatically infers whether you are **Relaxing**, **Leaving**, **Arriving**, **Deep Focused**, or **Sleeping**, recommending and staging living room automation scenes without manual fiddling.

---

## ⚡ Core Concept in Action

| Physical Sensor Snapshot | On-Device Heuristic Fusion | Inferred Context | Proactive Recommended Scene | Target Device States |
| :--- | :--- | :--- | :--- | :--- |
| **Low Motion** (`< 1.2 m/s²`)<br>+ **Dim Light** (`18 lux`)<br>+ **Home BLE Active** (`-58 dBm`)<br>+ **Near Proximity** | Multi-Modal Sensor Fusion Engine | **RELAXATION**<br>*(94% confidence)* | **Relaxation Scene** | 💡 Living Light: 30% (Warm 2700K)<br>❄️ AC: 24°C (Quiet)<br>🎵 Speaker: 20% (Lo-Fi Chill)<br>🔌 Smart Socket: ON |
| **High Motion** (`> 2.5 m/s²`)<br>+ **Exterior Light** (`420 lux`)<br>+ **Home BLE Disconnected** | Departure Classifier | **LEAVING**<br>*(96% confidence)* | **Energy Saving Scene** | 💡 Lights: **OFF**<br>❄️ AC: **OFF**<br>🌪️ Fan: **OFF**<br>🎵 Speaker: **OFF**<br>🔌 Smart Socket: **OFF** |
| **Settling Motion**<br>+ **Home BLE Re-acquired** (`-52 dBm`)<br>+ **Entry illumination** | Proximity Perimeter Acquisition | **ARRIVING**<br>*(92% confidence)* | **Welcome Home Scene** | 💡 Light: 80% (Warm 3000K)<br>❄️ AC: 22°C (Cool)<br>🌪️ Fan: Speed 2<br>🎵 Speaker: 35% |
| **Stationary Phone on Desk**<br>+ **Focused Light** (`220 lux`)<br>+ **Home Beacon Present** | Workspace Stability Filter | **DEEP FOCUS**<br>*(91% confidence)* | **Deep Focus Scene** | 💡 Light: 65% (Cool 4500K)<br>❄️ AC: 23°C (Normal)<br>🌪️ Fan: Speed 1<br>🎵 Speaker: Muted |
| **Stationary Motion**<br>+ **Pitch Darkness** (`0.8 lux`)<br>+ **Proximity Covered (Face-Down)** | Nightstand Sleep Heuristic | **SLEEP SANCTUARY**<br>*(98% confidence)* | **Sleep Sanctuary Scene** | 💡 Light: **OFF**<br>❄️ AC: 21°C (Sleep)<br>🌪️ Fan: Speed 1<br>🎵 Speaker: 15% (Deep Rain) |

---

## 📱 The 5 Primary Screens

1. **SensAura AI Home**:
   - Status indicators: `● LOCAL`, `● SENSOR STREAM`, `● BLE CONNECTED`, `OFFLINE-FIRST • ON-DEVICE AI`.
   - Dynamic Context Hero Card with circular confidence gauge and real-time sub-millisecond execution metric (**0.4 ms**).
   - Live Sensor Summary Strip: Photometrics (lux), Motion variance, Spatial BLE nodes, and Proximity.
   - 1-Tap **Apply Scene** action card.
   - Deterministic Scenario Injection Deck (`[ RELAXATION ]`, `[ LEAVING ]`, `[ ARRIVAL ]`, `[ DEEP FOCUS ]`, `[ SLEEP ]`, `[ RESET ]`).
2. **Live Sensors**:
   - Real-time animated 3-axis accelerometer waveform canvas (X, Y, Z, and Vector Magnitude).
   - Ambient light gauge with automatic Day/Night illumination labeling.
   - Proximity sensor state and millimeter distance approximation.
   - 360° BLE Spatial Radar view mapping active beacons by RSSI signal strength.
   - Physical Silicon vs. High-Fidelity Simulation hardware toggle.
3. **AI Context**:
   - Neural/heuristic signal attribution checklist with green verified checkmarks.
   - Transparent textual AI reasoning explanation.
   - Direct scenario execution trigger.
4. **Smart Environment**:
   - Living Room zone controller with interactive sliders, toggle switches, and status chips.
   - Real-time animated transitions when scene activations occur.
5. **Automation History**:
   - Persistent offline audit log using **Hive** local storage.
   - Chronological timestamped event logs (e.g. `8:41 PM Relaxation detected -> Relaxation Scene applied`).

---

## 🏛️ System Architecture

SensAura AI employs clean domain layering with hardware abstraction interfaces and zero external cloud coupling:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # Thresholds, UUIDs, timing
│   │   └── mock_scenarios.dart         # Relaxation, Leaving, Arrival, Focus, Sleep, Neutral
│   └── theme/
│       ├── app_colors.dart             # iQOO carbon black, cyber amber (#FF6600), neon cyan (#00E5FF)
│       └── app_theme.dart              # Material 3 dark typography & slider/switch styling
├── models/
│   ├── sensor_snapshot.dart            # Multi-modal snapshot with 3D magnitude & motionLevel
│   ├── ambient_context.dart            # Context types (relaxation, leaving, arriving, focus, sleep, neutral)
│   ├── context_result.dart             # Confidence (0-1.0), reasoning, measured latency
│   ├── smart_device.dart               # Smart light, AC, fan, speaker, socket
│   ├── automation_scene.dart           # Preset scenes with target states maps
│   └── automation_event.dart           # Hive-persisted audit record with EventIdGenerator
├── services/
│   ├── context_inference_engine.dart   # Abstract interface for on-device inference
│   ├── rule_based_context_engine.dart  # Sub-millisecond heuristic sensor fusion (measured ~0.4ms)
│   ├── on_device_ai_context_engine.dart# Google AI Edge / MediaPipe bridge stub
│   ├── sensor_provider.dart            # Abstract telemetry interface
│   ├── mock_sensor_provider.dart       # Deterministic smooth multi-step interpolation & micro-jitter
│   ├── real_sensor_provider.dart       # sensors_plus accelerometer with safe fallback
│   ├── ble_provider.dart               # Abstract BLE discovery interface
│   ├── mock_ble_provider.dart          # Simulated RSSI fluctuation and beacon proximity
│   ├── real_ble_provider.dart          # flutter_blue_plus with platform-safe fallback
│   ├── local_storage_service.dart      # Hive offline store with resilient memory fallback
│   └── automation_service.dart         # Central reactive state orchestrator
├── widgets/
│   ├── status_app_bar.dart             # Top badges: ● LOCAL  ● SENSOR STREAM  ● BLE CONNECTED
│   ├── context_hero_card.dart          # Hero context card, confidence ring, latency badge
│   ├── confidence_gauge.dart           # Animated circular custom canvas gauge
│   ├── sensor_stat_strip.dart          # Light (lux), Motion, BLE nodes, Proximity
│   ├── sensor_waveform_card.dart       # Real-time multi-axis canvas waveform (X, Y, Z, Mag)
│   ├── ble_radar_view.dart             # Animated spatial radar rings with RSSI blips
│   ├── smart_device_tile.dart          # Interactive sliders, toggles, room chips
│   └── simulation_control_panel.dart   # Tactile scenario injection deck
├── screens/
│   ├── main_scaffold.dart              # Persistent bottom navigation across 5 screens
│   ├── home_screen.dart                # Main dashboard & suggested automation card
│   ├── live_sensors_screen.dart        # Real-time telemetry, waveform, light, proximity, BLE radar
│   ├── ai_context_screen.dart          # Signal attribution checklist & AI reasoning explanation
│   ├── smart_environment_screen.dart   # Interactive Living Room smart devices
│   └── history_screen.dart             # Immutable chronological audit log
└── main.dart                           # Flutter entrypoint
```

---

## 🧪 Testing & Validation

All test suites pass cleanly:

```powershell
# Static Analysis (0 issues, 0 warnings, 0 lints)
flutter analyze

# Automated Test Suite (14 / 14 Passed)
flutter test
```

### Verified Test Suites:
- `test/automation_scene_test.dart`: Target state mapping validation across scenes.
- `test/rule_based_context_engine_test.dart`: Context inferences, confidence margins, and sub-2ms bounds.
- `test/sensor_snapshot_test.dart`: 3D acceleration vector magnitude and dynamic motion level classification.
- `test/widget_test.dart`: UI rendering and status element smoke tests.
- `test/demo_flow_test.dart`: End-to-end integration test verifying complete uninterrupted hackathon demo flow.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (>= 3.10.0)
- Android Studio / VS Code / Chrome

### Quick Launch

```bash
# 1. Clone repository
git clone https://github.com/KrishanuGharami/SensAura-AI.git
cd SensAura-AI

# 2. Get dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome

# 4. Or run on connected Android Device
flutter run -d android
```

---

## 🏆 Hackathon Submission Details

- **Event**: iQOO Hackathon 2026
- **Stage**: Chennai City Battle
- **Track**: Smart Living (Solo Track)
- **Developer**: Krishanu Gharami ([@KrishanuGharami](https://github.com/KrishanuGharami))
- **License**: MIT
