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

    @EnvironmentObject private var store: MovieStore
    @State private var selectedGenre: Genre?
    @State private var detailMovie: Movie?
    @State private var addingMovie = false

    /// `nil` genre means "All".
    private var visibleMovies: [Movie] {
        guard let selectedGenre else { return store.movies }
        return store.movies.filter { $0.genre == selectedGenre }
    }

    var body: some View {
        VStack(spacing: 0) {
            GenreFilterBar(selectedGenre: $selectedGenre)

            Text("Tap a card to select it · tap it again for detail · tap the list to go back")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            if visibleMovies.isEmpty {
                emptyState
            } else {
                WalletStackView(
                    movies: visibleMovies,
                    useSwiftUICards: useSwiftUICards,
                    cardHeight: 170
                ) { movie in
                    detailMovie = movie
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addingMovie = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add movie")
            }
        }
        .sheet(isPresented: $addingMovie) {
            AddMovieView { movie in
                store.add(movie)
                // Make the new card visible even when a filter is on.
                if selectedGenre != nil, selectedGenre != movie.genre {
                    selectedGenre = movie.genre
                }
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { detailMovie != nil },
            set: { if !$0 { detailMovie = nil } }
        )) {
            if let detailMovie {
                DetailView(movie: detailMovie)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "film.stack")
                .font(.system(size: 34))
                .foregroundColor(.secondary)
            Text("No \(selectedGenre?.displayName ?? "") movies yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap + to add one.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Genre filter

private struct GenreFilterBar: View {
    @Binding var selectedGenre: Genre?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", color: .secondary, isSelected: selectedGenre == nil) {
                    selectedGenre = nil
                }

                ForEach(Genre.allCases) { genre in
                    chip(
                        title: genre.displayName,
                        color: Color(rgb: genre.hex),
                        isSelected: selectedGenre == genre
                    ) {
                        // Tapping the active chip clears the filter.
                        selectedGenre = (selectedGenre == genre) ? nil : genre
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(UIColor.systemBackground))
    }

    private func chip(
        title: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Add movie

private struct AddMovieView: View {
    let onAdd: (Movie) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var genre: Genre = .action
    @State private var releaseDate = Date.now

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Movie") {
                    TextField("Name", text: $title)

                    Picker("Genre", selection: $genre) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.displayName).tag(genre)
                        }
                    }

                    DatePicker(
                        "Date of release",
                        selection: $releaseDate,
                        displayedComponents: .date
                    )
                }

                Section {
                    MovieCardContent(
                        movie: Movie(title: trimmedTitle.isEmpty ? "Movie name" : trimmedTitle,
                                     genre: genre,
                                     releaseDate: releaseDate)
                    )
                    .frame(height: 120)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Add Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(Movie(title: trimmedTitle, genre: genre, releaseDate: releaseDate))
                        dismiss()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }
}
