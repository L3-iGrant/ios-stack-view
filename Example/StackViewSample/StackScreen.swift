//
//  StackScreen.swift
//  StackViewSample
//
//  A single card-stack screen, dedicated to one card type. Because each
//  instance owns its own WalletStackView (and thus its own WalletView), the
//  UIKit and SwiftUI variants never interfere with each other.
//

import SwiftUI

struct StackScreen: View {

    let useSwiftUICards: Bool
    let title: String

    @State private var detailItem: SampleItem?

    var body: some View {
        VStack(spacing: 0) {
            Text("Tap a card to select it · tap it again for detail · tap the list to go back")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            WalletStackView(
                items: SampleData.items,
                useSwiftUICards: useSwiftUICards,
                cardHeight: 170
            ) { item in
                detailItem = item
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: Binding(
            get: { detailItem != nil },
            set: { if !$0 { detailItem = nil } }
        )) {
            if let detailItem {
                DetailView(item: detailItem)
            }
        }
    }
}
