//
//  SwiftUICardView.swift
//  StackView
//
//  A `CardView` that hosts a SwiftUI view, so the wallet stack can be driven
//  with SwiftUI cards as well as UIKit ones. The engine (`WalletView`) works
//  with `CardView` instances; this subclass is just a `CardView` whose content
//  is a `UIHostingController`.
//
//  UIKit path:   subclass `CardView` directly (e.g. the app's `CardTileView`).
//  SwiftUI path: `SwiftUICardView(rootView: MySwiftUICard(...))`.
//

import SwiftUI
import UIKit

/// Wraps the card's content so the hosting controller lays it out against the
/// card's full bounds. A card that reaches into the home-indicator area would
/// otherwise inherit the window's bottom safe-area inset, and content sized or
/// aligned against that reduced area drifts out of step with the cards above it.
private struct FullBleed<Content: View>: View {
    let content: Content
    var body: some View { content.ignoresSafeArea() }
}

open class SwiftUICardView<Content: View>: CardView {

    private let hostingController: UIHostingController<FullBleed<Content>>

    public init(rootView: Content) {
        hostingController = UIHostingController(rootView: FullBleed(content: rootView))
        // The hosting controller is added as a child view controller (see
        // didMoveToWindow), so it insets its root layout by the safe area it
        // inherits from its parent. A card overlapping the home indicator then
        // lays its content out in a shorter box and the content drifts up by
        // half the inset, out of step with the cards above it. ignoresSafeArea()
        // on the content only governs how it extends, not this inset.
        if #available(iOS 16.4, *) {
            hostingController.safeAreaRegions = []
        }
        super.init(frame: .zero)
        backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Swap the SwiftUI content without rebuilding the card.
    public func update(rootView: Content) {
        hostingController.rootView = FullBleed(content: rootView)
    }

    /// Attach the hosting controller to the nearest view controller once in the
    /// window, so SwiftUI gets a proper containment lifecycle.
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, hostingController.parent == nil,
              let parent = nearestViewController else { return }
        parent.addChild(hostingController)
        hostingController.didMove(toParent: parent)
    }

    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = next
        while let current = responder {
            if let viewController = current as? UIViewController { return viewController }
            responder = current.next
        }
        return nil
    }
}
