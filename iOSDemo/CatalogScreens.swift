// API 比較カタログ(iOS 版)。起動引数 -screen <id> で表示する。
// Sources/SwiftWasmUIDemo/CatalogScreens.swift と同じコードを維持すること(比較写真の前提)。
import SwiftUI

enum Catalog {
    static var currentScreenID: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screen"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }
}

struct CatalogRoot: View {
    let id: String

    var body: some View {
        switch id {
        case "text": TextScreen()
        case "button": ButtonScreen()
        case "controls": ControlsScreen()
        case "image": ImageScreen()
        case "stacks": StacksScreen()
        case "list": ListScreen()
        case "scrollview": ScrollScreen()
        case "shapes": ShapesScreen()
        case "progress": ProgressScreen()
        case "glass": GlassScreen()
        default: ModifiersScreen()
        }
    }
}

// ここから下の各画面 body は Web 版と一字一句同じにする

struct TextScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Large Title").font(.largeTitle)
            Text("Title").font(.title)
            Text("Headline").font(.headline)
            Text("Body").font(.body)
            Text("Caption").font(.caption)
            Text("Colored").foregroundColor(.red)
            Text("The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.")
                .lineLimit(2)
            Text("Center aligned multiline text that wraps across lines")
                .multilineTextAlignment(.center)
                .frame(width: 220)
        }
        .padding()
    }
}

struct ButtonScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("Default Button") {}
            Button("Destructive") {}
                .foregroundColor(.red)
            Button("Disabled") {}
                .disabled(true)
        }
        .padding()
    }
}

struct ControlsScreen: View {
    @State var text = ""
    @State var on = true
    @State var off = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter text", text: $text)
            Toggle("Notifications", isOn: $on)
            Toggle("Dark Mode", isOn: $off)
        }
        .padding()
    }
}

struct ImageScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 20) {
                Image(systemName: "heart.fill").foregroundColor(.red)
                Image(systemName: "star.fill").foregroundColor(.blue)
                Image(systemName: "person.circle")
                Image(systemName: "trash")
            }
            .font(.title)
            HStack(spacing: 20) {
                Image(systemName: "chevron.right")
                Image(systemName: "plus")
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Image(systemName: "xmark")
            }
            .font(.largeTitle)
        }
        .padding()
    }
}

struct StacksScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8).fill(.blue)
                    .frame(width: 60, height: 40)
                RoundedRectangle(cornerRadius: 8).fill(.green)
                    .frame(width: 60, height: 40)
                RoundedRectangle(cornerRadius: 8).fill(.red)
                    .frame(width: 60, height: 40)
            }
            HStack {
                Text("Leading")
                Spacer()
                Text("Trailing")
            }
            .frame(width: 260)
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(.blue)
                    .frame(width: 160, height: 90)
                Text("ZStack").foregroundColor(.white).font(.headline)
            }
            .frame(height: 90)
        }
        .padding()
    }
}

struct ListScreen: View {
    var body: some View {
        List {
            ForEach(["Apple", "Banana", "Cherry", "Durian", "Elderberry"], id: \.self) { fruit in
                Text(fruit)
            }
        }
    }
}

struct ScrollScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<25, id: \.self) { i in
                    Text("Row \(i)").padding(12)
                    Divider()
                }
            }
        }
    }
}

struct ShapesScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 20) {
                Rectangle().fill(.blue)
                    .frame(width: 64, height: 64)
                RoundedRectangle(cornerRadius: 16).fill(.green)
                    .frame(width: 64, height: 64)
                Circle().fill(.red)
                    .frame(width: 64, height: 64)
            }
            Capsule().fill(.gray)
                .frame(width: 120, height: 44)
            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 12).fill(.blue)
                    .frame(width: 64, height: 64)
                    .opacity(0.35)
                RoundedRectangle(cornerRadius: 12).fill(.blue)
                    .frame(width: 64, height: 64)
                    .shadow(radius: 8, y: 4)
                RoundedRectangle(cornerRadius: 12).fill(.white)
                    .frame(width: 64, height: 64)
                    .border(.red, width: 2)
            }
        }
        .padding()
    }
}

struct ProgressScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading...").foregroundColor(.gray)
        }
        .padding()
    }
}

struct ModifiersScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("padding + background + cornerRadius")
                .foregroundColor(.white)
                .padding()
                .background(.blue)
                .cornerRadius(12)
            Text("border")
                .padding(12)
                .border(.red, width: 2)
            Text("shadow")
                .padding(12)
                .background(.white)
                .cornerRadius(8)
                .shadow(radius: 6, y: 2)
            Text("opacity 0.4")
                .opacity(0.4)
        }
        .padding()
    }
}

struct GlassScreen: View {
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
            VStack(spacing: 16) {
                Text("Liquid Glass")
                    .font(.headline)
                    .padding(20)
                    .glassEffect()
                HStack(spacing: 12) {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("Glass card")
                }
                .padding(20)
                .glassEffect()
            }
        }
    }
}
