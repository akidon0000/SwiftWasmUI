#!/usr/bin/env bash
# docs/api-comparison.md 用の比較スクリーンショットを撮り直す。
# Web: ヘッドレス Chrome(要: bash scripts/build-web.sh 済み + ローカルサーバ起動中)
# iOS: シミュレータ(要: iOSDemo をビルド・インストール済み、UDID を環境変数で指定)
set -euo pipefail
cd "$(dirname "$0")/.."

PORT="${PORT:-8642}"
UDID="${SIM_UDID:?SIM_UDID=<booted simulator udid> を指定してください}"
BUNDLE=com.akidon0000.SwiftWasmUIDemo
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
IMG=docs/images
SCREENS=(text button controls image stacks list scrollview shapes progress modifiers glass)

mkdir -p "$IMG"

for id in "${SCREENS[@]}"; do
  # Web(390x844 @2x、カタログモードはフレームなしで描画される)
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 --window-size=390,844 \
    --virtual-time-budget=6000 --screenshot="$IMG/${id}-web.png" \
    "http://localhost:${PORT}/index.html#${id}" >/dev/null 2>&1

  # iOS(-screen 引数でカタログ画面を直接起動)
  xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$BUNDLE" -screen "$id" >/dev/null
  sleep 1.5
  xcrun simctl io "$UDID" screenshot --type png "$IMG/${id}-ios.png" >/dev/null
  sips --resampleWidth 780 "$IMG/${id}-ios.png" --out "$IMG/${id}-ios.png" >/dev/null

  echo "OK: $id"
done
xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
