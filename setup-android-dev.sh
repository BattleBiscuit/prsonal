#!/usr/bin/env bash
# Android + Flutter local dev setup (WSL and native Linux)
set -euo pipefail

# ── Colours ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERR ]${NC}  $*" >&2; exit 1; }

# ── Environment detection ──────────────────────────────────────────────────────
IS_WSL=false
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

# ── 1. System dependencies ─────────────────────────────────────────────────────
install_deps() {
  info "Installing system dependencies…"

  # Enable universe repo (needed for openjdk-17 on some Ubuntu releases).
  sudo add-apt-repository -y universe 2>/dev/null || true

  # Ignore errors from broken third-party PPAs (e.g. expired Ansible PPA key).
  sudo apt-get update -qq 2>&1 || true

  # Prefer JDK 17; fall back to 21 if not available (Ubuntu 24.04+).
  local JAVA_PKG="openjdk-17-jdk"
  if ! apt-cache show "$JAVA_PKG" &>/dev/null; then
    warn "openjdk-17-jdk not found — using openjdk-21-jdk instead."
    JAVA_PKG="openjdk-21-jdk"
  fi

  sudo apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa libxcb-cursor0 "$JAVA_PKG"
  ok "System dependencies ready."
}

# ── 2. Flutter SDK ─────────────────────────────────────────────────────────────
install_flutter() {
  if [[ -d "$HOME/flutter" ]]; then
    info "Flutter already present at ~/flutter — skipping clone."
  else
    info "Cloning Flutter SDK (stable branch)…"
    git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
    ok "Flutter cloned."
  fi

  if ! grep -q 'flutter/bin' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.bashrc"
    info "Added Flutter to PATH in ~/.bashrc"
  fi

  export PATH="$HOME/flutter/bin:$PATH"
}

# ── 3. Android SDK (cmdline-tools only) ───────────────────────────────────────
fetch_cmdline_tools_url() {
  # Parse the latest Linux zip name from Google's repository manifest.
  local REPO_XML="https://dl.google.com/android/repository/repository2-3.xml"
  local BASE="https://dl.google.com/android/repository"
  local ZIP

  ZIP=$(curl -fsSL --connect-timeout 15 "$REPO_XML" \
        | grep -oE 'commandlinetools-linux-[0-9]+_latest\.zip' \
        | sort -t- -k3 -n \
        | tail -1)

  [[ -n "$ZIP" ]] && echo "$BASE/$ZIP"
}

install_android_sdk() {
  local SDK_DIR="$HOME/android-sdk"
  local CMDLINE_DIR="$SDK_DIR/cmdline-tools"
  local LATEST_DIR="$CMDLINE_DIR/latest"

  if [[ -d "$LATEST_DIR" ]]; then
    info "Android cmdline-tools already installed — skipping."
  else
    local TOOLS_URL="${CMDLINE_TOOLS_URL:-}"

    if [[ -z "$TOOLS_URL" ]]; then
      info "Looking up latest cmdline-tools download URL…"
      TOOLS_URL=$(fetch_cmdline_tools_url) \
        || die "Could not resolve cmdline-tools URL.\n  Download manually from https://developer.android.com/studio#command-tools\n  then re-run:  CMDLINE_TOOLS_URL=/path/to/zip $0"
    fi

    local ZIP_FILE="/tmp/cmdline-tools.zip"
    info "Downloading $TOOLS_URL …"
    curl -fSL --progress-bar -o "$ZIP_FILE" "$TOOLS_URL"

    info "Extracting…"
    mkdir -p "$CMDLINE_DIR"
    unzip -q "$ZIP_FILE" -d "$CMDLINE_DIR"
    # The zip always unpacks a 'cmdline-tools' folder; rename to 'latest'.
    mv "$CMDLINE_DIR/cmdline-tools" "$LATEST_DIR"
    rm "$ZIP_FILE"
    ok "Android cmdline-tools installed."
  fi

  if ! grep -q 'ANDROID_HOME' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << 'EOF'

# Android SDK
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
EOF
    info "Added ANDROID_HOME and SDK paths to ~/.bashrc"
  fi

  export ANDROID_HOME="$HOME/android-sdk"
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
}

# ── 4. SDK packages + licences ─────────────────────────────────────────────────
install_sdk_packages() {
  info "Accepting SDK licences…"
  yes | sdkmanager --licenses > /dev/null 2>&1 || true

  info "Installing SDK packages (platform-tools, android-35, build-tools 35.0.0)…"
  sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
  ok "SDK packages installed."

  info "Accepting Flutter Android licences…"
  yes | flutter doctor --android-licenses > /dev/null 2>&1 || true
  ok "Flutter Android licences accepted."
}

