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
    
    var resolvers: [[Methods] : () -> Any] = [:]
    var expecteds: [[Methods]] = []
    var registered: [[Methods]] = []
    
    func save(_ id: String, _ value: Int) throws {
        
        return try self.resolve(method: .save(id, value))
    }
    
    func load(_ id: String) throws -> Int {
        
        return try self.resolve(method: .load(id))
    }
}
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
