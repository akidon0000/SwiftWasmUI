# Contributing to SwiftWasmUI

Thanks for your interest! SwiftWasmUI is a small, readable SwiftUI-like framework for
WebAssembly. PRs that make it better for everyone are very welcome. This guide is
intentionally short — keep it in mind, but don't sweat the small stuff.

## Ground rules

- **Be kind.** This project follows the spirit of the
  [Contributor Covenant](https://www.contributor-covenant.org/). Be respectful in
  issues, PRs, and reviews.
- **One topic per PR.** Smaller, focused PRs get merged faster than sprawling ones.
- **Discuss before big changes.** For anything that changes the public API or the
  rendering model, open an issue first so we can align before you spend time coding.
- **Match SwiftUI's API shape.** New views and modifiers should mirror SwiftUI's
  signatures as closely as the platform allows — see [ROADMAP.md](ROADMAP.md) for
  what's wanted next.

## Dev setup

You need a Swift toolchain with a SwiftWasm SDK installed
(see [swiftwasm.org](https://swiftwasm.org) — the SDK id is configurable via
`SWIFT_WASM_SDK`, default `swift-6.2.4-RELEASE_wasm`).

```bash
git clone https://github.com/akidon0000/SwiftWasmUI.git
cd SwiftWasmUI

bash scripts/build-web.sh                     # build the Wasm demo into Web/
python3 -m http.server 8000 --directory Web   # open http://localhost:8000
```

The demo app in `Sources/SwiftWasmUIDemo/DemoApp.swift` doubles as the manual test
surface — if you add a view or modifier, use it there so reviewers can see it running.

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).
