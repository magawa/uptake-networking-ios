import XCTest
import UptakeNetworking
import UptakeToolbox
import Medea
import Perfidy



class PostTests: XCTestCase {
  let simpleHost = Host(url: FakeServer.defaultURL)
  let emptyJSON = try! ValidJSONObject([:])
  
  func testSimplePOST() {
    let response = expectation(description: "Waiting for response")
    
    FakeServer.runWith { server in
      server.add("POST")
      simpleHost.post("/", json: emptyJSON).data {
        if case .success = $0 {
          response.fulfill()
        }
      }
      wait(for: [response], timeout: 1)
    }
  }
  
  
  func testPOSTJSONResponse() {
    let expectedJSON = expectation(description: "waiting for JSON")
    
    FakeServer.runWith { server in
      server.add("POST", response: ["hello": "world"])
      simpleHost.post("/", json: emptyJSON).json {
        if case .success(200, .object(let json)) = $0 {
          XCTAssertEqual(json["hello"] as! String, "world")
          expectedJSON.fulfill()
        }
      }
      wait(for: [expectedJSON], timeout: 1)
    }
  }
  
  
  func testPOSTJSONFragmentResponse() {
    let expectedJSON = expectation(description: "waiting for JSON")
    
    FakeServer.runWith { server in
      server.add("POST", response: Response(status: 200, headers: ["Content-Type": "application/json"], text: "\"fragment\""))
      simpleHost.post("/", json: emptyJSON).json {
        if case .success(200, .string(let fragment)) = $0 {
          XCTAssertEqual(fragment, "fragment")
          expectedJSON.fulfill()
        }
      }
      wait(for: [expectedJSON], timeout: 1)
    }
  }
  
  
  func testPOSTNonJSONResponse() {
    let successResponse = expectation(description: "waiting for success")
    let failureResponse = expectation(description: "waiting for failure")

    FakeServer.runWith { server in
      server.add("POST", response: "some text")
      simpleHost.post("/", json: emptyJSON).data {
        if case .success(200, "text/html"?, let d) = $0 {
          XCTAssertEqual(String(data: d, encoding: .utf8), "some text")
          successResponse.fulfill()
        }
      }
      simpleHost.post("/", json: emptyJSON).json {
        if case .failure(JSONError.malformed) = $0 {
          failureResponse.fulfill()
        }
      }
      wait(for: [successResponse, failureResponse], timeout: 1)
    }
  }
  
  
  func testPOSTInvalidJSONResponse() {
    let expectedError = expectation(description: "waiting for error")
    let subject = "not json".data(using: .utf8)!
    
    FakeServer.runWith { server in
      server.add("POST", response: Response(status: 200, headers: ["Content-Type": "application/json"], data: subject))
      simpleHost.post("/", json: emptyJSON).json {
        if case .failure(Medea.JSONError.malformed) = $0 {
          expectedError.fulfill()
        }
      }
      wait(for: [expectedError], timeout: 1)
    }
  }
  
  
  func testPOSTBody() {
    let bodySent = expectation(description: "waiting for body to be sent")
    
    FakeServer.runWith { server in
      server.add("POST") { req in
        let body = String(data: req.httpBody!, encoding: .utf8)!
        XCTAssertEqual(body, "{\"hello\":\"world\"}")
        bodySent.fulfill()
      }
      simpleHost.post("/", json: try! ValidJSONObject(["hello": "world"])).json(completion: { _ in })
      wait(for: [bodySent], timeout: 1)
    }
  }
  
  
  func testPOSTStatusCode() {
    let expectedCode = expectation(description: "waiting for status code")
    FakeServer.runWith { server in
      server.add("POST", response: 404)
      simpleHost.post("/", json: emptyJSON).data {
        if case .success(404, _, _) = $0 {
          expectedCode.fulfill()
        }
      }
      wait(for: [expectedCode], timeout: 1)
    }
  }
  
  
  func testPOSTWithHeaders() {
    let expectedRequestHeaders = expectation(description: "Waiting for expected request headers")
    let expectedResponse = expectation(description: "Waiting for response to prevent broken connections")

    FakeServer.runWith { server in
      server.add("POST") { req in
        XCTAssertEqual(req.allHTTPHeaderFields?[HTTPHeaderField.acceptVersion.description], "42")
        expectedRequestHeaders.fulfill()
      }
      
      simpleHost.post("/", json: emptyJSON, headers: [.acceptVersion: "42"]).json { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedRequestHeaders, expectedResponse], timeout: 1)
    }
  }
  
  
  func testImplicitContentType() {
    let expectedContentType = expectation(description: "waiting for content type")
    let expectedResponse = expectation(description: "Waiting for response to prevent broken connections")
    
    FakeServer.runWith { server in
      server.add("POST") { req in
        let subject = req.allHTTPHeaderFields?[HTTPHeaderField.contentType.description]
        XCTAssertEqual(subject, "application/json")
        expectedContentType.fulfill()
      }
      let host = Host(url: server.url)
      host.post("/", json: emptyJSON).json { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedContentType, expectedResponse], timeout: 1)
    }
  }
  
  
  func testExplicitContentType() {
    let expectedContentType = expectation(description: "waiting for content type")
    let expectedResponse = expectation(description: "Waiting for response to prevent broken connections")
    
    FakeServer.runWith { server in
      server.add("POST") { req in
        let subject = req.allHTTPHeaderFields?[HTTPHeaderField.contentType.description]
        XCTAssertEqual(subject, "x-fake/header")
        expectedContentType.fulfill()
      }
      let host = Host(url: server.url)
      host.post("/", json: emptyJSON, headers: [.contentType: "x-fake/header"]).json { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedContentType, expectedResponse], timeout: 1)
    }
  }
}
