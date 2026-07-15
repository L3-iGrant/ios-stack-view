//
//  SampleCards.swift
//  StackViewSample
//
//  Demonstrates the "support both" card forms:
//   • MovieUIKitCard         — a UIKit CardView subclass (like the app's CardTileView)
//   • SelectableSwiftUICard  — a SwiftUICardView hosting a SwiftUI view
//
//  Both override `tapped()` so that tapping the presented card reports a
//  selection, while tapping a non-presented card presents it (the base engine
//  behaviour otherwise dismisses).
//
//  Only the top ~45pt of a stacked card is visible, so the title and genre sit
//  at the top of the card and the release date hangs below them.
//

import SwiftUI
import StackView

// MARK: - SwiftUI card content

struct MovieCardContent: View {
    let movie: Movie

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(rgb: movie.genre.hex))
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(movie.genre.displayName.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.22))
                    .clipShape(Capsule())

                Text(movie.releaseText)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(16)
        }
        .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)
    }
}

// MARK: - SwiftUI card (hosted in the engine's CardView)

final class SelectableSwiftUICard: SwiftUICardView<MovieCardContent> {
    var onSelect: (() -> Void)?

    init(movie: Movie) {
        super.init(rootView: MovieCardContent(movie: movie))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tapped() {
        handleTap(card: self, onSelect: onSelect)
    }
}

// MARK: - UIKit card

final class MovieUIKitCard: CardView {
    var onSelect: (() -> Void)?

    init(movie: Movie) {
        super.init(frame: .zero)

        let container = UIView()
        container.backgroundColor = UIColor(rgb: movie.genre.hex)
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        let title = UILabel()
        title.text = movie.title
        title.font = .preferredFont(forTextStyle: .headline)
        title.textColor = .white

        let genre = GenrePillLabel()
        genre.text = movie.genre.displayName.uppercased()

        // Keep the pill hugging its text instead of stretching across the card.
        let genreRow = UIStackView(arrangedSubviews: [genre, UIView()])
        genreRow.axis = .horizontal

        let release = UILabel()
        release.text = movie.releaseText
        release.font = .preferredFont(forTextStyle: .subheadline)
        release.textColor = UIColor.white.withAlphaComponent(0.85)

        let stack = UIStackView(arrangedSubviews: [title, genreRow, release])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tapped() {
        handleTap(card: self, onSelect: onSelect)
    }
}

/// UIKit counterpart of the SwiftUI genre capsule.
private final class GenrePillLabel: UILabel {
    private let inset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .preferredFont(forTextStyle: .caption2)
        textColor = .white
        backgroundColor = UIColor.white.withAlphaComponent(0.22)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + inset.left + inset.right,
            height: size.height + inset.top + inset.bottom
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
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
