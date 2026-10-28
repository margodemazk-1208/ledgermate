# Setup — Development Environment

Verified working on Fedora Linux 44 (Workstation), 2026-10-28. Re-run the verification commands below after cloning on a new machine before trusting any of this is still accurate.

## Required tooling

| Tool | Version pinned | Install location (this machine) |
|---|---|---|
| Flutter SDK | 3.47.8 (stable) | `~/development/flutter` |
| JDK | Temurin 17.0.21+9 | `~/development/jdk-17.0.21+9` (NOT the system `dnf` Java — Fedora 44 only ships JDK 25, which Gradle/AGP do not yet support) |
| Android SDK | platform 36, build-tools 34.0.0 + 28.0.3, platform-tools | `~/Android/Sdk` |

## Environment variables (already appended to `~/.bashrc` and `~/.config/fish/config.fish`)

```bash
export JAVA_HOME="$HOME/development/jdk-17.0.21+9"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$JAVA_HOME/bin:$HOME/development/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```

## Verify the setup works

```bash
flutter doctor -v
```

Expect `[✓] Flutter`, `[✓] Android toolchain`. `[✗] Chrome` is expected and harmless (web target is out of scope — see `docs/PRD.md` §3.2).

## Running on a device

No emulator is set up (deliberate — see `docs/DECISIONS.md` reasoning on testing approach: real-device testing was chosen over emulator since the target deployment is sideloaded APKs to real phones).

1. On the Android phone: Settings → About Phone → tap Build Number 7x → enables Developer Options.
2. Developer Options → enable USB Debugging.
3. Connect via USB, accept the "Allow USB debugging?" prompt on the phone.
4. `flutter devices` should list the phone. `flutter run` to launch with hot reload.

## Building the release APK (for sideload distribution)

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```
