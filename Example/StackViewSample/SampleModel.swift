//
//  SampleModel.swift
//  StackViewSample
//

import SwiftUI

struct SampleItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let hex: UInt32
}

enum SampleData {
    static let items: [SampleItem] = [
        .init(title: "IDENTITY CARD", subtitle: "European Union", hex: 0x2659BF),
        .init(title: "HEALTH INSURANCE", subtitle: "Ministry of Health", hex: 0xCC4049),
        .init(title: "DRIVING LICENCE", subtitle: "DVLA", hex: 0x338C66),
        .init(title: "BOARDING PASS", subtitle: "SkyAir · SA204", hex: 0x734DA6),
        .init(title: "PAYMENT CARD", subtitle: "iGrant Bank", hex: 0x262633),
        .init(title: "LOYALTY CARD", subtitle: "Coffee Co.", hex: 0x997333)
    ]
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
