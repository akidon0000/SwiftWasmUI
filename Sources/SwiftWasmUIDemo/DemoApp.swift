#if os(WASI)
import SwiftWasmUI

@main
struct DemoApp: App {
    var body: some View {
        // #text 等のハッシュ付きで開くと API 比較カタログの単一画面を表示する
        if let id = Catalog.currentScreenID {
            CatalogRoot(id: id)
        } else {
            RootView()
        }
    }
}

struct RootView: View {
    @State var tab = 0

    var body: some View {
        ZStack(alignment: .center) {
            // ガラスの下に透けるカラフルな背景
            Color(css: "linear-gradient(160deg, #dbe7ff 0%, #f4e3ff 45%, #ffe9f0 100%)")
            VStack(spacing: 0) {
                if tab == 0 {
                    CounterView()
                } else {
                    if tab == 1 {
                        TodoView()
                    } else {
                        GalleryView()
                    }
                }
            }
            .padding(top: 72, bottom: 110)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            NavigationBarView(title: ["Counter", "Todo", "Gallery"][tab])
            TabBarView(selection: $tab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - iOS 26 風 Liquid Glass クローム(SwiftWasmUI 製)

struct NavigationBarView: View {
    let title: String

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                    .padding(10)
            }
            .glassEffect(cornerRadius: 22)
            .padding(14)
        }
    }
}

struct TabBarView: View {
    let selection: Binding<Int>

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                tabButton("number", "Counter", index: 0)
                tabButton("list.bullet", "Todo", index: 1)
                tabButton("square.grid.2x2", "Gallery", index: 2)
            }
            .glassEffect(cornerRadius: 32)
            .padding(18)
        }
    }

    func tabButton(_ icon: String, _ title: String, index: Int) -> some View {
        let selection = selection
        return VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title)
            Button(title) { selection.wrappedValue = index }
                .font(.caption)
        }
        .foregroundColor(selection.wrappedValue == index ? .blue : .gray)
        .padding(10)
        .frame(width: 96)
    }
}

// MARK: - Counter

struct CounterView: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftWasmUI (自作フレームワーク)")
                .font(.title)
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
        .padding()
    }
}

// MARK: - Todo

struct TodoItem {
    var isCompleted = false
    var text: String
}

struct TodoView: View {
    @State var newItem = ""
    @State var items = [TodoItem]()

    func addNewItem() {
        guard !newItem.isEmpty else { return }
        items.append(TodoItem(text: newItem))
        newItem = ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                TextField("New todo item", text: $newItem, onCommit: addNewItem)
                Button("+", action: addNewItem)
                    .font(.title)
                    .padding(4)
            }
            .padding(12)
            List {
                ForEach(items.indices, id: \.self) { i in
                    Toggle(
                        items[i].text,
                        isOn: Binding(
                            get: { items[i].isCompleted },
                            set: { items[i].isCompleted = $0 }
                        )
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Gallery(新規 API のショーケース)

struct GalleryView: View {
    @State var loading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shapes").font(.headline)
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12).fill(.blue)
                        .frame(width: 56, height: 56)
                    Circle().fill(.green)
                        .frame(width: 56, height: 56)
                    Capsule().fill(.red)
                        .frame(width: 80, height: 36)
                    Rectangle().fill(.gray)
                        .frame(width: 56, height: 56)
                        .opacity(0.4)
                }
                Divider()
                Text("Progress").font(.headline)
                HStack(spacing: 12) {
                    ProgressView()
                    Button(loading ? "Stop" : "Start") { loading = !loading }
                        .disabled(false)
                }
                Divider()
                Text("Long text with lineLimit(2)").font(.headline)
                Text("SwiftWasmUI renders SwiftUI-shaped code to the browser DOM. "
                    + "This paragraph is intentionally long so that the lineLimit "
                    + "modifier has something to clamp — you should see exactly two "
                    + "lines followed by an ellipsis.")
                    .lineLimit(2)
                Divider()
                Text("Tap gesture").font(.headline)
                RoundedRectangle(cornerRadius: 12).fill(loading ? .green : .gray)
                    .frame(width: 120, height: 44)
                    .onTapGesture { loading = !loading }
                    .shadow(radius: 6, y: 2)
                // ScrollView 確認用の水増しコンテンツ
                Divider()
                Text("Scroll me").font(.headline)
                ForEach(0..<12, id: \.self) { i in
                    Text("Row \(i)")
                        .padding(8)
                }
            }
            .padding()
        }
    }
}

#else
@main
enum SwiftWasmUIDemoStub {
    static func main() {
        print("SwiftWasmUIDemo is a Wasm-only executable. Build with --swift-sdk <wasm SDK>.")
    }
}
#endif
