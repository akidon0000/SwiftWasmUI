// SwiftWasmUI デモ用ブートストラップ(JavaScriptKit 0.19.2 ランタイム + WASI shim)
import { SwiftRuntime } from "https://cdn.jsdelivr.net/npm/javascript-kit-swift@0.19.2/Runtime/lib/index.mjs";
import {
  WASI,
  File,
  OpenFile,
  ConsoleStdout,
} from "https://cdn.jsdelivr.net/npm/@bjorn3/browser_wasi_shim@0.3.0/+esm";

// カタログモード(#text 等): iPhone 風フレームを外して素の 390x844 で表示する
// (スクリーンショット比較用に位置を確定させる)。OS がダークモードでも
// 比較写真はライト基準にしたいので、ダーク時のガラス配色を打ち消す。
if (location.hash) {
  document.body.style.cssText = "margin: 0; border: none; border-radius: 0; box-shadow: none;";
  const style = document.createElement("style");
  style.textContent = `@media (prefers-color-scheme: dark) {
    ._wasmui-glass {
      background: rgba(255, 255, 255, 0.55) !important;
      border-color: rgba(255, 255, 255, 0.7) !important;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12),
                  inset 0 1px 0 rgba(255, 255, 255, 0.9) !important;
    }
  }`;
  document.head.appendChild(style);
}

const swift = new SwiftRuntime();
const wasi = new WASI([], [], [
  new OpenFile(new File([])), // stdin
  ConsoleStdout.lineBuffered((line) => console.log(line)),
  ConsoleStdout.lineBuffered((line) => console.error(line)),
]);

// 開発用: ブラウザキャッシュで古い wasm を掴まないようにする
const response = await fetch(`./SwiftWasmUIDemo.wasm?t=${Date.now()}`);
const bytes = await response.arrayBuffer();
const { instance } = await WebAssembly.instantiate(bytes, {
  wasi_snapshot_preview1: wasi.wasiImport,
  javascript_kit: swift.wasmImports,
});

// reactor ABI: _initialize 後に main を明示的に呼ぶ
wasi.initialize(instance);
swift.setInstance(instance);
if (instance.exports.main) {
  instance.exports.main(0, 0);
} else if (instance.exports.__main_argc_argv) {
  instance.exports.__main_argc_argv(0, 0);
}
