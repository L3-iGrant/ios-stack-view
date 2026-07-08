//
//  DetailView.swift
//  StackViewSample
//
//  Shown when the user taps the already-presented (selected) card.
//

import SwiftUI

struct DetailView: View {
    let item: SampleItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(rgb: item.hex))
                    .frame(height: 200)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text(item.subtitle)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(20)
                    }

                Text("Card details")
                    .font(.headline)

                VStack(spacing: 0) {
                    detailRow("Name", item.title)
                    Divider()
                    detailRow("Issuer", item.subtitle)
                    Divider()
                    detailRow("Status", "Active")
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(16)
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
