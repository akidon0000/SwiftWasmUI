# SwiftWasmUI

A tiny SwiftUI-like UI framework for WebAssembly, built on
[SwiftWasm](https://swiftwasm.org) and
[JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit).

Write views with the API shape you already know from SwiftUI, and render them
to the browser DOM:

```swift
import SwiftWasmUI

@main
struct CounterApp: App {
    var body: some View {
        CounterView()
    }
}

struct CounterView: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
        .padding()
    }
}
```

## Why

SwiftUI is closed source and tied to Apple platforms, so bringing its API to
the web means reimplementing the UI layer from scratch.
[Tokamak](https://github.com/TokamakUI/Tokamak) pioneered this but has been
mostly inactive since 2023. SwiftWasmUI is a minimal, understandable take on the
same idea — small enough to read in one sitting, modern enough to build with
current SwiftWasm toolchains.

## Features

- `View` protocol + `@ViewBuilder` (including `if` / `else` branches)
- `@State` / `Binding` with automatic re-rendering
- `Text`, `Button`, `TextField`, `Toggle`, `List`, `ForEach`, `Color`
- `Image(systemName:)` with SF Symbols-style names, rendered via
  [Framework7 Icons](https://framework7.io/icons/) (MIT) — SF Symbols itself
  is licensed for Apple platforms only, so the glyphs are not Apple's
- `VStack` / `HStack` / `Spacer` implemented with flexbox — `Spacer()` just works
- Modifiers: `.padding()`, `.font()`, `.foregroundColor()`, `.background()`,
  `.frame()`, `.cornerRadius()`
- iOS-flavored default styling (`List` looks like `UITableView`)

## How it works

- **Rendering**: state changes rebuild the DOM subtree from scratch — no
  diffing, no virtual DOM. Simple and predictable; fine for small apps.
- **State**: view structs are recreated on every render. Before calling
  `body`, the renderer walks the struct with `Mirror`, finds `@State`
  properties in declaration order, and reconnects them to `_StateStore`
  instances that live in a persistent mount tree. Stores are shared by
  reference, so handlers from a previous render can still write safely.
- **Events**: DOM handlers are `JSClosure`s that mutate state and trigger a
  re-render.

## Requirements

- Swift toolchain with a [SwiftWasm SDK](https://book.swiftwasm.org) installed
  (`swift sdk list` should show e.g. `swift-6.2.4-RELEASE_wasm`)

## Running the demo

```bash
./scripts/build-web.sh
python3 -m http.server 8000 --directory Web
# open http://localhost:8000
```

The demo is an iOS-look tab app (counter + todo list) defined in
`Sources/SwiftWasmUIDemo/DemoApp.swift`.

## Known limitations

This is a research project, not a production framework.

- Full re-render on every state change (no reconciliation)
- `ForEach` keys by position, not by `id`
- `TextField` updates state silently while typing and commits on Enter
  (a full re-render would recreate the input and drop focus)
- No animations, gestures, environment values, or navigation — yet

See [ROADMAP.md](ROADMAP.md) for what's coming next.

## Contributing

PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
