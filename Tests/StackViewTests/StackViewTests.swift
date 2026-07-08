import XCTest
import SwiftUI
@testable import StackView

final class StackViewTests: XCTestCase {

    func testWalletViewDefaults() {
        let wallet = WalletView()
        XCTAssertEqual(wallet.preferableCardViewHeight, 150)
        XCTAssertEqual(wallet.minimalDistanceBetweenStackedCardViews, 45)
        XCTAssertTrue(wallet.insertedCardViews.isEmpty)
    }

    func testReloadInsertsCards() {
        let wallet = WalletView()
        let cards = [CardView(frame: .zero), CardView(frame: .zero)]
        wallet.reload(cardViews: cards)
        XCTAssertEqual(wallet.insertedCardViews.count, 2)
    }

    func testSwiftUICardViewIsACardView() {
        let card = SwiftUICardView(rootView: Text("Hello"))
        XCTAssertTrue(card is CardView)
    }
}
