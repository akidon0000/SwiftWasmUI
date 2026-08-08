#if os(WASI)
import WasmUI

@main
struct DemoApp: App {
    var body: some View {
        RootView()
    }
}

struct RootView: View {
    @State var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            NavigationBarView(title: tab == 0 ? "Counter" : "Todo")
            VStack(spacing: 0) {
                if tab == 0 {
                    CounterView()
                } else {
                    TodoView()
                }
            }
            .frame(maxHeight: .infinity)
            TabBarView(selection: $tab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - iOS 風クローム(WasmUI 製)

struct NavigationBarView: View {
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .padding(14)
            Hairline()
        }
        .background(Color(white: 0.97))
    }
}

struct Hairline: View {
    var body: some View {
        Color(white: 0.82).frame(height: 1, maxWidth: .infinity)
    }
}

struct TabBarView: View {
    let selection: Binding<Int>

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack {
                Spacer()
                tabButton("🔢", "Counter", index: 0)
                Spacer()
                tabButton("📋", "Todo", index: 1)
                Spacer()
            }
            .padding(8)
        }
        .background(Color(white: 0.97))
    }

    func tabButton(_ icon: String, _ title: String, index: Int) -> some View {
        let selection = selection
        return VStack(spacing: 2) {
            Text(icon)
            Button(title) { selection.wrappedValue = index }
                .font(.caption)
        }
        .foregroundColor(selection.wrappedValue == index ? .blue : .gray)
    }
}

// MARK: - Counter

struct CounterView: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("WasmUI (自作フレームワーク)")
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
enum WasmUIDemoStub {
    static func main() {
        print("WasmUIDemo is a Wasm-only executable. Build with --swift-sdk <wasm SDK>.")
    }
}
#endif
