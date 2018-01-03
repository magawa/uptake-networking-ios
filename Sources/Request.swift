import Foundation
import UptakeToolbox
import Medea

/// Given a session and a request, this class provides methods for turning the request into a data task with the requested completion type.
///
/// This should always be returned by a `Host` method. It should never be created from scratch.
public class Request {
  /// A `Result` type whose `.success` wraps a status code, content type, and `Data` blob.
  public typealias HTTPDataCompletion = (Result<(code: HTTPStatusCode, contentType: String?, body: Data)>) -> Void

  /// A `Result` type whose `.success` wraps a status code and JSON.
  public typealias HTTPJSONCompletion = (Result<(code: HTTPStatusCode, json: AnyJSON)>) -> Void
  
  
  private let session: URLSession
  private let request: URLRequest
  
  
  internal init(session: URLSession, request: URLRequest) {
    self.session = session
    self.request = request
  }
}



public extension Request {
  @discardableResult func data(completion: @escaping HTTPDataCompletion) -> URLSessionTask {
    return makeDataTask(completion: completion)
  }
  
  
  @discardableResult func json(completion: @escaping HTTPJSONCompletion) -> URLSessionTask {
    return data(completion: Helper.dataHandler(from: completion))
  }
}



private extension Request {
  func makeDataTask(completion: @escaping HTTPDataCompletion) -> URLSessionTask {
    let task = session.dataTask(with: request) { data, response, error in
      debug? {[
        "RESPONSE---------------------",
        String(describing: response),
        ]}
      debug? {
        guard
          let _data = data,
          let body = String(data: _data, encoding: .utf8) else {
            return []
        }
        return [
          "DATA-----------------------",
          body
        ]
      }
      
      switch (data, response, error) {
      case let(_, _, e?):
        debug? {[
          "ERROR----------------------",
          String(describing: e)
          ]}
        completion(.failure(e))
        
      case let (d?, r?, _):
        guard let httpResponse = r as? HTTPURLResponse else {
          let error = HTTPError.nonHTTP
          debug? {[
            "ERROR----------------------",
            String(describing: error)
            ]}
          completion(.failure(error))
          return
        }
        guard let code = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
          let error = HTTPError.invalidStatusCode(httpResponse.statusCode)
          debug? {[
            "ERROR----------------------",
            String(describing: error)
            ]}
          completion(.failure(error))
          return
        }
        let successTuple = (
          code: code,
          contentType: Helper.contentType(from: httpResponse.allHeaderFields),
          body: d)
        completion(.success(successTuple))
        
      default:
        //URLSession should always return either an error or data and response together.
        fatalError("URLSession contract failure")
      }
    }
    task.resume()
    return task
  }
}



private enum Helper {
  static func dataHandler(from handler: @escaping Request.HTTPJSONCompletion) -> Request.HTTPDataCompletion {
    return { (res: Result<(code: HTTPStatusCode, contentType: String?, body: Data)>) -> Void in
      let jsonResult = res.flatMap { (code, contentType, body) -> Result<(code: HTTPStatusCode, json: AnyJSON)> in
        do {
          return .success((code: code, json: try JSONHelper.anyJSON(from: body)))
        } catch {
          return .failure(error)
        }
      }
      handler(jsonResult)
    }
  }
  
  
  static func contentType(from dict: [AnyHashable: Any]) -> String? {
    return dict.first { key, _ in
      guard let stringKey = key as? String else {
        return false
      }
      return stringKey *== HTTPHeaderField.contentType.description
      }?.value as? String
  }
}
