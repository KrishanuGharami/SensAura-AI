# SensAura AI — AmbientPulse Engine

[![iQOO Hackathon 2026](https://img.shields.io/badge/iQOO%20Hackathon%202026-Chennai%20City%20Battle-FF6600?style=for-the-badge&logo=target)](https://github.com/KrishanuGharami)
[![Track](https://img.shields.io/badge/Track-Smart%20Living%20(Solo)-00E5FF?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Target Device](https://img.shields.io/badge/Target%20Device-iQOO%2015%20%7C%20OriginOS%206-FF6600?style=for-the-badge&logo=android)](https://github.com/KrishanuGharami)
[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-100%25%20Offline--First%20%7C%20On--Device%20AI-10B981?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Tests](https://img.shields.io/badge/Tests-80%2F80%20Passed%20(100%25)-brightgreen?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Context Guard](https://img.shields.io/badge/Safety-SensAura%20Context%20Guard-10B981?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Multilingual](https://img.shields.io/badge/Languages-6%20Indian%20Languages-9333EA?style=for-the-badge)](https://github.com/KrishanuGharami)

> **"Sense your world. Shape your space."**  
> SensAura AI transforms the smartphone into an offline-first ambient intelligence layer. Built and battle-tested for the **iQOO 15 (Snapdragon 8 Elite Gen 5, Android 16 / OriginOS 6)**, it senses motion, ambient illumination, proximity, BLE spatial presence, posture, and computer vision gestures to autonomously orchestrate smart living workspaces under deterministic **SensAura Context Guard** safety guarantees.

---

## 🌟 What Makes SensAura AI Unique?

1. **Phone-First Ambient Sensing**: Eliminates expensive proprietary IoT sensor hubs by turning the physical smartphone into a high-precision multi-modal context radar.
2. **Zero Cloud Dependence**: 100% on-device heuristic & neural fusion. Sensor telemetry, camera frames, and context decisions **never leave the phone**.
3. **SensAura Context Guard**: A deterministic safety gate enforcing hysteresis, cooldowns, manual override leases, and signal conflict suppression (`AUTO_SAFE`, `ASK_USER`, `AUTOMATION PAUSED`).
4. **Physical & Connected Actuators**:
   - **Workstation Laptop Actuator (`SensAura Node`)**: Direct LAN-based orchestration of developer workstations (DND, focus audio, screen lock) via secure HMAC tokens.
   - **Demo Connected Environment Actuator**: Complete smart-room simulation (Desk Lamp, Smart AC, Ergonomic Screen, Audio Ambience, Smart Socket) with real-time state machines, round-trip acknowledgements, and retry handling.
5. **Real-Time Camera & Vision Context**: Live camera pipeline evaluating sitting posture, face presence, fatigue indicators, and hand gestures (`✋ Pause`, `👍 Confirm`, `👎 Dismiss`, `✌️ Focus`, `✊ Rest`).
6. **100% Offline-First Multilingual UI**: Seamless in-app switching across **6 Indian languages** (English, Hindi, Tamil, Telugu, Malayalam, Kannada) with zero pipeline disruption.

---

## 🛡️ SensAura Context Guard Safety Layer

SensAura Context Guard is a deterministic safety gate interposed between the context inference engines and smart actuators to prevent erratic, flapping, or conflicting automations:

```
[ Sensor Streams + Camera + BLE ]
               │
               ▼
[ Context Inference Engine (Sub-2ms) ]
               │
               ▼
[ SensAura Context Guard Safety Gate ]
       │                │                │
       ▼                ▼                ▼
   AUTO_SAFE         ASK_USER      AUTOMATION PAUSED
  (Confidence ≥85%  (Confidence     (Conflict, Cooldown,
  & Presence True)   60% - 84%)     or Manual Override)
       │                │                │
       ▼                ▼                ▼
 Direct Execution  User Prompt     Zero Actuation
```

### Real-World Safety Rules:
1. **Sensor Hysteresis / Temporal Stabilization**: 3-sample temporal buffer prevents fluttering from transient sensor spikes.
2. **Automation Cooldown**: 45-second lock prevents repetitive, disruptive scene flapping.
3. **Manual Override Protection**: 180-second user lock respects manual slider/switch adjustments, withholding auto-overwrites until expired or explicitly released.
4. **Signal Conflict Suppression**: Contradictory inputs (e.g., transit-level motion + high lux while connected to home BLE beacon) resolve to **`UNCERTAIN`**, immediately pausing automation.
5. **Full Explainability**: Live dashboard displays transparent attribution checklists and safety criteria checks (`✓ / ✗`).

---

## ⚡ Ambient Context Matrix

| Physical Sensor Snapshot | On-Device Fusion | Context Guard Decision | Recommended Action | Actuator State |
| :--- | :--- | :--- | :--- | :--- |
| **Low Motion** (`< 1.2 m/s²`)<br>+ **Optimal Light** (`220 lux`)<br>+ **Upright Posture** | **FOCUS**<br>*(94% confidence)* | **AUTO_SAFE**<br>*(Presence verified)* | **Focus Workspace**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Light: 80% (Cool 4000K)<br>❄️ AC: 22°C<br>💻 Laptop: DND Enabled<br>🔌 Socket: ON |
| **Minimal Motion** (`< 0.8 m/s²`)<br>+ **Dim Light** (`18 lux`)<br>+ **Relaxed Posture** | **REST / RELAX**<br>*(95% confidence)* | **AUTO_SAFE**<br>*(Presence verified)* | **Restoration Scene**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Light: 30% (Warm 2700K)<br>❄️ AC: 24°C (Quiet)<br>💻 Laptop: DND Disabled<br>🎵 Ambient Sound: ON |
| **High Motion** (`> 2.5 m/s²`)<br>+ **Exterior Light** (`450 lux`)<br>+ **BLE Disconnected** | **LEAVING**<br>*(96% confidence)* | **AUTO_SAFE**<br>*(Departure verified)* | **Energy Saver**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Light: **OFF**<br>❄️ AC: **OFF**<br>💻 Laptop: Screen Locked<br>🔌 Socket: **OFF** |
| **Settling Motion**<br>+ **Home BLE Re-acquired** (`-52 dBm`)<br>+ **Entry illumination** | **ARRIVING**<br>*(92% confidence)* | **AUTO_SAFE**<br>*(Presence acquired)* | **Welcome Workspace**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Light: 75% (Warm 3000K)<br>❄️ AC: 23°C<br>💻 Laptop: Waking up |
| **Contradictory Signals**<br>*(High motion + BLE docked)* | **UNCERTAIN**<br>*(50% confidence)* | **AUTOMATION PAUSED**<br>`[PAUSED • SIGNALS CONFLICT]` | **No Action** | 🔒 Devices remain untouched.<br>User notified of ambiguity. |
| **Manual User Adjustment**<br>*(Within last 180s)* | Any detected context | **AUTOMATION PAUSED**<br>`[PAUSED • MANUAL OVERRIDE]` | **No Action** | 🔒 Active override lease preserved.<br>`[Release Lock]` available. |

---

## 🌐 100% Offline-First Multilingual UI

SensAura AI natively supports **6 major Indian languages**:

| Language | Native Name | Code | Status |
|---|---|---|---|
| **English** | English | `en` | Default / Fallback |
| **Hindi** | हिन्दी | `hi` | 100% Translated & Verified |
| **Tamil** | தமிழ் | `ta` | 100% Translated & Verified |
| **Telugu** | తెలుగు | `te` | 100% Translated & Verified |
| **Malayalam** | മലയാളം | `ml` | 100% Translated & Verified |
| **Kannada** | ಕನ್ನಡ | `kn` | 100% Translated & Verified |

- **Instant Zero-Restart Switcher**: Accessible directly from the top `StatusAppBar` (`🌐 தமிழ்`, `🌐 हिन्दी`, etc.). Language updates instantly rebuild the UI without interrupting background sensor feeds, camera previews, BLE streams, or Context Guard timers.
- **Offline Persistence**: Selected locale is stored in local Hive storage (`LocalStorageService`) and restored automatically across app restarts.
- **Robust Font Fallback**: Utilizes `Noto Sans` font fallbacks across Devanagari, Tamil, Telugu, Malayalam, and Kannada scripts to eliminate glyph clipping and tofu boxes.

---

## 📱 The 5 Application Screens

1. **SensAura AI Home (`HomeScreen`)**:
   - Status badges: `● LOCAL`, `● SENSOR STREAM`, `● BLE CONNECTED`, `OFFLINE-FIRST`.
   - Dynamic **Context Hero Card** with circular confidence gauge and sub-millisecond execution latency (**0.4 ms**).
   - **Live Sensor Summary Strip**: Photometrics (lux), Motion variance, Spatial BLE nodes, Proximity.
   - **SensAura Context Guard Card**: Shows active safety decision (`AUTO_SAFE`, `ASK_USER`, `AUTOMATION PAUSED`), rationale, signals checklist, and safety criteria.
   - Guarded **Apply Scene** action button dynamically reflecting safety readiness.
   - Interactive Scenario Injection Deck (`[ FOCUS ]`, `[ REST ]`, `[ ARRIVING ]`, `[ LEAVING ]`, `[ UNCERTAIN ]`, `[ RESET ]`).
2. **Live Sensors (`LiveSensorsScreen`)**:
   - Real-time animated 3-axis accelerometer waveform canvas (X, Y, Z, and Vector Magnitude).
   - Ambient light gauge with automatic Day/Night illumination labeling.
   - Proximity sensor state and millimeter distance approximation.
   - 360° BLE Spatial Radar view mapping active beacons by RSSI signal strength.
   - Physical Silicon vs. High-Fidelity Simulation hardware toggle.
3. **Smart Environment (`ConnectedDevicesScreen`)**:
   - Living Room zone controller with interactive sliders, toggle switches, and status chips.
   - Connected Environment demo disclosure, state machine badges (`ON`, `OFF`, `Standby`, `Acknowledged`).
   - Manual override lease alert with one-tap `[Release Lock]` action.
4. **AI Context & Vision (`AiContextScreen`)**:
   - Real-time camera preview running on physical iQOO 15 hardware.
   - AI Computer Vision overlay toggle with posture and gesture indicators.
   - Gesture intent palette (`✋ Pause`, `👍 Confirm`, `👎 Dismiss`, `✌️ Focus`, `✊ Rest`).
   - Transparent textual AI reasoning explanation and attribution checklist.
5. **Automation History (`HistoryScreen`)**:
   - Persistent offline audit log using **Hive** local storage.
   - Chronological timestamped event logs (e.g. `10:24 AM FOCUS detected -> Workstation Focus Scene applied [Latency: 12ms]`).
   - One-tap history export and clear log actions.

---

## 🏛️ System Architecture

SensAura AI is architected with strict separation of concerns, hardware abstraction interfaces, and zero external cloud coupling:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Physical iQOO 15 Sensor Hardware                     │
│   • Accelerometer & Gyro   • Ambient Light   • Proximity   • BLE 6.0    │
│   • Physical Camera (Front/Rear Preview & Video Frames)                 │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     SensAura Sensing & Vision Layer                     │
│   • RealSensorProvider (accelerometer, gyro, lux, proximity)           │
│   • RealBleProvider (flutter_blue_plus scanner & RSSI radar)            │
│   • RealCameraProvider (camera controller & lifecycle management)      │
│   • VisionTemporalFusionEngine (gesture, posture & expression filter)   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     On-Device Context Engine (< 2ms)                    │
│   • RuleBasedContextEngine: Sub-millisecond sensor fusion               │
│   • Multi-modal Confidence Scoring & Contradiction Detection            │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   🛡️ SensAura Context Guard Safety Gate                │
│   • 3-Sample Hysteresis Buffer   • 45s Automation Cooldown              │
│   • 180s Manual Override Lease    • Explicit Attribution & Reasoning    │
│   • AUTO_SAFE  |  ASK_USER  |  AUTOMATION PAUSED                        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
            ┌────────────────────────┴────────────────────────┐
            ▼                                                 ▼
┌──────────────────────────────────────┐  ┌───────────────────────────────┐
│    Workstation Actuator Provider     │  │   Demo Environment Actuator   │
│  (SensAura Node LAN Companion)       │  │  (Smart Room State Machines)  │
│  • DND / Focus Mode Sync             │  │  • Desk Lamp (Brightness/CCT) │
│  • Volume & Media Ambience           │  │  • Smart AC (Cool/Eco)        │
│  • Workstation Screen Lock           │  │  • Ergonomic Screen & Sockets │
│  • HMAC Token Security               │  │  • Round-trip Acknowledgements│
└──────────────────┬───────────────────┘  └───────────────┬───────────────┘
                   │                                      │
                   └──────────────────┬───────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      UI & Offline Persistence Layer                     │
│   • Hive Local Storage (Audit History & Persisted User Locale)          │
│   • 6-Language Multilingual UI (Instant Zero-Restart Switcher)          │
│   • Material 3 Dark Futuristic Cyberpunk Theme (iQOO Cyber Amber)       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📂 Repository Structure

```
SensAura-AI/
├── companion/
│   └── sensaura_node.py                # Python workstation companion (LAN/Wi-Fi actuator)
├── android/                            # Native Android project (SDK 35/36, OriginOS 6 compatibility)
├── lib/
│   ├── core/
│   │   ├── constants/                  # Cooldowns, thresholds, mock scenarios
│   │   └── theme/                      # iQOO cyber amber (#FF6600), dark theme, font fallbacks
│   ├── l10n/                           # Standard ARB files & AppLocalizations (en, hi, ta, te, ml, kn)
│   ├── models/
│   │   ├── actuator_command.dart       # Actuator command & execution response
│   │   ├── ambient_context.dart        # AmbientContextType enum & localization extensions
│   │   ├── automation_event.dart       # Hive audit trail entity
│   │   ├── automation_scene.dart       # Scene definitions & target device maps
│   │   ├── automation_timeline_entry.dart
│   │   ├── context_guard_result.dart   # Guard decisions, explainability & localized badges
│   │   ├── context_result.dart         # Context result wrapper with latency & confidence
│   │   ├── pose_feature_snapshot.dart  # Pose & posture feature structures
│   │   ├── sensor_snapshot.dart        # 3D acceleration, lux, proximity snapshot
│   │   ├── smart_device.dart           # Smart device model & state capabilities
│   │   └── vision_context_sample.dart  # Hand gesture & facial expression models
│   ├── screens/
│   │   ├── ai_context_screen.dart      # Real camera preview & vision gesture palette
│   │   ├── connected_devices_screen.dart # Smart living environment controller
│   │   ├── history_screen.dart         # Immutable audit logs & clear action
│   │   ├── home_screen.dart            # Context Hero, Guard card, suggested automations
│   │   ├── live_sensors_screen.dart    # Real-time waveforms, lux gauge, BLE radar
│   │   └── main_scaffold.dart          # 5-tab navigation bar with dynamic localization
│   ├── services/
│   │   ├── actuator_provider.dart      # Unified actuator interface
│   │   ├── automation_service.dart     # Reactive state orchestrator (cooldown, override)
│   │   ├── ble_actuator_provider.dart  # BLE smart-home actuator interface
│   │   ├── camera_posture_provider.dart# Posture & vision telemetry interface
│   │   ├── context_guard.dart          # Deterministic safety gate implementation
│   │   ├── context_inference_engine.dart # Abstract inference interface
│   │   ├── demo_environment_actuator.dart# Simulated room actuator with realistic latency
│   │   ├── local_explanation_engine.dart # Human-readable decision explainability
│   │   ├── local_storage_service.dart  # Hive storage with memory fallback & locale store
│   │   ├── mediapipe_vision_provider.dart# Edge vision analysis pipeline
│   │   ├── real_ble_provider.dart      # flutter_blue_plus BLE scanner
│   │   ├── real_camera_provider.dart   # Real Android camera preview & frame processor
│   │   ├── real_sensor_provider.dart   # sensors_plus hardware sensor pipeline
│   │   ├── rule_based_context_engine.dart # Sub-2ms heuristic sensor fusion engine
│   │   ├── vision_temporal_fusion_engine.dart # Temporal gesture & posture smoothing
│   │   ├── voice_intent_provider.dart  # Voice intent parser interface
│   │   └── workstation_actuator_provider.dart # Laptop SensAura Node client (HTTP/LAN)
│   ├── widgets/
│   │   ├── ble_radar_view.dart         # Animated spatial BLE radar canvas
│   │   ├── confidence_gauge.dart       # Circular confidence indicator
│   │   ├── context_hero_card.dart      # Hero context card with confidence ring
│   │   ├── privacy_status_card.dart    # On-device privacy indicator
│   │   ├── sensor_stat_strip.dart      # Compact live sensor telemetry strip
│   │   ├── sensor_waveform_card.dart   # Real-time multi-axis accelerometer waveform
│   │   ├── smart_device_tile.dart      # Interactive device controls & sliders
│   │   ├── status_app_bar.dart         # Status badges & live language selector
│   │   └── vision_overlay_painter.dart # Real-time custom painter for vision bounding boxes
│   └── main.dart                       # Entry point with dynamic locale switching
└── test/                               # 80 unit, widget, and integration tests
```

---

## 🧪 Comprehensive Test Suite (80 / 80 Passed)

The entire codebase is verified by 80 automated unit, widget, and integration tests:

```powershell
# 1. Run static code analysis (0 errors, 0 warnings)
flutter analyze

# 2. Execute all 80 automated tests
flutter test
```

### Breakdown of Test Suites:
| Test Suite | Tests | Scope |
|---|---|---|
| `test/localization_test.dart` | **14** | All 6 languages, string completeness, model extensions, Hive persistence, widget language switcher |
| `test/demo_actuator_test.dart` | **10** | Demo actuator state machine, round-trip latency, retry handling, manual override protection |
| `test/real_camera_test.dart` | **10** | Real camera initialization, permissions, preview states, graceful fallbacks |
| `test/camera_vision_test.dart` | **8** | Computer vision temporal filtering, gesture detection, posture classification |
| `test/hardware_mvp_extensions_test.dart` | **8** | Physical sensor streams, BLE discovery, hardware-level error boundaries |
| `test/context_guard_test.dart` | **8** | Exhaustive `AUTO_SAFE`, `ASK_USER`, `AUTOMATION PAUSED` validation, cooldowns, override leases |
| `test/rule_based_context_engine_test.dart` | **7** | Multi-modal sensor fusion, confidence calculations, sub-2ms latency, contradiction detection |
| `test/p0_acceptance_test.dart` | **6** | End-to-end P0 hardware-to-actuator acceptance verification |
| `test/widget_test.dart` | **5** | Widget rendering, bottom navigation, status app bar smoke tests |
| `test/demo_flow_test.dart` | **4** | End-to-end jury demo simulation flow |

---

## 🚀 Quick Start & Installation

### Prerequisites
- [Flutter SDK](https://flutter.dev) (>= 3.24.0)
- Android SDK (API 35/36)
- Python 3.10+ (for optional Workstation Laptop Actuator)
- Target Device: **iQOO 15** or any modern Android smartphone

### 1. Build & Install Release APK to iQOO 15

```powershell
# 1. Clone the repository
git clone https://github.com/KrishanuGharami/SensAura-AI.git
cd SensAura-AI

# 2. Install Flutter dependencies
flutter pub get

# 3. Build release APK
flutter build apk --release

# 4. Install directly to connected iQOO 15 via ADB
flutter install
```
*The compiled APK will be located at: `build/app/outputs/flutter-apk/app-release.apk` (~53.6 MB).*

### 2. (Optional) Run the Laptop Companion Node

To enable the physical laptop actuator (DND, focus audio, screen lock):

```powershell
# Set an authentication token
$env:SENSAURA_NODE_TOKEN = "sensaura-secret-token"

# Run the companion node on the laptop
python companion\sensaura_node.py --host 0.0.0.0 --port 8765
```

In the app's **Connected Devices** screen, enter your laptop's local IP address (e.g. `192.168.1.5`) and port `8765`.

---

## 🎬 3-Minute Hackathon Jury Demo Walkthrough

1. **Step 1 — Show Physical Telemetry**:
   - Open the **Live Sensors** tab. Tilt and move the iQOO 15 to demonstrate live 3-axis accelerometer waveforms updating in real-time. Cover the light sensor to show ambient lux dropping.
2. **Step 2 — Trigger Context Fusion & Context Guard**:
   - Return to the **SensAura AI Home** tab. Place the phone flat on the desk.
   - Observe the engine detect **FOCUS** within **0.4 ms**.
   - Point out the **Context Guard Card**: status displays **`AUTO_SAFE`** with verified safety checks (`✓ High Confidence`, `✓ Presence Verified`, `✓ No Signal Conflict`).
3. **Step 3 — Actuation & Connected Environment**:
   - Tap **`APPLY SCENE (AUTO SAFE)`**.
   - Navigate to **Smart Environment**: observe Desk Lamp, AC, and Smart Sockets instantly transition to Focus settings with real-time round-trip latency (~15ms).
   - If the laptop companion is connected, demonstrate the laptop entering Do Not Disturb and muting notifications.
4. **Step 4 — Real Camera & Gesture Control**:
   - Switch to the **AI Context** tab. Show the live iQOO camera preview.
   - Demonstrate the hand gesture palette (`✋ Pause Automation` to halt automations or `✌️ Focus Mode`).
5. **Step 5 — Live Multilingual Switching**:
   - Tap the top-right `🌐 Language` button in the app bar.
   - Select **தமிழ் (Tamil)** or **हिन्दी (Hindi)**.
   - Point out how the entire UI instantly localizes without stopping the camera feed, dropping sensor streams, or interrupting active cooldown timers.
6. **Step 6 — Audit Trail**:
   - Open the **History** tab to show the permanent, offline Hive audit log recording every context decision, latency, and actuator acknowledgment.

---

## 🏆 Hackathon Submission Metadata

- **Event**: iQOO Hackathon 2026
- **Stage**: Chennai City Battle
- **Track**: Smart Living (Working Professional / Solo Track)
- **Target Hardware**: iQOO 15 (Snapdragon 8 Elite Gen 5, OriginOS 6)
- **Developer**: Krishanu Gharami ([@KrishanuGharami](https://github.com/KrishanuGharami))
- **License**: MIT
