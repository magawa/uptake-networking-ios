import XCTest
import UptakeNetworking
import UptakeToolbox
import Medea
import Perfidy

class GetTests: XCTestCase {
  let simpleHost = Host(url: FakeServer.defaultURL)
  
  func testSimpleGET() {
    let response = expectation(description: "Waiting for response")
    
    FakeServer.runWith { server in
      server.add("GET")
      simpleHost.get("/").data {
        if case .success = $0 {
          response.fulfill()
        }
      }
      wait(for: [response], timeout: 1)
    }
  }
  
  
  func testGETJSONResponse() {
    let expectedJSON = expectation(description: "waiting for JSON")
    
    FakeServer.runWith { server in
      server.add("GET", response: ["hello": "world"])
      simpleHost.get("/").json {
        if case .success(200, .object(let json)) = $0 {
          XCTAssertEqual(json["hello"] as! String, "world")
          expectedJSON.fulfill()
        }
      }
      wait(for: [expectedJSON], timeout: 1)
    }
  }
  
  
  func testGETJSONFragmentResponse() {
    let expectedJSON = expectation(description: "waiting for JSON")
    
    FakeServer.runWith { server in
      server.add("GET", response: Response(status: 200, headers: ["Content-Type": "application/json"], text: "\"fragment\""))
      simpleHost.get("/").json {
        if case .success(200, .string(let fragment)) = $0 {
          XCTAssertEqual(fragment, "fragment")
          expectedJSON.fulfill()
        }
      }
      wait(for: [expectedJSON], timeout: 1)
    }
  }
  
  
  func testGETNonJSONResponse() {
    let successResponse = expectation(description: "waiting for success")
    let failureResponse = expectation(description: "waiting for failure")

    FakeServer.runWith { server in
      server.add("GET", response: "some text")
      simpleHost.get("/").data {
        if case .success(200, "text/html"?, let d) = $0 {
          XCTAssertEqual(String(data: d, encoding: .utf8), "some text")
          successResponse.fulfill()
        }
      }
      simpleHost.get("/").json {
        if case .failure(JSONError.malformed) = $0 {
          failureResponse.fulfill()
        }
      }
      wait(for: [successResponse, failureResponse], timeout: 1)
    }
  }

  
  func testGETInvalidJSONResponse() {
    let expectedError = expectation(description: "waiting for error")
    let subject = "not json".data(using: .utf8)!
    
    FakeServer.runWith { server in
      server.add("GET", response: Response(status: 200, headers: ["Content-Type": "application/json"], data: subject))
      simpleHost.get("/").json {
        if case .failure(Medea.JSONError.malformed) = $0 {
          expectedError.fulfill()
        }
      }
      wait(for: [expectedError], timeout: 1)
    }
  }

  
  func testGETParams() {
    let paramsSent = expectation(description: "waiting for params to be sent")
    let subject1 = URLQueryItem(name: "foo", value: "bar")
    let subject2 = URLQueryItem(name: "baz", value: "quux")
    
    FakeServer.runWith { server in
      server.add("GET") { req in
        let items = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)!.queryItems!
        XCTAssert(items.contains(subject1))
        XCTAssert(items.contains(subject2))
        paramsSent.fulfill()
      }
      simpleHost.get("/", params: [subject1, subject2], headers: [:]).json(completion: { _ in })
      wait(for: [paramsSent], timeout: 1)
    }
  }
  
  
  func testGETStatusCode() {
    let expectedCode = expectation(description: "waiting for status code")
    FakeServer.runWith { server in
      server.add("GET", response: 404)
      simpleHost.get("/").data {
        if case .success(404, _, _) = $0 {
          expectedCode.fulfill()
        }
      }
      wait(for: [expectedCode], timeout: 1)
    }
  }
  
  
  func testGETWithHeaders() {
    let expectedRequestHeaders = expectation(description: "Waiting for expected request headers")
    let expectedResponse = expectation(description: "Waiting for response to prevent broken connections")

    FakeServer.runWith { server in
      server.add("GET") { req in
        XCTAssertEqual(req.allHTTPHeaderFields?[HTTPHeaderField.acceptVersion.description], "42")
        expectedRequestHeaders.fulfill()
      }
      
      simpleHost.get("/", headers: [.acceptVersion: "42"]).json { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedRequestHeaders, expectedResponse], timeout: 1)
    }
  }
}
