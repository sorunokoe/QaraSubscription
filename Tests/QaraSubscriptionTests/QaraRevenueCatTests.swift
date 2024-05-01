//
//  QaraRevenueCatTests.swift
//  
//
//  Created by SALGARA, YESKENDIR on 30.04.24.
//

import XCTest
@testable import QaraSubscription

final class QaraRevenueCatTests: XCTestCase {
    
    var sut: QaraSubscription!
    
    override func setUp() async throws {
        sut = QaraSubscription.shared
    }

    override func tearDown() async throws {
        sut = nil
    }

}
