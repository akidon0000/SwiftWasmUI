#if os(WASI)
import JavaScriptKit

// MARK: - Text

public struct Text: _PrimitiveView, _DOMPrimitive {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element("span", in: ctx.parent)
        el.textContent = .string(content)
    }
}

// MARK: - Image

/// SF Symbols 互換の API で Framework7 Icons(MIT)のグリフを描画する。
/// SF Symbols 名のドットをアンダースコアに変換する(例: "chevron.right" → "chevron_right")。
/// SF Symbols 本体は Apple プラットフォーム外で使えないため、フォントは同梱しない。
public struct Image: _PrimitiveView, _DOMPrimitive {
    let systemName: String

    public init(systemName: String) {
        self.systemName = systemName
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "i",
            css: "font-size: inherit; line-height: 1; vertical-align: middle;",
            className: "f7-icons",
            in: ctx.parent
        )
        el.textContent = .string(String(systemName.map { $0 == "." ? "_" : $0 }))
    }
}

// MARK: - Button

public struct Button: _PrimitiveView, _DOMPrimitive {
    let title: String
    let action: () -> ()

    public init(_ title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "button",
            css: "color: var(--wasmui-accent, rgb(0,122,255)); background: none; border: none; "
                + "padding: 0; font: inherit; cursor: pointer;",
            in: ctx.parent
        )
        el.textContent = .string(title)
        let action = action
        el.onclick = .object(JSClosure { _ in
            action()
            return .undefined
        })
    }
}

// MARK: - Stack / Spacer

public enum HorizontalAlignment {
    case leading, center, trailing

    var css: String {
        switch self {
        case .leading: "flex-start"
        case .center: "center"
        case .trailing: "flex-end"
        }
    }
}

public enum VerticalAlignment {
    case top, center, bottom

    var css: String {
        switch self {
        case .top: "flex-start"
        case .center: "center"
        case .bottom: "flex-end"
        }
    }
}

/// Tokamak と違い flexbox 実装なので Spacer がそのまま効く
public struct VStack: _PrimitiveView, _DOMPrimitive {
    let alignment: HorizontalAlignment
    let spacing: Double
    let content: any View

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Double = 8,
        @ViewBuilder content: () -> some View
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "div",
            css: "display: flex; flex-direction: column; align-items: \(alignment.css); gap: \(spacing)px;",
            in: ctx.parent
        )
        ctx.walkChild(content, into: el, index: 0)
    }
}

public struct HStack: _PrimitiveView, _DOMPrimitive {
    let alignment: VerticalAlignment
    let spacing: Double
    let content: any View

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Double = 8,
        @ViewBuilder content: () -> some View
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "div",
            css: "display: flex; flex-direction: row; align-items: \(alignment.css); gap: \(spacing)px;",
            in: ctx.parent
        )
        ctx.walkChild(content, into: el, index: 0)
    }
}

/// 子を同じ領域に重ねる。各子は絶対配置レイヤーに包まれ、alignment で寄せる。
/// レイヤー自体はクリックを透過し、子要素だけが受ける(._wasmui-zlayer)。
public struct ZStack: _PrimitiveView, _DOMPrimitive {
    public enum Alignment {
        case top, center, bottom

        var css: String {
            switch self {
            case .top: "flex-start"
            case .center: "center"
            case .bottom: "flex-end"
            }
        }
    }

    let alignment: Alignment
    let content: any View

    public init(alignment: Alignment = .center, @ViewBuilder content: () -> some View) {
        self.alignment = alignment
        self.content = content()
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "div",
            css: "position: relative; flex: 1 1 auto; align-self: stretch; min-height: 0;",
            in: ctx.parent
        )
        for (i, child) in DOM.flatten(content).enumerated() {
            let layer = DOM.element(
                "div",
                css: """
                position: absolute; inset: 0;
                display: flex; flex-direction: column;
                align-items: center; justify-content: \(alignment.css);
                """,
                className: "_wasmui-zlayer",
                in: el
            )
            ctx.walkChild(child, into: layer, index: i)
        }
    }
}

public struct Spacer: _PrimitiveView, _DOMPrimitive {
    public init() {}

    func render(_ ctx: RenderContext) {
        _ = DOM.element("div", css: "flex-grow: 1; align-self: stretch;", in: ctx.parent)
    }
}

// MARK: - List

/// iOS の UITableView 風の既定スタイルを持つリスト
public struct List: _PrimitiveView, _DOMPrimitive {
    let content: any View

    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "div",
            css: "overflow-y: auto; flex: 1 1 0; min-height: 0; width: 100%; align-self: stretch;",
            in: ctx.parent
        )
        for (i, row) in DOM.flatten(content).enumerated() {
            let rowEl = DOM.element(
                "div",
                css: "padding: 12px 16px; border-bottom: 1px solid #e5e5ea; width: 100%; "
                    + "box-sizing: border-box; display: flex; align-items: center;",
                in: el
            )
            ctx.walkChild(row, into: rowEl, index: i)
        }
    }
}

// MARK: - TextField

public struct TextField: _PrimitiveView, _DOMPrimitive {
    let placeholder: String
    let text: Binding<String>
    let onCommit: () -> ()

    public init(_ placeholder: String, text: Binding<String>, onCommit: @escaping () -> () = {}) {
        self.placeholder = placeholder
        self.text = text
        self.onCommit = onCommit
    }

    func render(_ ctx: RenderContext) {
        let el = DOM.element(
            "input",
            css: "font: inherit; padding: 8px 12px; border: 1px solid #d1d1d6; border-radius: 8px; "
                + "flex: 1 1 0; min-width: 0; color-scheme: light; background: #fff; color: #000;",
            in: ctx.parent
        )
        el.placeholder = .string(placeholder)
        el.value = .string(text.wrappedValue)

        // 逐次入力では再描画しない(input 要素が作り直されてフォーカスが飛ぶため)。
        // Enter で確定したときだけ通常の set → 再描画を通す。
        let text = text
        let onCommit = onCommit
        el.oninput = .object(JSClosure { _ in
            text.silentSetter(el.value.string ?? "")
            return .undefined
        })
        el.onkeydown = .object(JSClosure { args in
            if args.first?.key.string == "Enter" {
                text.wrappedValue = el.value.string ?? ""
                onCommit()
            }
            return .undefined
        })
    }
}

// MARK: - Toggle

public struct Toggle: _PrimitiveView, _DOMPrimitive {
    let title: String
    let isOn: Binding<Bool>

    public init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self.isOn = isOn
    }

    func render(_ ctx: RenderContext) {
        let label = DOM.element(
            "label",
            css: "display: flex; align-items: center; gap: 8px; width: 100%; cursor: pointer;",
            in: ctx.parent
        )
        let checkbox = DOM.element("input", css: "color-scheme: light;", in: label)
        checkbox.type = .string("checkbox")
        checkbox.checked = .boolean(isOn.wrappedValue)
        let span = DOM.element("span", in: label)
        span.textContent = .string(title)

        let isOn = isOn
        checkbox.onchange = .object(JSClosure { _ in
            isOn.wrappedValue = checkbox.checked.boolean ?? false
            return .undefined
        })
    }
}

#endif
