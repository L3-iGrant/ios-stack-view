//
//  SampleModel.swift
//  StackViewSample
//

import SwiftUI

enum Genre: String, CaseIterable, Identifiable, Hashable {
    case action, comedy, drama, sciFi, horror, animation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .action: return "Action"
        case .comedy: return "Comedy"
        case .drama: return "Drama"
        case .sciFi: return "Sci-Fi"
        case .horror: return "Horror"
        case .animation: return "Animation"
        }
    }

    var hex: UInt32 {
        switch self {
        case .action: return 0xCC4049
        case .comedy: return 0xD98E1F
        case .drama: return 0x2659BF
        case .sciFi: return 0x734DA6
        case .horror: return 0x262633
        case .animation: return 0x338C66
        }
    }
}

struct Movie: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let genre: Genre
    let releaseDate: Date

    var releaseText: String {
        releaseDate.formatted(date: .abbreviated, time: .omitted)
    }
}

/// Shared across both card screens, so a movie added from either one shows up
/// in the other.
final class MovieStore: ObservableObject {
    @Published private(set) var movies: [Movie] = SampleData.movies

    /// New movies go on top of the stack, where the card is visible right away.
    func add(_ movie: Movie) {
        movies.insert(movie, at: 0)
    }
}

enum SampleData {
    static let movies: [Movie] = [
        .init(title: "Dune: Part Two", genre: .sciFi, releaseDate: date(2024, 3, 1)),
        .init(title: "Oppenheimer", genre: .drama, releaseDate: date(2023, 7, 21)),
        .init(title: "Barbie", genre: .comedy, releaseDate: date(2023, 7, 21)),
        .init(title: "Mad Max: Fury Road", genre: .action, releaseDate: date(2015, 5, 15)),
        .init(title: "Hereditary", genre: .horror, releaseDate: date(2018, 6, 8)),
        .init(title: "Spirited Away", genre: .animation, releaseDate: date(2001, 7, 20))
    ]

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}

extension Color {
    init(rgb: UInt32) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
