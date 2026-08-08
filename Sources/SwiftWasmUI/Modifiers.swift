#if os(WASI)
import JavaScriptKit

// MARK: - Color / Font

/// SwiftUI と同じく Color 自体も View(利用可能な領域いっぱいに広がる)
public struct Color: _PrimitiveView, _DOMPrimitive {
    let css: String

    public init(css: String) {
        self.css = css
    }

    public init(white: Double) {
        let v = Int(white * 255)
        css = "rgb(\(v), \(v), \(v))"
    }

    public static let blue = Color(css: "rgb(0, 122, 255)")
    public static let gray = Color(css: "rgb(142, 142, 147)")
    public static let red = Color(css: "rgb(255, 59, 48)")
    public static let green = Color(css: "rgb(52, 199, 89)")
    public static let black = Color(css: "#000")
    public static let white = Color(css: "#fff")

    func render(_ ctx: RenderContext) {
        // background ショートハンドなので linear-gradient(...) 等もそのまま使える
        _ = DOM.element(
            "div",
            css: "background: \(css); width: 100%; height: 100%; flex: 1 1 auto; align-self: stretch;",
            in: ctx.parent
        )
    }
}

public enum Font {
    case largeTitle, title, headline, body, caption

    var css: String {
        switch self {
        case .largeTitle: "font-size: 34px; font-weight: 700;"
        case .title: "font-size: 28px; font-weight: 400;"
        case .headline: "font-size: 17px; font-weight: 600;"
        case .body: "font-size: 17px; font-weight: 400;"
        case .caption: "font-size: 12px; font-weight: 400;"
        }
    }
}

// MARK: - スタイルラッパー

/// モディファイアは div でラップして CSS を当てる最小実装
public struct _StyledView: _PrimitiveView, _DOMPrimitive {
    let content: any View
    let css: String
    var className = ""

    func render(_ ctx: RenderContext) {
        let el = DOM.element("div", css: css, className: className, in: ctx.parent)
        ctx.walkChild(content, into: el, index: 0)
    }
}

public extension View {
    func padding(_ value: Double = 16) -> some View {
        _StyledView(content: self, css: "padding: \(value)px;")
    }

    func padding(
        top: Double = 0, leading: Double = 0, bottom: Double = 0, trailing: Double = 0
    ) -> some View {
        _StyledView(content: self, css: "padding: \(top)px \(trailing)px \(bottom)px \(leading)px;")
    }

    func font(_ font: Font) -> some View {
        _StyledView(content: self, css: font.css)
    }

    func foregroundColor(_ color: Color) -> some View {
        // --wasmui-accent は Button のデフォルト色にも波及させるためのカスタムプロパティ
        _StyledView(content: self, css: "color: \(color.css); --wasmui-accent: \(color.css);")
    }

    func background(_ color: Color) -> some View {
        _StyledView(
            content: self,
            css: "background: \(color.css); width: 100%; box-sizing: border-box;"
        )
    }

    /// iOS 26 の Liquid Glass 風マテリアル。
    /// backdrop-filter のぼかし + 半透明背景 + 上端ハイライトで近似する。
    func glassEffect(cornerRadius: Double = 28) -> some View {
        _StyledView(
            content: self,
            css: """
            background: rgba(255, 255, 255, 0.55);
            -webkit-backdrop-filter: blur(24px) saturate(1.8);
            backdrop-filter: blur(24px) saturate(1.8);
            border-radius: \(cornerRadius)px;
            border: 0.5px solid rgba(255, 255, 255, 0.7);
            box-shadow:
                0 8px 24px rgba(0, 0, 0, 0.12),
                inset 0 1px 0 rgba(255, 255, 255, 0.9);
            overflow: hidden;
            """
        )
    }

    func cornerRadius(_ radius: Double) -> some View {
        _StyledView(content: self, css: "border-radius: \(radius)px; overflow: hidden;")
    }

    func frame(
        width: Double? = nil,
        height: Double? = nil,
        maxWidth: Double? = nil,
        maxHeight: Double? = nil
    ) -> some View {
        var css = "display: flex; flex-direction: column; align-items: stretch;"
        var fills = false
        if let width { css += " width: \(width)px;" }
        if let height { css += " height: \(height)px;" }
        if let maxWidth {
            css += maxWidth == .infinity ? " width: 100%; align-self: stretch;" : " max-width: \(maxWidth)px;"
        }
        if let maxHeight {
            if maxHeight == .infinity {
                // flex 親の残りスペースを全部使う(SwiftUI の greedy な挙動の近似)
                css += " flex: 1 1 0px; align-self: stretch; min-height: 0;"
                fills = true
            } else {
                css += " max-height: \(maxHeight)px;"
            }
        }
        return _StyledView(content: self, css: css, className: fills ? "_wasmui-fill" : "")
    }
}

#endif
