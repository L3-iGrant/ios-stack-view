//
//  SampleCards.swift
//  StackViewSample
//
//  Demonstrates the "support both" card forms:
//   • SampleUIKitCard        — a UIKit CardView subclass (like the app's CardTileView)
//   • SelectableSwiftUICard  — a SwiftUICardView hosting a SwiftUI view
//
//  Both override `tapped()` so that tapping the presented card reports a
//  selection, while tapping a non-presented card presents it (the base engine
//  behaviour otherwise dismisses).
//

import SwiftUI
import StackView

// MARK: - SwiftUI card content

struct SampleCardContent: View {
    let item: SampleItem

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(rgb: item.hex))
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(18)
        }
        .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)
    }
}

// MARK: - SwiftUI card (hosted in the engine's CardView)

final class SelectableSwiftUICard: SwiftUICardView<SampleCardContent> {
    var onSelect: (() -> Void)?

    init(item: SampleItem) {
        super.init(rootView: SampleCardContent(item: item))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tapped() {
        handleTap(card: self, onSelect: onSelect)
    }
}

// MARK: - UIKit card

final class SampleUIKitCard: CardView {
    var onSelect: (() -> Void)?

    init(item: SampleItem) {
        super.init(frame: .zero)

        let container = UIView()
        container.backgroundColor = UIColor(rgb: item.hex)
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        let title = UILabel()
        title.text = item.title
        title.font = .preferredFont(forTextStyle: .headline)
        title.textColor = .white

        let subtitle = UILabel()
        subtitle.text = item.subtitle
        subtitle.font = .preferredFont(forTextStyle: .subheadline)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.85)

        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tapped() {
        handleTap(card: self, onSelect: onSelect)
    }
}

// MARK: - Shared tap behaviour

/// Selection behaviour for the sample cards:
///  • fanned rest → tap a card → present it (one selected at the top)
///  • tap the presented card → `onSelect` (open the detail page)
///  • tap any other card while one is presented → dismiss back to the fan
func handleTap(card: CardView, onSelect: (() -> Void)?) {
    if card.presented {
        onSelect?()
    } else if card.walletView?.presentedCardView != nil {
        card.walletView?.dismissPresentedCardView(animated: true)
    } else {
        card.walletView?.present(cardView: card, animated: true)
    }
}
