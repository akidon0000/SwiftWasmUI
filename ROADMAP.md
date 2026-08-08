# ROADMAP

**読み手と目的**: SwiftWasmUI のコントリビュータと利用者向けに、「SwiftUI 互換 API を
どこまで実装すれば何ができるか」を段階で示す。網羅的な SwiftUI 再実装は目標にしない —
各フェーズの完了条件は「そのフェーズのアプリ例が書けること」。

## 完了の定義

SwiftUI の公開 API は膨大(ビュー・モディファイア合わせて数百)で、全対応は現実的な
ゴールではない。本プロジェクトの **v1.0 = Phase 3 完了** と定義する:
「典型的な CRUD + ナビゲーション付きのモバイル風 Web アプリが、SwiftUI のコードを
ほぼコピペで動かせる」状態。

## Phase 0 — 済み ✅

| 分類 | API |
|---|---|
| コア | `View` / `@ViewBuilder`(`if`/`else`) / `App` |
| 状態 | `@State` / `Binding` |
| ビュー | `Text` `Button` `TextField` `Toggle` `List` `ForEach` `Color` `Image(systemName:)` `Spacer` |
| レイアウト | `VStack` `HStack` `ZStack` |
| モディファイア | `.padding` `.font` `.foregroundColor` `.background` `.frame` `.cornerRadius` `.glassEffect` |

## Phase 1 — 基本の穴埋め(単画面アプリが不自由なく書ける)

- [ ] `ScrollView`
- [ ] `Divider`
- [ ] `Label` / `Link`
- [ ] `Slider` / `Stepper` / `Picker`
- [ ] `SecureField` / `TextEditor`
- [ ] `LinearGradient` / `RoundedRectangle` / `Circle`(基本 Shape)
- [ ] `.opacity` / `.shadow` / `.border` / `.clipped`
- [ ] `.disabled` / `.onTapGesture` / `.onAppear`
- [ ] `@Environment(\.colorScheme)` とダークモード対応(`.glassEffect` 含む)

## Phase 2 — 状態管理(SwiftUI らしいデータフロー)

- [ ] `@Observable` / `ObservableObject` + `@StateObject` / `@ObservedObject` 相当
- [ ] `@Environment` / `@EnvironmentObject`
- [ ] `.onChange(of:)` / `.task`
- [ ] 差分レンダリング(全再構築をやめ、`TextField` のフォーカス喪失などを解消)

## Phase 3 — ナビゲーション(v1.0)

- [ ] `NavigationStack` / `NavigationLink`(ブラウザ履歴と同期)
- [ ] `TabView`(Liquid Glass タブバーを標準スタイル化)
- [ ] `.sheet` / `.alert` / `.confirmationDialog`
- [ ] `.navigationTitle` / `.toolbar`

## Phase 4 — 品質・拡張(v1.0 以降)

- [ ] アニメーション(`withAnimation` / `.transition` → CSS transition へマッピング)
- [ ] `LazyVGrid` / `LazyHGrid`
- [ ] `AsyncImage`
- [ ] アクセシビリティ(ARIA 属性)
- [ ] SSR / ハイドレーション検討

## 参考文献

- SwiftUI API リファレンス: https://developer.apple.com/documentation/swiftui
- 先行実装 Tokamak(対応 API の目安): https://github.com/TokamakUI/Tokamak
