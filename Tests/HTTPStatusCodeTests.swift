import Foundation
import UptakeToolbox
import UptakeNetworking
import XCTest


class HTTPStatusCodeTests: XCTestCase {
  func testRawValues() {
    XCTAssertEqual(100, HTTPStatusCode.continue.rawValue)
    XCTAssertEqual(101, HTTPStatusCode.switchingProtocols.rawValue)
    XCTAssertEqual(102, HTTPStatusCode.processing.rawValue)
    
    XCTAssertEqual(200, HTTPStatusCode.ok.rawValue)
    XCTAssertEqual(201, HTTPStatusCode.created.rawValue)
    XCTAssertEqual(202, HTTPStatusCode.accepted.rawValue)
    XCTAssertEqual(203, HTTPStatusCode.nonAuthoritativeInformation.rawValue)
    XCTAssertEqual(204, HTTPStatusCode.noContent.rawValue)
    XCTAssertEqual(205, HTTPStatusCode.resetContent.rawValue)
    XCTAssertEqual(206, HTTPStatusCode.partialContent.rawValue)
    XCTAssertEqual(207, HTTPStatusCode.multiStatus.rawValue)
    XCTAssertEqual(208, HTTPStatusCode.alreadyReported.rawValue)
    XCTAssertEqual(226, HTTPStatusCode.imUsed.rawValue)
    
    XCTAssertEqual(300, HTTPStatusCode.multipleChoices.rawValue)
    XCTAssertEqual(301, HTTPStatusCode.movedPermanently.rawValue)
    XCTAssertEqual(302, HTTPStatusCode.found.rawValue)
    XCTAssertEqual(303, HTTPStatusCode.seeOther.rawValue)
    XCTAssertEqual(304, HTTPStatusCode.notModified.rawValue)
    XCTAssertEqual(305, HTTPStatusCode.useProxy.rawValue)
    XCTAssertEqual(306, HTTPStatusCode.switchProcy.rawValue)
    XCTAssertEqual(307, HTTPStatusCode.temporaryRedirect.rawValue)
    XCTAssertEqual(308, HTTPStatusCode.permanentRedirect.rawValue)
    
    XCTAssertEqual(400, HTTPStatusCode.badRequest.rawValue)
    XCTAssertEqual(401, HTTPStatusCode.unauthorized.rawValue)
    XCTAssertEqual(402, HTTPStatusCode.paymentRequired.rawValue)
    XCTAssertEqual(403, HTTPStatusCode.forbidden.rawValue)
    XCTAssertEqual(404, HTTPStatusCode.notFound.rawValue)
    XCTAssertEqual(405, HTTPStatusCode.methodNotAllowed.rawValue)
    XCTAssertEqual(406, HTTPStatusCode.notAcceptable.rawValue)
    XCTAssertEqual(407, HTTPStatusCode.proxyAuthenticationRequired.rawValue)
    XCTAssertEqual(408, HTTPStatusCode.requestTimeout.rawValue)
    XCTAssertEqual(409, HTTPStatusCode.conflict.rawValue)
    XCTAssertEqual(410, HTTPStatusCode.gone.rawValue)
    XCTAssertEqual(411, HTTPStatusCode.lengthRequired.rawValue)
    XCTAssertEqual(412, HTTPStatusCode.preconditionFailed.rawValue)
    XCTAssertEqual(413, HTTPStatusCode.payloadTooLarge.rawValue)
    XCTAssertEqual(414, HTTPStatusCode.uriTooLong.rawValue)
    XCTAssertEqual(415, HTTPStatusCode.unsupportedMediaType.rawValue)
    XCTAssertEqual(416, HTTPStatusCode.rangeNotSatisfiable.rawValue)
    XCTAssertEqual(417, HTTPStatusCode.expectationFailed.rawValue)
    XCTAssertEqual(421, HTTPStatusCode.misdirectedRequest.rawValue)
    XCTAssertEqual(422, HTTPStatusCode.unprocessableEntity.rawValue)
    XCTAssertEqual(423, HTTPStatusCode.locked.rawValue)
    XCTAssertEqual(424, HTTPStatusCode.failedDependency.rawValue)
    XCTAssertEqual(426, HTTPStatusCode.upgradeRequired.rawValue)
    XCTAssertEqual(428, HTTPStatusCode.preconditionRequired.rawValue)
    XCTAssertEqual(429, HTTPStatusCode.tooManyRequests.rawValue)
    XCTAssertEqual(431, HTTPStatusCode.requestHeaderFieldsTooLarge.rawValue)
    XCTAssertEqual(451, HTTPStatusCode.unavailableForLegalReasons.rawValue)
    
    XCTAssertEqual(500, HTTPStatusCode.internalServerError.rawValue)
    XCTAssertEqual(501, HTTPStatusCode.notImplemented.rawValue)
    XCTAssertEqual(502, HTTPStatusCode.badGateway.rawValue)
    XCTAssertEqual(503, HTTPStatusCode.serviceUnavailable.rawValue)
    XCTAssertEqual(504, HTTPStatusCode.gatewayTimeout.rawValue)
    XCTAssertEqual(505, HTTPStatusCode.httpVersionNotSupported.rawValue)
  }
  
  
  func testMatcher() {
    switch HTTPStatusCode.accepted {
    case 202:
      XCTAssert(true)
    default:
      XCTFail()
    }
    
    
    switch HTTPStatusCode.accepted {
    case 200...202:
      XCTAssert(true)
    default:
      XCTFail()
    }

    
    switch HTTPStatusCode.accepted {
    case 200..<300:
      XCTAssert(true)
    default:
      XCTFail()
    }


    switch HTTPStatusCode.accepted {
    case HTTPStatusCode.successRange:
      XCTAssert(true)
    default:
      XCTFail()
    }
  }
  
  
  func testCodeCategories() {
    with(HTTPStatusCode.continue) {
      XCTAssert($0.isInformational)
      XCTAssertFalse($0.isSuccess)
      XCTAssertFalse($0.isRedirection)
      XCTAssertFalse($0.isClientError)
      XCTAssertFalse($0.isServerError)
    }

    with(HTTPStatusCode.accepted) {
      XCTAssertFalse($0.isInformational)
      XCTAssert($0.isSuccess)
      XCTAssertFalse($0.isRedirection)
      XCTAssertFalse($0.isClientError)
      XCTAssertFalse($0.isServerError)
    }
    
    with(HTTPStatusCode.found) {
      XCTAssertFalse($0.isInformational)
      XCTAssertFalse($0.isSuccess)
      XCTAssert($0.isRedirection)
      XCTAssertFalse($0.isClientError)
      XCTAssertFalse($0.isServerError)
    }
    
    with(HTTPStatusCode.notFound) {
      XCTAssertFalse($0.isInformational)
      XCTAssertFalse($0.isSuccess)
      XCTAssertFalse($0.isRedirection)
      XCTAssert($0.isClientError)
      XCTAssertFalse($0.isServerError)
    }

    with(HTTPStatusCode.internalServerError) {
      XCTAssertFalse($0.isInformational)
      XCTAssertFalse($0.isSuccess)
      XCTAssertFalse($0.isRedirection)
      XCTAssertFalse($0.isClientError)
      XCTAssert($0.isServerError)
    }
  }
  
  
  func testDescription() {
    XCTAssertEqual(HTTPStatusCode.notFound.description, "404: not found")
  }
}
