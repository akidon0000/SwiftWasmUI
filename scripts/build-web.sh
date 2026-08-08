#!/usr/bin/env bash
# WasmUIDemo を WebAssembly 向けにビルドして Web/ に配置する
set -euo pipefail
cd "$(dirname "$0")/.."

SDK="${SWIFT_WASM_SDK:-swift-6.2.4-RELEASE_wasm}"

# - WASI エミュレーション define: Foundation/CoreFoundation が要求
# - reactor ABI: JavaScriptKit が要求
# - __main_argc_argv: reactor では main がエクスポートされないため明示
swift build --swift-sdk "$SDK" --product WasmUIDemo \
  -Xcc -D_WASI_EMULATED_SIGNAL \
  -Xcc -D_WASI_EMULATED_PROCESS_CLOCKS \
  -Xcc -D_WASI_EMULATED_MMAN \
  -Xswiftc -Xclang-linker -Xswiftc -mexec-model=reactor \
  -Xlinker --export-if-defined=main \
  -Xlinker --export-if-defined=__main_argc_argv

cp .build/wasm32-unknown-wasip1/debug/WasmUIDemo.wasm Web/WasmUIDemo.wasm
echo "OK: Web/WasmUIDemo.wasm"
echo "動作確認: python3 -m http.server 8000 --directory Web"
