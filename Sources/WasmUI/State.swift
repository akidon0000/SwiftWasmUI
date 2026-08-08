#if os(WASI)

// MARK: - 状態の実体(クラスなのでビュー構造体のコピー間で共有される)

/// 状態の正本。マウントノードが保持し、描画をまたいで生き残る。
/// ボックスと分離しているのは、再描画後も「古い描画のハンドラ」が
/// 同じ正本に書き込めるようにするため(ボックス自体はビューごとに作り直される)。
final class _StateStore {
    var value: Any
    weak var renderer: Renderer?

    init(_ value: Any) {
        self.value = value
    }
}

public final class _StateBox {
    var store: _StateStore

    init(_ value: Any) {
        store = _StateStore(value)
    }

    var rawValue: Any {
        get { store.value }
        set { store.value = newValue }
    }

    func set(_ value: Any) {
        store.value = value
        store.renderer?.invalidate()
    }

    /// 再描画を起こさずに値だけ更新する(TextField の逐次入力用)
    func setSilently(_ value: Any) {
        store.value = value
    }
}

/// Mirror で @State プロパティを見つけるためのフック
protocol _StateProperty {
    var _box: _StateBox { get }
}

// MARK: - @State

/// 仕組み: ビュー構造体は描画のたびに作り直されるが、描画前に Renderer が
/// Mirror で @State を列挙し、前回描画の値をボックスへ引き継ぐ(宣言順キー)。
@propertyWrapper
public struct State<Value>: _StateProperty {
    let box: _StateBox

    public init(wrappedValue: Value) {
        box = _StateBox(wrappedValue)
    }

    public var wrappedValue: Value {
        get { box.rawValue as! Value }
        nonmutating set { box.set(newValue) }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { box.rawValue as! Value },
            set: { box.set($0) },
            setSilently: { box.setSilently($0) }
        )
    }

    var _box: _StateBox { box }
}

// MARK: - Binding

@propertyWrapper
public struct Binding<Value> {
    let getter: () -> Value
    let setter: (Value) -> ()
    let silentSetter: (Value) -> ()

    public init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
        getter = get
        setter = set
        silentSetter = set
    }

    init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> (),
        setSilently: @escaping (Value) -> ()
    ) {
        getter = get
        setter = set
        silentSetter = setSilently
    }

    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    public var projectedValue: Binding<Value> { self }
}

#endif
