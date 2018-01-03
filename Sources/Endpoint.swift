import Foundation
import Medea



/// Conforming types are capable of being represented as an `Endpoint`.
public protocol EndpointConvertible {
  /// The `Endpoint` representation of the conforming type.
  var endpointValue: Endpoint { get }
}



/// A value encapsulating the method, path, and optional parameters of an HTTP request.
public struct Endpoint {
  internal let method: HTTPMethod
  internal let path: String
  internal let json: ValidJSONObject?
  private let _headers: [HTTPHeaderField: String]
  internal var headers: [HTTPHeaderField: String] {
    switch method {
      //Methods that take a body and have JSON, set the content type.
    case .put, .patch, .post:
      guard json != nil else {
        return _headers
      }
      return _headers.merging([.contentType: "application/json"]) { existing, _ in
        // If `oldHeaders` has an explicit content type, don't overwrite it.
        return existing
      }
    default:
      return _headers
    }
  }
  
  
  /**
   Initializes an endpoint with the given method, path, and optional parameters as a JSON object.
   
   - Parameter method: The HTTP method to use. Usually one of GET, POST, PUT, or DELETE.
   
   - Parameter path: The path of the desired resource. This will usually be appended to the URL of a `Host` before being passed to a request. Do not put query params in here. That's what `json` is for.
   
   - Parameter json: *Optional.* The parameters to be included in the request. If this is a GET request, they'll be encoded into query params (using [Rails conventions](http://codefol.io/posts/How-Does-Rack-Parse-Query-Params-With-parse-nested-query) if nested). Otherwise this JSON is serialized, UTF-8 encoded, and set as the request body (with an appropriate `Content-Type` header).
   */
  public init(method: HTTPMethod, path: String, json: ValidJSONObject? = nil, headers: [HTTPHeaderField: String] = [:]) {
    self.method = method
    self.path = path
    self.json = json
    _headers = headers
  }
}



public extension Endpoint {
  func request(from baseURL: URL) -> URLRequest {
    debug? {[
      "REQUEST--------------",
      "method: \(method.description)",
      "url: \(url(from: baseURL))",
      "json: \(json?.value ?? [:])",
      "headers: \(headers)",
      ]}
    var req = URLRequest(url: url(from: baseURL))
    req.httpMethod = method.description
    headers.forEach { key, value in
      req.addValue(value, forHTTPHeaderField: key.description)
    }
    req.httpBody = body
    return req
  }
}


extension Endpoint: EndpointConvertible {
  public var endpointValue: Endpoint {
    return self
  }
}



private extension Endpoint {
  var queryItems: [URLQueryItem]? {
    switch method {
    case .get:
      guard let someJSON = json else {
        return nil
      }
      return Helper.jsonToQuery(someJSON)
    default:
      return nil
    }
  }
  
  
  var body: Data? {
    switch method {
    case .patch, .post, .put:
      guard let someJSON = json else {
        return nil
      }
      return JSONHelper.data(from: someJSON)
    default:
      return nil
    }
  }
  
  
  func url(from baseURL: URL) -> URL {
    guard var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      fatalError("Problem resolving against base URL")
    }
    
    comps.appendPathComponent(path)
    
    if let qs = queryItems {
      if comps.queryItems == nil {
        comps.queryItems = qs
      } else {
        comps.queryItems?.append(contentsOf: qs)
      }
    }
    
    guard let url = comps.url else {
      fatalError("Problem with leading “/” in path.")
    }
    
    return url
  }
}



private enum Helper {
  static func jsonToQuery(_ json: ValidJSONObject) -> [URLQueryItem] {
    // This is easiest to implement recursively, which means it has to take «Any». But we only want to allow a «JSONObject» at the top-level. So we wrap the generic recursive func in the strongly typed version.
    return anyJSONToQuery(json.value, prefix: nil)
  }
  
  
  private static func anyJSONToQuery(_ jsonValue: Any, prefix: String?) -> [URLQueryItem] {
    var items: [URLQueryItem] = []
    
    switch jsonValue {
    case let d as JSONObject:
      d.forEach {
        let newPrefix = prefix == nil ? $0.key : prefix! + "[\($0.key)]"
        items.append(contentsOf: anyJSONToQuery($0.value, prefix: newPrefix))
      }
      
    case let a as Array<Any>:
      guard let somePrefix = prefix else {
        fatalError("Top-level array encountered when converting to params.")
      }
      a.forEach { it in
        items.append(contentsOf: anyJSONToQuery(it, prefix: somePrefix + "[]"))
      }
      
    default:
      guard let somePrefix = prefix else {
        fatalError("Top-level value encountered when converting to params.")
      }
      items.append(URLQueryItem(name: somePrefix, value: String(describing: jsonValue)))
    }
    
    return items
  }
}
  


private extension URLComponents {
  private enum K {
    static let delimiter = "/"
    static let pad = "|"
    static let delimiterSet = CharacterSet(charactersIn: delimiter)
  }
  
  
  mutating func appendPathComponent(_ component: String) {
    path = trimmingBack(path) + K.delimiter + trimmingFront(component)
  }
  
  
  private func trimmingFront(_ string: String) -> String {
    let trimmed = (string + K.pad).trimmingCharacters(in: K.delimiterSet)
    return String(trimmed.dropLast())
  }
  
  
  private func trimmingBack(_ string: String) -> String {
    let trimmed = (K.pad + string).trimmingCharacters(in: K.delimiterSet)
    return String(trimmed.dropFirst())
  }
}
