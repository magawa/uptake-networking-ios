import Foundation


/**
 An alternative to stringly-typed HTTP headers. Common headers have their own members in the enum. Custom types can be represented with `custom`.
 
 - Seealso:
   - https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
   - http://www.figure.ink/blog/2017/5/29/mixing-constant-and-literal-strings
 */
public enum HTTPHeaderField {
  
  
  /** 
   A standard header field type.
   
   - Seealso: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
   */
  case accept, acceptCharset, acceptEncoding, acceptLanguage, acceptVersion, authorization, cacheControl, connection, cookie, contentLength, contentMD5, contentType, date, host, origin, referer, userAgent
  
  
  /**
   Custom headers are a common occurance. Such headers can still be represented as an `HTTPHeaderField` by making them the associated value of this `custom` type.
   
   - Seealso: http://www.figure.ink/blog/2017/5/29/mixing-constant-and-literal-strings
   */
  case custom(String)
}



extension HTTPHeaderField: CustomStringConvertible {
  /** 
   A `String` representation of the reciever. In most cases, it's the string of the given header as it would appear in a request. i.e.: `.contentType.description == "Content-Type"`.
   
   In the case of `custom`, this representation is its associated value (`.custom("foo").description == "foo"`).
   */
  public var description: String {
    switch self {
    case .accept: return "Accept"
    case .acceptCharset: return "Accept-Charset"
    case .acceptEncoding: return "Accept-Encoding"
    case .acceptLanguage: return "Accept-Language"
    case .acceptVersion: return "Accept-Version"
    case .authorization: return "Authorization"
    case .cacheControl: return "Cache-Control"
    case .connection: return "Connection"
    case .cookie: return "Cookie"
    case .contentLength: return "Content-Length"
    case .contentMD5: return "Content-MD5"
    case .contentType: return "Content-Type"
    case .date: return "Date"
    case .host: return "Host"
    case .origin: return "Origin"
    case .referer: return "Referer"
    case .userAgent: return "User-Agent"
    case .custom(let s): return s
    }
  }
}



extension HTTPHeaderField: Equatable {
  /**
   Implements `Equatable`. This is slighly different from the standard enum implementation in that it bases equality off of the value of `description`. Thus:
   
   ```
   HTTPHeaderField.origin == HTTPHeaderField.custom("Origin")
   ```
   */
  public static func ==(lhs: HTTPHeaderField, rhs: HTTPHeaderField) -> Bool {
    return lhs.description == rhs.description
  }
}



extension HTTPHeaderField: Hashable {
  /// Makes `HTTPHeaderField` hashable, which is important seeing as it's only purpose in life is to serve as the key of a `Dictionary`.
  public var hashValue: Int {
    return description.hashValue
  }
}
