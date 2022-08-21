[![Swift](https://github.com/Tavernari/SimpleMock/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/Tavernari/DIContainer/actions/workflows/swift.yml)[![Maintainability](https://api.codeclimate.com/v1/badges/4f79db0e9d2d9b596967/maintainability)](https://codeclimate.com/github/Tavernari/SimpleMock/maintainability)[![Test Coverage](https://api.codeclimate.com/v1/badges/4f79db0e9d2d9b596967/test_coverage)](https://codeclimate.com/github/Tavernari/SimpleMock/test_coverage)

# 🪆 Simple Mock Swift

It is a very simple Mock implementation made to help developers to create their own mocks easily.
Usually, creating mocks from scratch is tricky and sometimes we don't want to use a complex tool to just test simple cases.

The idea of this repository is more to show how you can create your own mock than just depend external tools.

>Writing your own mocks means you have to design your mocking structure. And that’s never a bad idea.
>
>When you write your own mocks, you aren’t using reflection, so your mocks will almost always be extremely fast.
[Uncle Bob - When to Mock](https://blog.cleancoder.com/uncle-bob/2014/05/10/WhenToMock.html)

## Usage

Your object mock has to conform to the Mock protocol and set an Enum with cases representing methods you expect to use.

So, after defining the Methods, you must create the collections that will store expectations, resolvers, and interactions.

On the methods the system under testing will use, you should call resolve to register interaction and request the value that should return.

```Swift
class ServiceMock: Service, Mock {
    
    enum Methods: Hashable {
        
        case save(_ id: String, _ value: Int)
        case load(_ id: String)
    }
    
    var methodsResolvers: [[Methods] : () -> Any] = [:]
    var methodsExpected: [[Methods]] = []
    var methodsRegistered: [[Methods]] = []
    
    func save(_ id: String, _ value: Int) throws {
        
        return try self.resolve(method: .save(id, value))
    }
    
    func load(_ id: String) throws -> Int {
        
        return try self.resolve(method: .load(id))
    }
}
```

#### Test usage

```Swift
try serviceMock.expect(method: .load(self.id)) { 0 }

try serviceMock.expect(method: .save(self.id, 10)) { Void() }
try serviceMock.expect(method: .load(self.id), after: .save(self.id, 10)) { 10 }

XCTAssertEqual(try serviceMock.load(self.id), 0)
XCTAssertNoThrow(try serviceMock.save(self.id, 10))
XCTAssertEqual(try serviceMock.load(self.id), 10)

try self.serviceMock.verify()
```

## Instalation

### Swift Package Manager

in `Package.swift` add the following:

```swift
dependencies: [
    .package(url: "https://github.com/Tavernari/SimpleMock", from: "0.1.0")
],
targets: [
    .target(
        name: "MyProject",
        dependencies: [..., "SimpleMock"]
    )
    ...
]
```
