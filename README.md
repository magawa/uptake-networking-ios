# UptakeNetworking
![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat) ![API docs](http://mobile-toolkit-docs.services.common.int.uptake.com/docs/uptake-networking-ios/badge.svg)

An abstraction around `URLSession` providing a RESTful interface to a host and enpoints.

## Direct Usage
Start by defining a `Host`. You might want to do this someplace globally if you'll be using the API frequently from different locations:

```swift
public enum API {
  static let uptake = Host(url: URL(string: "https://uptake-prod-staging.apigee.net/cat/auth/v1")!)
}
```

Note the host URL need not limit itself to the server. If there's a common path component all endpoints share (for example, a version prefix as above), that can be included here to save typing later.

Later, when you need to send a requiest to a given path with a given verb, you can…

```swift
API.uptake.get("/my/resource") { responseResult in
  // Handle response...
}

API.uptake.post("/some/resource") { responseResult in
  // &c. &c.
}
```

`responseResult` is a Result type wrapping either an error (in the case of network failure) or a `(HTTPStatusCode, AnyJSON?)` tuple. This gives the caller a great deal of flexibility through pattern matching without ever needing to parse the response. A simple handler can be simple:


```swift
API.uptake.get("/some/resource") { 
  if case .success(_, .object(let json)?) = $0 {
    let model = MyResourceModel(json: json)
    // do something with model
  }
}
```

Whereas more robust handling is not only possible, but succinct for what it achieves:

```swift
API.uptake.get("/some/resource") { 
  switch $0 {
    case .success(_, nil):
      // Alert user about invalid response format...

    case .success(HTTPStatusCode.successRange, .object(let json)?):
      let model = MyResourceModel(json: json)
      // do something with model

    case .success(.unauthorized, _),
         .success(.forbidden, _):
      // Present log in screen...

    case .failure(let error):
      // Present alert with error message...

    default:
      // Present alert with default message...
  }
}
```

## Defining Endpoints
Under Construction…
