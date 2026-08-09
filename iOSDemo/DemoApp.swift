// SwiftWasmUI の Web デモと同じ UI を本家 SwiftUI で再現した iOS 版デモ。
// iOS 26 の Liquid Glass (.glassEffect) を使用する。
import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            // -screen <id> 付きで起動すると API 比較カタログの単一画面を表示する
            if let id = Catalog.currentScreenID {
                CatalogRoot(id: id)
            } else {
                RootView()
            }
        }
    }
}

struct RootView: View {
    @State var tab = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.86, green: 0.91, blue: 1.0),
                    Color(red: 0.96, green: 0.89, blue: 1.0),
                    Color(red: 1.0, green: 0.91, blue: 0.94),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                if tab == 0 {
                    CounterView()
                } else {
                    TodoView()
                }
            }
            .padding(.top, 72)
            .padding(.bottom, 110)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                NavigationBarView(title: tab == 0 ? "Counter" : "Todo")
                Spacer()
                TabBarView(selection: $tab)
            }
        }
    }
}

struct NavigationBarView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .padding(10)
            .padding(.horizontal, 8)
            .glassEffect()
    }
}

struct TabBarView: View {
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            tabButton("number", "Counter", index: 0)
            tabButton("list.bullet", "Todo", index: 1)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 32))
        .padding(18)
    }

    func tabButton(_ icon: String, _ title: String, index: Int) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title2)
            Button(title) { selection = index }
                .font(.caption)
        }
        .foregroundColor(selection == index ? .blue : .gray)
        .padding(10)
        .frame(width: 96)
    }
}

struct CounterView: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftWasmUI (自作フレームワーク)")
                .font(.title)
                .multilineTextAlignment(.center)
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
        .padding()
        Spacer()
    }
}

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
                TextField("New todo item", text: $newItem)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addNewItem)
                Button("+", action: addNewItem)
                    .font(.title)
                    .padding(4)
            }
            .padding(12)
            List($items, id: \.text) { $item in
                Toggle(item.text, isOn: $item.isCompleted)
            }
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
