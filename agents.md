# AGENTS.md — Add ARCore Depth API (Flutter + Native Android)

This file is a machine-friendly guide / handoff for adding ARCore Depth API support (same behavior as in **Vetra Depth Recorder**) to another mobile project that uses Flutter for UI and Native Android (Kotlin) for ARCore.

> Replace placeholders in `<>` with your project's names/paths (e.g. `<PROJECT_NAME>`, `<package>`).

---

## Goal
Integrate ARCore Depth API so the app can:
- Detect device depth support and enable `Config.DepthMode.AUTOMATIC` when appropriate.
- Sample and stream the center depth (meters) to Flutter (≤5 Hz) for UI overlays.
- Capture and save a stride-correct `depth.bin` (raw `uint16` little-endian, W×H×2 bytes) and return `DepthInfo` JSON.
- Compute depth intrinsics scaled to the color camera intrinsics for alignment.

---

## Quick setup commands (example)

- Open Android module: `cd android && ./gradlew assembleDebug`
- Flutter: `flutter pub get && flutter run`

> Do not hardcode ARCore versions; pick the latest stable compatible with your project's policies.

---

## High-level API surface (MethodChannel)

Native (Kotlin) should expose via `MethodChannel` / `EventChannel`:

- `startSession(enableDepth: Boolean)` — configures AR session and depth mode.
- `stopSession()`
- `captureDepth()` → returns `{ success, depthFilePath, depthInfo }` JSON.
- `centerDepthStream` (event) — emits `float` center depth (meters) at a throttled rate.

---

## Native (Kotlin) Implementation Checklist

1. **Check Support & Configure Session**
   - `session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)` before enabling.
   - If supported and user enables depth, set `config.depthMode = Config.DepthMode.AUTOMATIC` and `depthSupported = true`; otherwise `DISABLED` and `depthSupported = false`.

2. **Acquire & Close Depth Image**
   - Use `frame.acquireDepthImage16Bits()` and always `depthImage.close()` in a `finally`.
   - Catch `NotYetAvailableException` and skip when depth is not ready.

3. **Read DEPTH16 Buffer (stride-aware)**
   - Use `plane.rowStride` and `plane.pixelStride`. Copy rows into an `out` buffer sized `width * height * 2`.
   - Example loop: read `rowStride` bytes per row into a `rowBuffer`, then extract `pixelStride`-spaced pairs of bytes.
   - Write `out` to `depth.bin` with `FileOutputStream.use { fos.write(out) }`.

4. **Sample Center Depth (throttled)**
   - Throttle frequency (e.g., 200 ms / 5 Hz).
   - Compute center coords: `cx = depthImage.width / 2`, `cy = depthImage.height / 2`.
   - Use `offset = cy * plane.rowStride + cx * plane.pixelStride` to read two bytes (little-endian) and convert to millimeters → meters.
   - Post updates to Flutter on the Android main thread via `MethodChannel` / `EventChannel`.

5. **Depth Intrinsics Scaling**
   - If you have color camera intrinsics `(fxColor, fyColor, cxColor, cyColor)` at `(colorWidth, colorHeight)`, compute:
     ```
     val scaleX = depthWidth.toFloat() / colorWidth.toFloat()
     val scaleY = depthHeight.toFloat() / colorHeight.toFloat()
     val fxDepth = fxColor * scaleX
     val fyDepth = fyColor * scaleY
     val cxDepth = cxColor * scaleX
     val cyDepth = cyColor * scaleY
     ```
   - Return or save these intrinsics with the depth file for downstream back-projection.

6. **Threading & Safety**
   - ARCore frame updates are on the GL thread: do expensive I/O (writing depth.bin) off the render-critical path or in a worker thread.
   - Ensure `MethodChannel` callbacks/events are sent on the Android main thread.

7. **Error Handling**
   - Guard all depth operations with `depthSupported`.
   - Handle `NotYetAvailableException` gracefully.
   - Ensure `depthImage.close()` always runs to avoid memory leaks.

---

## File format & Naming

- `depth.bin`: binary, row-major, little-endian `uint16` values, no padding (size `width * height * 2`).
- Store in app-private storage. Return absolute path to Flutter.
- Save `DepthInfo` JSON alongside or in the capture response:

```json
{
  "width": 320,
  "height": 240,
  "dtype": "uint16",
  "unit": "millimeters",
  "isCompressed": false
}
```

---

## Flutter-side Implementation Notes

- Create UI overlay showing the center depth (meters).
- Subscribe to `centerDepthStream` (or poll via `MethodChannel`) and update UI (≤5 Hz).
- Provide a **Capture** button calling `captureDepth()` which saves `depth.bin` and returns `DepthInfo` + file path.
- Handle runtime Camera permissions (either in Flutter or delegate to native).

---

## Acceptance Tests

- Live center depth visible and updating at human-friendly rate (≤5 Hz).
- Pressing Capture produces `depth.bin` whose size equals `width * height * 2` bytes.
- Capture returns a `DepthInfo` JSON and valid file path.
- On unsupported devices, feature is disabled and app remains stable.
- No memory leaks or crashes after repeated captures.

---

## Unit Test Recommendations

- Test buffer-copy logic by simulating a `rowStride > width * pixelStride` case and verifying the produced `out` buffer matches expected values.
- Test `captureDepth()` behavior when depth is unavailable (should return graceful error).

---

## Example JSON response for capture

```json
{
  "success": true,
  "depthFilePath": "/data/user/0/<package>/files/depth_0001.bin",
  "depthInfo": { "width": 320, "height": 240, "dtype": "uint16", "unit": "millimeters", "isCompressed": false }
}
```

---

## PR / QA checklist
- [ ] Add Kotlin engine and wire to AR session startup
- [ ] Add MethodChannel handlers & Flutter-side API
- [ ] Add permission and ARCore dependency changes
- [ ] Implement center depth sampling and tests
- [ ] Implement depth.bin writer (stride-aware) and tests
- [ ] Add UI overlay + Capture button in Flutter demo
- [ ] Add logging and QA notes
- [ ] Update README with usage and expected file format

---

## Notes & Edge Cases
- Some devices may output `0` for unknown/invalid depth pixels — document this.
- Depth resolution often differs from color resolution; always use scaled intrinsics to align color + depth.
- Full-depth capture is heavier; throttle and perform writes off the GL thread.

---

If you want, generate a ready-to-paste Kotlin class template and Flutter MethodChannel handlers next. Otherwise use this AGENTS.md as the machine-friendly handoff file for your repo.

