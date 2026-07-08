//
//  WalletStackView.swift
//  StackViewSample
//
//  The app-side thin SwiftUI wrapper around the SDK's `WalletView` engine.
//  The SDK is engine-only, so hosting apps own a small representable like this
//  (mirroring data-wallet-ios's WalletContainer / WalletCardStackView, which
//  pins the WalletView edge-to-edge inside a container and reloads it once the
//  view has a real frame).
//

import SwiftUI
import StackView

struct WalletStackView: UIViewRepresentable {

    let items: [SampleItem]
    let useSwiftUICards: Bool
    let cardHeight: CGFloat
    let onSelect: (SampleItem) -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let wallet = WalletView()
        wallet.backgroundColor = .clear
        wallet.translatesAutoresizingMaskIntoConstraints = false
        // When the WalletView is created programmatically (starting at .zero)
        // rather than from a sized xib, the engine's scroll-view autoresizing
        // mask (flexible top/left *margins*) pushes it to the bottom-right as the
        // view grows. Pin it to fill instead.
        wallet.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(wallet)
        NSLayoutConstraint.activate([
            wallet.topAnchor.constraint(equalTo: container.topAnchor),
            wallet.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            wallet.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            wallet.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        wallet.walletHeader = nil
        wallet.useHeaderDistanceForStackedCards = true
        wallet.contentInset = .zero

        context.coordinator.wallet = wallet
        return container
    }

    func updateUIView(_ container: UIView, context: Context) {
        guard let wallet = context.coordinator.wallet else { return }
        wallet.preferableCardViewHeight = cardHeight

        let signature = "\(useSwiftUICards)|\(cardHeight)|" + items.map { $0.id.uuidString }.joined()
        guard context.coordinator.signature != signature else { return }
        context.coordinator.signature = signature

        let cards: [CardView] = items.map { item in
            if useSwiftUICards {
                let card = SelectableSwiftUICard(item: item)
                card.onSelect = { onSelect(item) }
                return card
            } else {
                let card = SampleUIKitCard(item: item)
                card.onSelect = { onSelect(item) }
                return card
            }
        }

        // Reload once the container has a real frame, so the engine lays the
        // cards out against the correct size.
        DispatchQueue.main.async {
            wallet.reload(cardViews: cards)
        }
    }

    final class Coordinator {
        var wallet: WalletView?
        var signature = ""
    }
}
