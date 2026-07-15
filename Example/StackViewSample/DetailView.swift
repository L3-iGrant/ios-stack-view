//
//  DetailView.swift
//  StackViewSample
//
//  Shown when the user taps the already-presented (selected) card.
//

import SwiftUI

struct DetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(rgb: movie.genre.hex))
                    .frame(height: 200)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(movie.title)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text(movie.genre.displayName)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(20)
                    }

                Text("Movie details")
                    .font(.headline)

                VStack(spacing: 0) {
                    detailRow("Name", movie.title)
                    Divider()
                    detailRow("Genre", movie.genre.displayName)
                    Divider()
                    detailRow("Date of release", movie.releaseText)
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(16)
        }
        .navigationTitle(movie.title)
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
