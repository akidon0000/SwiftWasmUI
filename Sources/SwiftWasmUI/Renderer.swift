#if os(WASI)
import JavaScriptKit

// MARK: - マウントツリー(状態の永続化単位)

/// ビューツリー上の位置ごとに状態を保持するノード。
/// 描画のたびにビュー構造体は作り直されるが、このノードは生き残る。
final class MountNode {
    var typeName = ""
    var slots: [_StateStore] = []
    var children: [Int: MountNode] = [:]

    /// 同じ位置に別の型が来たら状態を破棄する
    func reuse(ifType newType: String) {
        guard typeName != newType else { return }
        typeName = newType
        slots = []
        children = [:]
    }

    func child(_ index: Int) -> MountNode {
        if let existing = children[index] { return existing }
        let node = MountNode()
        children[index] = node
        return node
    }
}

// MARK: - プリミティブが DOM を描画するためのフック

struct RenderContext {
    let renderer: Renderer
    let parent: JSObject
    let node: MountNode

    /// 子ビューを指定の DOM 要素へ描画する
    func walkChild(_ view: any View, into element: JSObject, index: Int) {
        renderer.walk(view, parent: element, node: node.child(index))
    }
}

protocol _DOMPrimitive {
    func render(_ ctx: RenderContext)
}

// MARK: - Renderer(状態変化で全再描画する最小実装)

public final class Renderer {
    public static var shared: Renderer?

    let container: JSObject
    let rootView: any View
    let rootNode = MountNode()
    private var isRendering = false
    private var needsRender = false

    init(rootView: any View, container: JSObject) {
        self.rootView = rootView
        self.container = container
    }

    func invalidate() {
        if isRendering {
            needsRender = true
        } else {
            render()
        }
    }

    func render() {
        isRendering = true
        repeat {
            needsRender = false
            container.innerHTML = .string("")
            walk(rootView, parent: container, node: rootNode)
        } while needsRender
        isRendering = false
    }

    func walk(_ view: any View, parent: JSObject, node: MountNode) {
        node.reuse(ifType: String(reflecting: type(of: view)))

        switch view {
        case is EmptyView:
            return
        case let tuple as TupleView:
            for (i, child) in tuple.children.enumerated() {
                walk(child, parent: parent, node: node.child(i))
            }
        case let either as _EitherView:
            walk(either.content, parent: parent, node: node.child(either.isFirst ? 0 : 1))
        case let forEach as _ForEachProtocol:
            for (i, child) in forEach._resolvedChildren.enumerated() {
                walk(child, parent: parent, node: node.child(i))
            }
        case let primitive as _DOMPrimitive:
            primitive.render(RenderContext(renderer: self, parent: parent, node: node))
        default:
            adoptState(of: view, into: node)
            renderBody(of: view, parent: parent, node: node)
        }
    }

    /// 新しいビュー構造体の @State を、ノードが保持する状態の正本(_StateStore)に
    /// つなぎ替える(宣言順キー)。値のコピーではなく参照の共有なので、
    /// 再描画をまたいで古いハンドラが書き込んでも失われない。
    private func adoptState(of view: any View, into node: MountNode) {
        var index = 0
        for child in Mirror(reflecting: view).children {
            guard let property = child.value as? _StateProperty else { continue }
            let box = property._box
            if index < node.slots.count {
                box.store = node.slots[index]
            } else {
                node.slots.append(box.store)
            }
            box.store.renderer = self
            index += 1
        }
        if index < node.slots.count {
            node.slots.removeSubrange(index...)
        }
    }

    private func renderBody(of view: some View, parent: JSObject, node: MountNode) {
        walk(view.body, parent: parent, node: node.child(0))
    }
}

// MARK: - DOM ヘルパー

enum DOM {
    static var document: JSValue { JSObject.global.document }

    static func element(
        _ tag: String,
        css: String = "",
        className: String = "",
        in parent: JSObject
    ) -> JSObject {
        var el = document.createElement(tag)
        if !css.isEmpty {
            el.style.object!.cssText = .string(css)
        }
        if !className.isEmpty {
            el.className = .string(className)
        }
        _ = parent.appendChild!(el)
        return el.object!
    }

    /// ビューの子リストを平坦化する(List が行単位でラップするために使う)
    static func flatten(_ view: any View) -> [any View] {
        switch view {
        case is EmptyView:
            return []
        case let tuple as TupleView:
            return tuple.children.flatMap(flatten)
        case let either as _EitherView:
            return flatten(either.content)
        case let forEach as _ForEachProtocol:
            return forEach._resolvedChildren.flatMap(flatten)
        default:
            return [view]
        }
    }
}

// MARK: - App エントリポイント

public protocol App {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
    init()
}

public extension App {
    static func main() {
        let document = JSObject.global.document

        // フレームワーク共通スタイル(.frame(maxHeight: .infinity) の子を伸ばす)
        var style = document.createElement("style")
        style.textContent = .string("""
        ._wasmui-fill > * { flex: 1 1 auto; min-height: 0; align-self: stretch; }
        ._wasmui-zlayer { pointer-events: none; }
        ._wasmui-zlayer > * { pointer-events: auto; }
        """)
        _ = document.head.appendChild(style)

        var container = document.getElementById("app")
        if container.isNull {
            container = document.body
        }
        let app = Self()
        let renderer = Renderer(rootView: app.body, container: container.object!)
        Renderer.shared = renderer
        renderer.render()
    }
}

#endif
