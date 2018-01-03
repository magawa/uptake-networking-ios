import UIKit
import XCTest
import UptakeNetworking



class HTTPHeaderTests: XCTestCase {
  func testDescription() {
    XCTAssertEqual(HTTPHeaderField.accept.description , "Accept")
    XCTAssertEqual(HTTPHeaderField.acceptCharset.description , "Accept-Charset")
    XCTAssertEqual(HTTPHeaderField.acceptEncoding.description , "Accept-Encoding")
    XCTAssertEqual(HTTPHeaderField.acceptLanguage.description , "Accept-Language")
    XCTAssertEqual(HTTPHeaderField.acceptVersion.description , "Accept-Version")
    XCTAssertEqual(HTTPHeaderField.authorization.description , "Authorization")
    XCTAssertEqual(HTTPHeaderField.cacheControl.description , "Cache-Control")
    XCTAssertEqual(HTTPHeaderField.connection.description , "Connection")
    XCTAssertEqual(HTTPHeaderField.cookie.description , "Cookie")
    XCTAssertEqual(HTTPHeaderField.contentLength.description , "Content-Length")
    XCTAssertEqual(HTTPHeaderField.contentMD5.description , "Content-MD5")
    XCTAssertEqual(HTTPHeaderField.contentType.description , "Content-Type")
    XCTAssertEqual(HTTPHeaderField.date.description , "Date")
    XCTAssertEqual(HTTPHeaderField.host.description , "Host")
    XCTAssertEqual(HTTPHeaderField.origin.description , "Origin")
    XCTAssertEqual(HTTPHeaderField.referer.description , "Referer")
    XCTAssertEqual(HTTPHeaderField.userAgent.description , "User-Agent")
  }
  
  
  func testCustom() {
    XCTAssertEqual(HTTPHeaderField.custom("foo").description, "foo")
  }
  
  
  func testEquality() {
    XCTAssert(HTTPHeaderField.accept == HTTPHeaderField.accept)
    XCTAssertFalse(HTTPHeaderField.accept == HTTPHeaderField.acceptCharset)
    XCTAssert(HTTPHeaderField.accept == HTTPHeaderField.custom("Accept"))
  }
}
