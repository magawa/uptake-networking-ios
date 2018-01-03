import UIKit
import XCTest
import UptakeNetworking



class HTTPMethodTests: XCTestCase {
  func testDescription() {
    XCTAssertEqual(HTTPMethod.head.description, "HEAD")
    XCTAssertEqual(HTTPMethod.get.description, "GET")
    XCTAssertEqual(HTTPMethod.post.description, "POST")
    XCTAssertEqual(HTTPMethod.put.description, "PUT")
    XCTAssertEqual(HTTPMethod.delete.description, "DELETE")
    XCTAssertEqual(HTTPMethod.trace.description, "TRACE")
    XCTAssertEqual(HTTPMethod.connect.description, "CONNECT")
    XCTAssertEqual(HTTPMethod.options.description, "OPTIONS")
    XCTAssertEqual(HTTPMethod.patch.description, "PATCH")
  }
}
