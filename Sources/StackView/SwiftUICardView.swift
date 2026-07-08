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

open class SwiftUICardView<Content: View>: CardView {

    private let hostingController: UIHostingController<Content>

    public init(rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
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
        hostingController.rootView = rootView
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
