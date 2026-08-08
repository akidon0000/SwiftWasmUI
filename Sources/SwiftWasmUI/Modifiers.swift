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
        // flex column にして親からの高さ制約を子へ伝播させる(._wasmui-styled)。
        // これがないと ScrollView 等が祖先のどこかの block div で高さを失う。
        let el = DOM.element(
            "div",
            css: css,
            className: className.isEmpty ? "_wasmui-styled" : "_wasmui-styled " + className,
            in: ctx.parent
        )
        ctx.walkChild(content, into: el, index: 0)
    }
}

/// イベント系モディファイア(.onTapGesture / .onAppear)のラッパー
public struct _EventView: _PrimitiveView, _DOMPrimitive {
    let content: any View
    var onTap: (() -> ())?
    var onAppear: (() -> ())?

    func render(_ ctx: RenderContext) {
        let el = DOM.element("div", in: ctx.parent)
        if let onTap {
            var mutable = JSValue.object(el)
            mutable.onclick = .object(JSClosure { _ in
                onTap()
                return .undefined
            })
        }
        ctx.walkChild(content, into: el, index: 0)
        // render 完了 = DOM に載った時点を「appear」とみなす
        onAppear?()
    }
}

// MARK: - Shape

public protocol Shape: View {}

extension Rectangle: Shape {}
extension RoundedRectangle: Shape {}
extension Circle: Shape {}
extension Capsule: Shape {}

public extension Shape {
    /// Shape は currentColor で塗られるため、色を差し込むだけでよい
    func fill(_ color: Color) -> some View {
        _StyledView(
            content: self,
            css: "display: flex; flex: 1 1 auto; align-self: stretch; min-height: 0; "
                + "color: \(color.css);"
        )
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
    /// 色はグローバルスタイルの ._wasmui-glass が持ち、ダークモードにも追従する。
    func glassEffect(cornerRadius: Double = 28) -> some View {
        _StyledView(
            content: self,
            css: "border-radius: \(cornerRadius)px; overflow: hidden;",
            className: "_wasmui-glass"
        )
    }

    func opacity(_ value: Double) -> some View {
        _StyledView(content: self, css: "opacity: \(value);")
    }

    /// SwiftUI と同様、操作を無効化しつつ薄く表示する
    func disabled(_ disabled: Bool = true) -> some View {
        _StyledView(
            content: self,
            css: disabled ? "pointer-events: none; opacity: 0.4;" : ""
        )
    }

    func shadow(radius: Double, x: Double = 0, y: Double = 0) -> some View {
        _StyledView(
            content: self,
            css: "filter: drop-shadow(\(x)px \(y)px \(radius)px rgba(0, 0, 0, 0.33));"
        )
    }

    func border(_ color: Color, width: Double = 1) -> some View {
        _StyledView(content: self, css: "border: \(width)px solid \(color.css);")
    }

    func clipped() -> some View {
        _StyledView(content: self, css: "overflow: hidden;")
    }

    func lineLimit(_ number: Int) -> some View {
        _StyledView(
            content: self,
            css: "display: -webkit-box; -webkit-line-clamp: \(number); "
                + "-webkit-box-orient: vertical; overflow: hidden;"
        )
    }

    func multilineTextAlignment(_ alignment: HorizontalAlignment) -> some View {
        let value = switch alignment {
        case .leading: "left"
        case .center: "center"
        case .trailing: "right"
        }
        return _StyledView(content: self, css: "text-align: \(value);")
    }

    /// foregroundColor の新 API 名(色のみ対応)
    func foregroundStyle(_ color: Color) -> some View {
        foregroundColor(color)
    }

    func onTapGesture(perform action: @escaping () -> ()) -> some View {
        _EventView(content: self, onTap: action)
    }

    /// 描画された時点で一度呼ばれる(全再構築レンダリングでは再描画ごとに呼ばれる点に注意)
    func onAppear(perform action: @escaping () -> ()) -> some View {
        _EventView(content: self, onAppear: action)
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
