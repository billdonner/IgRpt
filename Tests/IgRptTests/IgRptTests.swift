import XCTest
@testable import IgRpt

class IgRptTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(IgRpt().text, "Hello, World from IgRpt")
    }


    static var allTests : [(String, (IgRptTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
