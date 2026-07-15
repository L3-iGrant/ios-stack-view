//
//  ContentView.swift
//  StackViewSample
//
//  Home screen: pick UIKit cards or SwiftUI cards. Each opens its own screen
//  with a fresh WalletView, so the two card types never share one stack.
//

import SwiftUI

struct ContentView: View {
    /// One store for both screens, so a movie added on either shows up on both.
    @StateObject private var store = MovieStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                NavigationLink {
                    StackScreen(useSwiftUICards: false, title: "UIKit Cards")
                } label: {
                    MenuButton(
                        title: "UIKit Cards",
                        subtitle: "CardView subclass",
                        systemImage: "square.stack.3d.up"
                    )
                }

                NavigationLink {
                    StackScreen(useSwiftUICards: true, title: "SwiftUI Cards")
                } label: {
                    MenuButton(
                        title: "SwiftUI Cards",
                        subtitle: "SwiftUICardView",
                        systemImage: "swift"
                    )
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(white: 0.95).ignoresSafeArea())
            .navigationTitle("Movie Cards")
        }
        .environmentObject(store)
    }
}

private struct MenuButton: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    ContentView()
}
