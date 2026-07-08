# ios-stack-view

A wallet-style **stacked card view** for iOS — the card-stack engine used by iGrant Data Wallet, packaged as a reusable Swift library.

At rest the cards form a fanned, scrollable stack. Tapping a card **presents** it (it floats to the top while the other cards collapse into a peek stack below); tapping the presented card reports a selection, and it can be dragged down to dismiss back to the fan.

## Features

- **Fanned, scrollable rest layout** — all cards visible, native (smooth, inertial) `UIScrollView` scrolling
- **Tap to present** — the tapped card floats to the top while the rest collapse into a bottom peek stack
- **Tap-to-dismiss / drag-to-dismiss** — send the selected card back to its place
- **Presented-card callback** — get notified when the presented card changes
- **Bring-your-own card** — the SDK owns layout, scrolling, gestures and animation; you supply the card as a **UIKit** view (subclass `CardView`) or a **SwiftUI** view (`SwiftUICardView`)
- **Configurable** — card height, fan spacing, collapsed peek height, collapsed count, animation speeds, and more

## Requirements

- iOS 16+
- Swift 5.9+

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies…**, enter the URL below, and set the dependency rule to **Up to Next Major Version** so it tracks the latest release:

```
https://github.com/L3-iGrant/ios-stack-view
```

Or in `Package.swift`, using the latest release tag:

```swift
dependencies: [
    .package(url: "https://github.com/L3-iGrant/ios-stack-view", from: "<latest-release>")
]
```

## Concepts

| Type | Role |
|---|---|
| `WalletView` | The engine — a `UIScrollView` subclass that does the scroll / fan / present / dismiss layout and animations. |
| `CardView` | The base card (`UIView`) the engine operates on. It carries the tap / pan / long-press gestures. **Subclass it** to build a UIKit card. It defines *no* visuals. |
| `SwiftUICardView<Content>` | A `CardView` that hosts a SwiftUI view via `UIHostingController`, so your card can be pure SwiftUI. |

The SDK deliberately **does not** ship a SwiftUI `UIViewRepresentable`. The host app writes a small wrapper around `WalletView` (see the sample) and configures it directly — the same pattern the Data Wallet app uses.

## Usage

### 1. Configure the engine

```swift
import StackView

let wallet = WalletView()
wallet.walletHeader = nil
wallet.useHeaderDistanceForStackedCards = true
wallet.preferableCardViewHeight = 170
wallet.minimalDistanceBetweenStackedCardViews = 45   // fan spacing at rest
wallet.contentInset = .zero
```

### 2. Supply cards — UIKit *or* SwiftUI

**UIKit card** — subclass `CardView`:

```swift
final class MyCard: CardView {
    init(item: Item) {
        super.init(frame: .zero)
        // add your labels / image views
    }
    required init?(coder: NSCoder) { fatalError() }
}

wallet.reload(cardViews: items.map { MyCard(item: $0) })
```

**SwiftUI card** — wrap any SwiftUI view in `SwiftUICardView`:

```swift
wallet.reload(cardViews: items.map { SwiftUICardView(rootView: MyCardView(item: $0)) })
```

### 3. Decide what a tap does (your policy)

The engine gives you `present(cardView:animated:)` and `dismissPresentedCardView(animated:)`. Override `tapped()` on your card to route them — e.g. present on first tap, open a detail screen on the second, go back when another card is tapped:

```swift
override func tapped() {
    if presented {
        onSelect?()                                  // open detail
    } else if walletView?.presentedCardView != nil {
        walletView?.dismissPresentedCardView(animated: true)  // tap the list → go back
    } else {
        walletView?.present(cardView: self, animated: true)   // → float to top
    }
}
```

### 4. Embed in SwiftUI

Write a thin `UIViewRepresentable` in your app that owns a `WalletView` and reloads it when your data changes. A complete, ~40-line example is in [`Example/StackViewSample/WalletStackView.swift`](Example/StackViewSample/WalletStackView.swift).

## Configuration reference

Layout (per `WalletView` instance):

| Property | Default | Controls |
|---|---|---|
| `preferableCardViewHeight` | `150` | Card height |
| `minimalDistanceBetweenStackedCardViews` | `45` | Peek between cards in the fanned rest stack |
| `useHeaderDistanceForStackedCards` | `false` | Use the above spacing for the fan |
| `minimalDistanceBetweenCollapsedCardViews` | `40` | Peek per card in the collapsed bottom stack |
| `maximimNumberOfCollapsedCardViewsToShow` | `0` | How many cards show in the collapsed bottom stack |
| `distanceBetweetCollapsedAndPresentedCardViews` | `0` | Gap between the presented card and the collapsed stack |
| `grabPopupOffset` | `20` | Lift offset on long-press grab |
| `contentInset` | — | Scroll insets (the setter also adds internal bottom padding) |
| `walletHeader` | `nil` | Optional header pinned above the cards |

Animation speeds are `static` (apply to **all** `WalletView`s): `presentingAnimationSpeed` (0.35), `dismissingAnimationSpeed` (0.35), `insertionAnimationSpeed` (0.6), `removalAnimationSpeed` (1.0), `grabbingAnimationSpeed` (0.2).

State / control: `insertedCardViews`, `presentedCardView`, `reload(cardViews:)`, `present(cardView:…)`, `dismissPresentedCardView(…)`, `insert(…)`, `remove(…)`, and the `didPresentCardViewBlock` callback.

## Sample app

A runnable sample lives in [`Example/`](Example/): a home screen with **UIKit Cards** and **SwiftUI Cards** screens (each with its own `WalletView`), the fanned scrollable stack, tap-to-present / tap-to-dismiss, and a detail page.

```sh
cd Example
open StackViewSample.xcodeproj    # ⌘R on any iOS Simulator
# or regenerate the project first: xcodegen generate
```

## Architecture

| Layer | Owns |
|---|---|
| **SDK** | `WalletView` (engine) · `CardView` (contract + gestures) · `SwiftUICardView` (UIKit↔SwiftUI bridge) |
| **Your app** | The card's **look** (UIKit subclass or SwiftUI view) and the **tap policy** (`tapped()` override) |
