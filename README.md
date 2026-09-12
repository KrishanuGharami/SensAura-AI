# SensAura AI (AmbientPulse Engine)

[![iQOO Hackathon 2026](https://img.shields.io/badge/iQOO%20Hackathon%202026-Chennai%20City%20Battle-FF6600?style=for-the-badge&logo=target)](https://github.com/KrishanuGharami)
[![Track](https://img.shields.io/badge/Track-Smart%20Living%20(Solo)-00E5FF?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Offline--First%20%7C%20On--Device%20AI-10B981?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Tests](https://img.shields.io/badge/Tests-24%2F24%20Passed-brightgreen?style=for-the-badge)](https://github.com/KrishanuGharami)
[![Context Guard](https://img.shields.io/badge/Safety-SensAura%20Context%20Guard-10B981?style=for-the-badge)](https://github.com/KrishanuGharami)

> **"SensAura AI – an offline-first, on-device contextual automated home assistant that turns the smartphone into an intelligent smart-home controller using physical phone sensors, ambient sensor fusion, and SensAura Context Guard."**

---

## 🛡️ SensAura Context Guard Safety Layer

SensAura Context Guard is a deterministic safety gate that sits between the sensor inference engine and smart home actuators to prevent unsafe, jittery, or conflicting automations:

- **AUTO_SAFE**: High confidence (≥ 0.85) AND verified physical presence AND no active manual override AND no conflicting signals AND automation cooldown expired.
- **ASK_USER**: Moderate confidence (0.60 – 0.85) OR presence unconfirmed. Requires user confirmation before applying scene.
- **NO_ACTION**: Low confidence (< 0.60) OR sensory signals conflict OR manual override lease active OR automation cooldown active.

### Real-World Robustness Mechanisms:
1. **Sensor Hysteresis / Temporal Stabilization**: 3-sample window buffer prevents context thrashing from isolated sensor noise.
2. **Automation Cooldown**: 45-second lock prevents repetitive, disruptive scene updates.
3. **Manual Override Protection**: 180-second user lock respects manual device adjustments, pausing auto-overwrites until expired or explicitly released.
4. **Signal Conflict Detection**: Flags contradictory sensor combinations (e.g., transit-level motion + high ambient lux while connected to home BLE beacon) as **`UNCERTAIN`**, automatically pausing automation.
5. **Full Explainability**: Home dashboard clearly itemizes detected signals (attribution) and Context Guard criteria checks (✓/✗).

---

## ⚡ Core Concept in Action

| Physical Sensor Snapshot | On-Device Heuristic Fusion | Context Guard Decision | Recommended Action | Target Device States |
| :--- | :--- | :--- | :--- | :--- |
| **Low Motion** (`< 1.2 m/s²`)<br>+ **Dim Light** (`18 lux`)<br>+ **Home BLE Active** (`-58 dBm`) | **RELAXATION**<br>*(94% confidence)* | **AUTO_SAFE**<br>*(Presence verified, cooldown ready)* | **Relaxation Scene**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Living Light: 30% (Warm 2700K)<br>❄️ AC: 24°C (Quiet)<br>🎵 Speaker: 20% (Lo-Fi Chill)<br>🔌 Smart Socket: ON |
| **High Motion** (`> 2.5 m/s²`)<br>+ **Exterior Light** (`420 lux`)<br>+ **Home BLE Disconnected** | **LEAVING**<br>*(96% confidence)* | **AUTO_SAFE**<br>*(Departure verified)* | **Energy Saving Scene**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Lights: **OFF**<br>❄️ AC: **OFF**<br>🌪️ Fan: **OFF**<br>🎵 Speaker: **OFF**<br>🔌 Smart Socket: **OFF** |
| **Settling Motion**<br>+ **Home BLE Re-acquired** (`-52 dBm`)<br>+ **Entry illumination** | **ARRIVING**<br>*(92% confidence)* | **AUTO_SAFE**<br>*(Presence acquired)* | **Welcome Home Scene**<br>`[APPLY SCENE (AUTO SAFE)]` | 💡 Light: 80% (Warm 3000K)<br>❄️ AC: 22°C (Cool)<br>🌪️ Fan: Speed 2<br>🎵 Speaker: 35% |
| **High Motion** (`13.8 m/s²`)<br>+ **High Light** (`420 lux`)<br>+ **Home BLE Active** (`-55 dBm`) | **UNCERTAIN**<br>*(50% confidence - Conflict)* | **NO_ACTION**<br>*(Automation paused: Conflicting signals)* | **Automation Paused**<br>`[PAUSED • SIGNALS CONFLICT]` | 🔒 Devices remain unchanged.<br>User notified of signal conflict. |
| **User Adjusted Device Slider**<br>*(Within last 180s)* | Any detected context | **NO_ACTION**<br>*(Manual override lease active)* | **Automation Paused**<br>`[PAUSED • MANUAL OVERRIDE]` | 🔒 Device state preserved.<br>`[Release Lock]` available on dashboard. |
| **Scene Applied < 45s Ago** | Any detected context | **NO_ACTION**<br>*(Cooldown active)* | **Automation Paused**<br>`[PAUSED • COOLDOWN ACTIVE]` | 🔒 Fluttering prevented.<br>`[Reset Timer]` available for demo. |

---

## 📱 The 5 Primary Screens

1. **SensAura AI Home**:
   - Status badges: `● LOCAL`, `● SENSOR STREAM`, `● BLE CONNECTED`, `OFFLINE-FIRST • ON-DEVICE AI`.
   - Dynamic Context Hero Card with circular confidence gauge and real-time execution latency (**0.4 ms**).
   - Live Sensor Summary Strip: Photometrics (lux), Motion variance, Spatial BLE nodes, and Proximity.
   - **SensAura Context Guard Card**: Shows active safety decision (`AUTO_SAFE`, `ASK_USER`, `AUTOMATION PAUSED`), rationale, signals checklist, and safety criteria.
   - Guarded **Apply Scene** action button dynamically reflecting safety readiness.
   - Deterministic Scenario Injection Deck (`[ RELAXATION ]`, `[ LEAVING ]`, `[ ARRIVAL ]`, `[ DEEP FOCUS ]`, `[ SLEEP ]`, `[ UNCERTAIN ]`, `[ RESET NEUTRAL ]`).
2. **Live Sensors**:
   - Real-time animated 3-axis accelerometer waveform canvas (X, Y, Z, and Vector Magnitude).
   - Ambient light gauge with automatic Day/Night illumination labeling.
   - Proximity sensor state and millimeter distance approximation.
   - 360° BLE Spatial Radar view mapping active beacons by RSSI signal strength.
   - Physical Silicon vs. High-Fidelity Simulation hardware toggle.
3. **AI Context**:
   - Neural/heuristic signal attribution checklist with verified checkmarks.
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
│   │   ├── app_constants.dart          # Thresholds, UUIDs, timing, cooldown & override constants
│   │   └── mock_scenarios.dart         # Relaxation, Leaving, Arrival, Focus, Sleep, Uncertain, Neutral
│   └── theme/
│       ├── app_colors.dart             # iQOO carbon black, cyber amber (#FF6600), neon cyan (#00E5FF)
│       └── app_theme.dart              # Material 3 dark typography & slider/switch styling
├── models/
│   ├── sensor_snapshot.dart            # Multi-modal snapshot with 3D magnitude & motionLevel
│   ├── ambient_context.dart            # Context types (relaxation, leaving, arriving, focus, sleep, neutral, uncertain)
│   ├── context_result.dart             # Confidence (0-1.0), reasoning, measured latency, guardResult
│   ├── context_guard_result.dart       # ContextGuardDecision (autoSafe, askUser, noAction), checks, explainability
│   ├── smart_device.dart               # Smart light, AC, fan, speaker, socket
│   ├── automation_scene.dart           # Preset scenes with target states maps
│   └── automation_event.dart           # Hive-persisted audit record with EventIdGenerator
├── services/
│   ├── context_guard.dart              # SensAura Context Guard safety evaluation gate
│   ├── context_inference_engine.dart   # Abstract interface for on-device inference
│   ├── rule_based_context_engine.dart  # Sub-millisecond heuristic sensor fusion & conflict detector
│   ├── on_device_ai_context_engine.dart# Google AI Edge / MediaPipe bridge stub
│   ├── sensor_provider.dart            # Abstract telemetry interface
│   ├── mock_sensor_provider.dart       # Deterministic smooth multi-step interpolation & micro-jitter
│   ├── real_sensor_provider.dart       # sensors_plus accelerometer with safe fallback
│   ├── ble_provider.dart               # Abstract BLE discovery interface
│   ├── mock_ble_provider.dart          # Simulated RSSI fluctuation and beacon proximity
│   ├── real_ble_provider.dart          # flutter_blue_plus with platform-safe fallback
│   ├── local_storage_service.dart      # Hive offline store with resilient memory fallback
│   └── automation_service.dart         # Central reactive state orchestrator (cooldown, override, hysteresis)
├── widgets/
│   ├── status_app_bar.dart             # Top badges: ● LOCAL  ● SENSOR STREAM  ● BLE CONNECTED
│   ├── context_hero_card.dart          # Hero context card, confidence ring, latency badge, guard tag
│   ├── confidence_gauge.dart           # Animated circular custom canvas gauge
│   ├── sensor_stat_strip.dart          # Light (lux), Motion, BLE nodes, Proximity
│   ├── sensor_waveform_card.dart       # Real-time multi-axis canvas waveform (X, Y, Z, Mag)
│   ├── ble_radar_view.dart             # Animated spatial radar rings with RSSI blips
│   ├── smart_device_tile.dart          # Interactive sliders, toggles, room chips
│   └── simulation_control_panel.dart   # Tactile scenario injection deck with UNCERTAIN & NEUTRAL
├── screens/
│   ├── main_scaffold.dart              # Persistent bottom navigation across 5 screens
│   ├── home_screen.dart                # Main dashboard, Context Guard explainability & suggested scene
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

# Automated Test Suite (24 / 24 Passed)
flutter test
```

### Verified Test Suites:
- `test/context_guard_test.dart`: Exhaustive validation of `AUTO_SAFE`, `ASK_USER`, and `NO_ACTION` rules, threshold bounds (0.85, 0.60), conflict overrides, manual override locks, and cooldown locks.
- `test/rule_based_context_engine_test.dart`: Multi-modal inferences, confidence calculations, sub-2ms bounds, and contradictory signal conflict detection (`UNCERTAIN` context).
- `test/automation_scene_test.dart`: Target state mapping validation across scenes.
- `test/sensor_snapshot_test.dart`: 3D acceleration vector magnitude and dynamic motion level classification.
- `test/widget_test.dart`: UI rendering, Context Guard cards, and status element smoke tests.
- `test/demo_flow_test.dart`: End-to-end integration test verifying complete uninterrupted demo flow including scenario injection, Context Guard gating, cooldown, manual overrides, and offline audit logging.

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