# ── 5. Emulator (optional) ─────────────────────────────────────────────────────
AVD_NAME="flutter_dev"
SYSTEM_IMAGE="system-images;android-35;google_apis;x86_64"

install_emulator() {
  info "Installing Android emulator and system image…"
  info "(system image is ~1 GB — this may take a few minutes)"
  sdkmanager "emulator" "$SYSTEM_IMAGE"
  yes | sdkmanager --licenses > /dev/null 2>&1 || true
  ok "Emulator package installed."

  if avdmanager list avd | grep -q "Name: $AVD_NAME"; then
    info "AVD '$AVD_NAME' already exists — skipping creation."
  else
    info "Creating AVD '$AVD_NAME' (Pixel 6 profile)…"
    echo "no" | avdmanager create avd \
      --name "$AVD_NAME" \
      --package "$SYSTEM_IMAGE" \
      --device "pixel_6" \
      --force
    ok "AVD created."
  fi

  # Add emulator binary to PATH if needed.
  if ! grep -q 'emulator' "$HOME/.bashrc"; then
    echo 'export PATH="$ANDROID_HOME/emulator:$PATH"' >> "$HOME/.bashrc"
    info "Added emulator to PATH in ~/.bashrc"
  fi
  export PATH="$ANDROID_HOME/emulator:$PATH"

  # Grant KVM access — required for x86_64 hardware acceleration.
  if ! groups | grep -qw kvm; then
    info "Adding $USER to the kvm group…"
    sudo gpasswd -a "$USER" kvm
    warn "KVM group change requires a session restart."
    warn "Run 'newgrp kvm' now, or log out and back in to WSL."
  fi

  echo ""
  ok "Emulator ready. To start it:"
  echo ""
  echo "    emulator -avd $AVD_NAME"
  echo ""
  if $IS_WSL; then
    echo "  WSLg provides the display automatically — run that command in your"
    echo "  WSL terminal and the emulator window should open on Windows."
    echo ""
    echo "  If the window doesn't appear, try:"
    echo "    emulator -avd $AVD_NAME -gpu swiftshader_indirect"
  fi
}

# ── 6. flutter doctor ──────────────────────────────────────────────────────────
run_flutter_doctor() {
  info "Running flutter doctor…"
  flutter doctor || true   # non-zero exit is expected until a device is connected
}

# ── Summary ────────────────────────────────────────────────────────────────────
print_summary() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  ok "Setup complete!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  1. Reload your shell:"
  echo "       source ~/.bashrc"
  echo ""
  echo "  2. Install VS Code extensions:"
  echo "       Dart-Code.flutter"
  echo "       Dart-Code.dart-code"
  echo ""
  echo "  3. Connect your Android device (Android 11+ required):"
  echo "       Settings → Developer Options → Wireless Debugging"
  echo "       → Pair device with pairing code"
  echo ""
  echo "       adb pair <ip>:<pair-port>       # pairing screen values"
  echo "       adb connect <ip>:<debug-port>   # main wireless debug port"
  echo "       flutter devices                 # confirm device is listed"
  echo ""
  if $IS_WSL; then
    echo "  WSL note: wireless debugging is recommended (USB requires usbipd-win)."
    echo "  If you ever need USB — from Windows PowerShell (Admin):"
    echo "       usbipd list"
    echo "       usbipd attach --wsl --busid <id>"
    echo ""
  fi
  warn "'Android Studio not installed' in flutter doctor output is expected — VS Code is the IDE."
}

usage() {
  echo "Usage: $0 [--emulator]"
  echo ""
  echo "  (no flags)   Install Flutter + Android SDK only"
  echo "  --emulator   Also install the Android emulator and create an AVD"
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  local WITH_EMULATOR=false
  for arg in "$@"; do
    case "$arg" in
      --emulator) WITH_EMULATOR=true ;;
      --help|-h)  usage; exit 0 ;;
      *) die "Unknown argument: $arg\n$(usage)" ;;
    esac
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Android + Flutter Dev Setup"
  echo "  Environment: $( $IS_WSL && echo WSL || echo "Native Linux" )"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  install_deps
  install_flutter
  install_android_sdk
  install_sdk_packages
  $WITH_EMULATOR && install_emulator
  run_flutter_doctor
  print_summary
}

main "$@"
