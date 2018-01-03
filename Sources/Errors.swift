import Foundation



/// The response isn't HTTP or has an issue with HTTP things like status codes.
public enum HTTPError: LocalizedError {
  /// A response was returned from the networking stack, but it didn't contain an HTTP status code.
  case nonHTTP
  
  /// An HTTP response was returned from the networking stack, but its status code was out-of-range.
  case invalidStatusCode(Int)
  
  /// An HTTP response was returned with a status code that was unexpected by the client.
  case unexpectedStatus(HTTPStatusCode)
  
  /// :nodoc:
  public var errorDescription: String? {
    switch self {
    case .nonHTTP:
      return "Expected HTTP Response"
    case .invalidStatusCode:
      return "Invalid Status"
    case .unexpectedStatus:
      return "Unexpected Response"
    }
  }
  
  
  public var failureReason: String? {
    switch self {
    case .nonHTTP:
      return "The response from server was missing one or more values required by HTTP."
    case .invalidStatusCode(let code):
      return "The server returned a status of “\(code)”, which is invalid."
    case .unexpectedStatus(let code):
      return "The server responded with an unexpected status. \(code.description)"
    }
  }
}



