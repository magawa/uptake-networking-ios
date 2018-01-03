import XCTest
import UptakeNetworking
import UptakeToolbox
import Medea
import Perfidy



class DeleteTests: XCTestCase {
  let simpleHost = Host(url: FakeServer.defaultURL)
  
  
  func testSimpleDELETE() {
    let response = expectation(description: "Waiting for response")
    
    FakeServer.runWith { server in
      server.add("DELETE")
      simpleHost.delete("/").data {
        if case .success = $0 {
          response.fulfill()
        }
      }
      wait(for: [response], timeout: 1)
    }
  }
  
  
  func testDELETEJSONResponse() {
    let expectedJSON = expectation(description: "waiting for JSON")
    
    FakeServer.runWith { server in
      server.add("DELETE", response: ["hello": "world"])
      simpleHost.delete("/").json {
        if case .success(200, .object(let json)) = $0 {
          XCTAssertEqual(json["hello"] as! String, "world")
          expectedJSON.fulfill()
        }
      }
      wait(for: [expectedJSON], timeout: 1)
    }
  }
  
  
  func testDELETEJSONFragmentResponse() {
    let expectedJSON = expectation(description: "waiting for JSON")
    
    FakeServer.runWith { server in
      server.add("DELETE", response: Response(status: 200, headers: ["Content-Type": "application/json"], text: "\"fragment\""))
      simpleHost.delete("/").json {
        if case .success(200, .string(let fragment)) = $0 {
          XCTAssertEqual(fragment, "fragment")
          expectedJSON.fulfill()
        }
      }
      wait(for: [expectedJSON], timeout: 1)
    }
  }
  
  
  func testDELETENonJSONResponse() {
    let successResponse = expectation(description: "waiting for success")
    let failureResponse = expectation(description: "waiting for failure")

    FakeServer.runWith { server in
      server.add("DELETE", response: "some text")
      simpleHost.delete("/").data {
        if case .success(200, "text/html"?, let d) = $0 {
          XCTAssertEqual(String(data: d, encoding: .utf8), "some text")
          successResponse.fulfill()
        }
      }
      simpleHost.delete("/").json {
        if case .failure(JSONError.malformed) = $0 {
          failureResponse.fulfill()
        }
      }
      wait(for: [successResponse, failureResponse], timeout: 1)
    }
  }
  
  
  func testDELETEInvalidJSONResponse() {
    let expectedError = expectation(description: "waiting for error")
    let subject = "not json".data(using: .utf8)!
    
    FakeServer.runWith { server in
      server.add("DELETE", response: Response(status: 200, headers: ["Content-Type": "application/json"], data: subject))
      simpleHost.delete("/").json {
        if case .failure(Medea.JSONError.malformed) = $0 {
          expectedError.fulfill()
        }
      }
      wait(for: [expectedError], timeout: 1)
    }
  }
  
  
  func testDELETEStatusCode() {
    let expectedCode = expectation(description: "waiting for status code")
    FakeServer.runWith { server in
      server.add("DELETE", response: 404)
      simpleHost.delete("/").data {
        if case .success(404, _, _) = $0 {
          expectedCode.fulfill()
        }
      }
      wait(for: [expectedCode], timeout: 1)
    }
  }
  
  
  func testDELETEWithHeaders() {
    let expectedRequestHeaders = expectation(description: "Waiting for expected request headers")
    let expectedResponse = expectation(description: "Waiting for response to prevent broken connections")
    
    FakeServer.runWith { server in
      server.add("DELETE") { req in
        XCTAssertEqual(req.allHTTPHeaderFields?[HTTPHeaderField.acceptVersion.description], "42")
        expectedRequestHeaders.fulfill()
      }
      simpleHost.delete("/", headers: [.acceptVersion: "42"]).json { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedRequestHeaders, expectedResponse], timeout: 1)
    }
  }
}
