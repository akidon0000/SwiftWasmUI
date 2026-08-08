// SwiftWasmUI デモ用ブートストラップ(JavaScriptKit 0.19.2 ランタイム + WASI shim)
import { SwiftRuntime } from "https://cdn.jsdelivr.net/npm/javascript-kit-swift@0.19.2/Runtime/lib/index.mjs";
import {
  WASI,
  File,
  OpenFile,
  ConsoleStdout,
} from "https://cdn.jsdelivr.net/npm/@bjorn3/browser_wasi_shim@0.3.0/+esm";

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
