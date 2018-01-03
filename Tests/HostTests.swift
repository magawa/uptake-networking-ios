import XCTest
import UptakeNetworking
import UptakeToolbox
import Medea
import Perfidy

class HostTests: XCTestCase {
  func testHostHeaders() {
    let expectedRequestHeaders = expectation(description: "Waiting for expected request headers")
    let expectedResponse = expectation(description: "Waiting for the response to get back to avoid broken connections")
    
    FakeServer.runWith { server in
      let subject = Host(url: server.url, defaultHeaders: [.acceptVersion: "100"])
      server.add("GET") { req in
        XCTAssertEqual(req.allHTTPHeaderFields?[HTTPHeaderField.acceptVersion.description], "100")
        expectedRequestHeaders.fulfill()
      }
      subject.get("/").json { _ in
        expectedResponse.fulfill()
      }
  
      wait(for: [expectedRequestHeaders, expectedResponse], timeout: 1)
    }
  }
  

  func testHostHeadersOverriddenByRequest() {
    let expectedRequestHeaders = expectation(description: "Waiting for expected request headers")
    let expectedResponse = expectation(description: "Waiting for response so as to avoid disconnection and retries.")
    
    FakeServer.runWith { server in
      let subject = Host(url: server.url, defaultHeaders: [.acceptVersion: "42"])
      server.add("GET") { req in
        XCTAssertEqual(req.allHTTPHeaderFields?[HTTPHeaderField.acceptVersion.description], "64")
        expectedRequestHeaders.fulfill()
      }
      subject.get("/", headers: [.acceptVersion: "64"]).json { _ in
        expectedResponse.fulfill()
      }
      
      wait(for: [expectedRequestHeaders, expectedResponse], timeout: 1)
    }
  }
  
  
  func testTimeout() {
    let expectedTimeout = expectation(description: "Waiting for timeout...")

    FakeServer.runWith { server in
      let subject = Host(url: server.url, timeout: 0.5)
      server.add("GET", response: 666) //Special timeout code
      subject.get("/").json {
        if case .failure(URLError.timedOut) = $0 {
          expectedTimeout.fulfill()
        }
      }
    
      wait(for: [expectedTimeout], timeout: 1)
    }
  }
  
  
  func testInvalidURL() {
    let expectedError = expectation(description: "Waiting for error")
    
    let subject = Host(url: URL(string: "http://example.invalid")!)
    subject.get("/").json {
      if case .failure(URLError.cannotFindHost) = $0 {
        expectedError.fulfill()
      }
    }
    
    wait(for: [expectedError], timeout: 1)
  }
  
  
  func testInvalidStatusCode() {
    let expectedBadCode = expectation(description: "waiting for bad code")
    
    FakeServer.runWith { server in
      server.add("GET", response: 800)
      let host = Host(url: server.url)
      host.get("/").json {
        if case .failure(HTTPError.invalidStatusCode) = $0 {
          expectedBadCode.fulfill()
        }
      }
      
      wait(for: [expectedBadCode], timeout: 1)
    }
  }
}
