#if os(WASI)
import SwiftWasmUI

@main
struct DemoApp: App {
    var body: some View {
        RootView()
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
                    TodoView()
                }
            }
            .padding(top: 72, bottom: 110)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            NavigationBarView(title: tab == 0 ? "Counter" : "Todo")
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

#else
@main
enum SwiftWasmUIDemoStub {
    static func main() {
        print("SwiftWasmUIDemo is a Wasm-only executable. Build with --swift-sdk <wasm SDK>.")
    }
}
#endif
