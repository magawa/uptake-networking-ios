import Foundation
import UptakeToolbox
import Medea



/// An abstraction around a server hosting a collection of REST endpoints.
public class Host {
  fileprivate let session: URLSession
  fileprivate let hostURL: URL
  
  
  /**
   Initializes a `Host`.
   
   - Parameter url: The URL used to reach this host. Note it can also contain a path which is then prefixed to all future requests. This is useful when all endpoints share a common prefix, for example in the case of versioning.
   
     Rather than creating a host at `http://example.com` and endpoints at `/v1/foo`, `/v1/bar`, etc., we can include the common prefix in the URL: `http://example.com/v1`
   
   - Parameter constantHeaders: Headers that will be included in every request to this host (though headers specified in the request will override those given here).

     `Content-Type` is usually inferred by requests on the host. There's usually no reason to include it here.
   
   - Parameter timeout: The default timeout for requests on this host, in seconds.
   */
  public init(url: URL, defaultHeaders: [HTTPHeaderField: String] = [:], timeout: TimeInterval = 15.0) {
    self.hostURL = url
    session = Helper.makeSession(headers: defaultHeaders, timeout: timeout)
  }
}



public extension Host {
  /**
   Asynchronously sends a GET request to the given path of the host.
   
   - Parameter path: The path of the desired endpoint. This will be appended to the URL given to the host on initialization.
   
   - Parameter params: *Optional.* Query params to send with the GET request.
   
   - Parameter headers: *Optional.* HTTP Headers to include in this request. These will overrite any default headers specified on host initialization.
   
   - Parameter completion: A callback that will be evaluated at the conclusion of the network task. Usually, this is when getting a response from the server, but could also be in response to a timeout, network failure, or some other error.
   
     Failures conditions:
   
     - Standard `NSError`s from `URLSessionDataTask` (see: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes)
     
     - `ResponseError` — when there's an issue with the format or content of the response.
     
     - `HTTPError` — when the response isn't HTTP or has an issue with its status code.
   
     - `Medea.JSONError` — when there's an issue parsing the body as JSON.
   */
  @discardableResult func get(_ path: String, params: [URLQueryItem] = [], headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .get, path: path, json: Helper.queryToJSON(params), headers: headers)
    return request(endpoint)
  }
  
  
  /**
   Asynchronously sends a POST request to the given path of the host.
   
   - Parameter path: The path of the desired endpoint. This will be appended to the URL given to the host on initialization.
   
   - Parameter json: *Optional.* Body of the request, formatted as a JSON object. This should already have been checked for validity by wrapping in a `ValidJSONObject`.
   
   - Parameter headers: *Optional.* HTTP Headers to include in this request. These will overrite any default headers specified on host initialization. `Content-Type` is assumed to be `application/json` and does not need to be given explicitly.
   
   - Parameter completion: A callback that will be evaluated at the conclusion of the network task. Usually, this is when getting a response from the server, but could also be in response to a timeout, network failure, or some other error.
   
     Failure conditions:
     
     - Standard `NSError`s from `URLSessionDataTask` (see: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes)
   
     - `ResponseError` — when there's an issue with the format or content of the response.
     
     - `HTTPError` — when the response isn't HTTP or has an issue with its status code.
     
     - `Medea.JSONError` — when there's an issue parsing the body as JSON.
   */
  @discardableResult func post(_ path: String, json: ValidJSONObject, headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .post, path: path, json: json, headers: headers)
    return request(endpoint)
  }
  
  

  /**
   Asynchronously sends a PUT request to the given path of the host.
   
   - Parameter path: The path of the desired endpoint. This will be appended to the URL given to the host on initialization.
   
   - Parameter json: *Optional.* Body of the request, formatted as a JSON object. This should already have been checked for validity by wrapping in a `ValidJSONObject`.
   
   - Parameter headers: *Optional.* HTTP Headers to include in this request. These will overrite any default headers specified on host initialization. `Content-Type` is assumed to be `application/json` and does not need to be given explicitly.
   
   - Parameter completion: A callback that will be evaluated at the conclusion of the network task. Usually, this is when getting a response from the server, but could also be in response to a timeout, network failure, or some other error.
   
     Failure conditions:
     
     - Standard `NSError`s from `URLSessionDataTask` (see: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes)
   
     - `ResponseError` — when there's an issue with the format or content of the response.
     
     - `HTTPError` — when the response isn't HTTP or has an issue with its status code.
     
     - `Medea.JSONError` — when there's an issue parsing the body as JSON.
   */
  @discardableResult func put(_ path: String, json: ValidJSONObject, headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .put, path: path, json: json, headers: headers)
    return request(endpoint)
  }
  
  
  /**
   Asynchronously sends a DELETE request to the given path of the host.
   
   - Parameter path: The path of the desired endpoint. This will be appended to the URL given to the host on initialization.
   
   - Parameter headers: *Optional.* HTTP Headers to include in this request. These will overrite any default headers specified on host initialization. `Content-Type` is assumed to be `application/json` and does not need to be given explicitly.
   
   - Parameter completion: A callback that will be evaluated at the conclusion of the network task. Usually, this is when getting a response from the server, but could also be in response to a timeout, network failure, or some other error.
   
     Possible errors:
     
     - Standard `NSError`s from `URLSessionDataTask` (see: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes)
   
     - `ResponseError` — when there's an issue with the format or content of the response.
     
     - `HTTPError` — when the response isn't HTTP or has an issue with its status code.
     
     - `Medea.JSONError` — when there's an issue parsing the body as JSON.
   */
  @discardableResult func delete(_ path: String, headers: [HTTPHeaderField: String] = [:]) -> Request {
    let endpoint = Endpoint(method: .delete, path: path, json: nil, headers: headers)
    return request(endpoint)
  }
  
  
  
  /**
   Asynchronously sends a request using the method, path, etc. encapsulated in the `endpoint`.
   
   - Parameter endpoint: Any type resolvable to an `Endpoint`. This encapsulates the method, path, parameters, and headers to be used in the request.
   
   - Parameter completion: A callback that will be evaluated at the conclusion of the network task. Usually, this is when getting a response from the server, but could also be in response to a timeout, network failure, or some other error.
   
     Possible errors:
     
     - Standard `NSError`s from `URLSessionDataTask` (see: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes)
   
     - `ResponseError` — when there's an issue with the format or content of the response.
     
     - `HTTPError` — when the response isn't HTTP or has an issue with its status code.
     
     - `Medea.JSONError` — when there's an issue parsing the body as JSON.
   */
  @discardableResult func request(_ endpointConvertible: EndpointConvertible) -> Request {
    let endpoint = endpointConvertible.endpointValue
    let req = endpoint.request(from: hostURL)
    
    debug? {[
      "REQUEST--------------",
      "method: \(req.httpMethod ?? "none")",
      "url: \(req.url?.absoluteString ?? "none")",
      "json: \(endpoint.json?.value ?? [:])",
      "headers: \(req.allHTTPHeaderFields ?? [:])",
      ]}
    
    return Request(session: session, request: req)
  }
}



private enum Helper {
  static func queryToJSON(_ query: [URLQueryItem]) -> ValidJSONObject {
    var json: [String: Any] = [:]
    query.forEach { json[$0.name] = $0.value }
    return try! ValidJSONObject(json)
  }

  
  static func makeSession(headers: [HTTPHeaderField: String], timeout: TimeInterval) -> URLSession {
    debug? {[
      "MAKE SESSION-----------",
      "headers: \(headers)",
      "timeout: \(timeout)",
      ]}
    
    let  config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.httpAdditionalHeaders = sessionHeaders(from: headers)
    config.timeoutIntervalForRequest = timeout
    
    return URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
  }
  
  
  static private func sessionHeaders(from headers: [HTTPHeaderField: String]) -> [String: String] {
    var sessionHeaders: [String: String] = [:]
    headers.forEach { sessionHeaders[String(describing: $0)] = $1 }
    return sessionHeaders
  }
}
