#if os(WASI)

// MARK: - View プロトコル

public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

extension Never: View {
    public var body: Never { fatalError() }
}

/// DOM に直接描画されるプリミティブ(body を持たない)
public protocol _PrimitiveView: View where Body == Never {}

public extension _PrimitiveView {
    var body: Never { fatalError("primitive view has no body") }
}

public struct EmptyView: _PrimitiveView {
    public init() {}
}

/// ViewBuilder が複数の子をまとめる入れ物
public struct TupleView: _PrimitiveView {
    let children: [any View]
    public init(children: [any View]) { self.children = children }
}

/// if / else 分岐の入れ物
public struct _EitherView: _PrimitiveView {
    let isFirst: Bool
    let content: any View
}

// MARK: - ViewBuilder

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView { EmptyView() }
    public static func buildBlock<V: View>(_ v: V) -> V { v }
    public static func buildBlock(_ vs: any View...) -> TupleView { TupleView(children: vs) }
    public static func buildOptional(_ v: (any View)?) -> TupleView {
        TupleView(children: v.map { [$0] } ?? [])
    }
    public static func buildEither(first: any View) -> _EitherView {
        _EitherView(isFirst: true, content: first)
    }
    public static func buildEither(second: any View) -> _EitherView {
        _EitherView(isFirst: false, content: second)
    }
    public static func buildExpression<V: View>(_ v: V) -> V { v }
}

// MARK: - ForEach

public struct ForEach<Data: RandomAccessCollection>: _PrimitiveView {
    let data: Data
    let content: (Data.Element) -> any View

    /// id は再描画キーとしては未使用(常に順序キー)。SwiftUI 互換のためだけに受け取る
    public init<ID: Hashable>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> some View
    ) {
        self.data = data
        self.content = { content($0) }
    }

    var resolvedChildren: [any View] { data.map(content) }
}

/// ForEach をプロトコル経由で型消去して扱うための内部フック
protocol _ForEachProtocol {
    var _resolvedChildren: [any View] { get }
}

extension ForEach: _ForEachProtocol {
    var _resolvedChildren: [any View] { resolvedChildren }
}

#endif
