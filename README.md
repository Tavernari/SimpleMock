# Simple Mock Swift 🚀

[![Swift](https://github.com/Tavernari/SimpleMock/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/Tavernari/DIContainer/actions/workflows/swift.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/4f79db0e9d2d9b596967/maintainability)](https://codeclimate.com/github/Tavernari/SimpleMock/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4f79db0e9d2d9b596967/test_coverage)](https://codeclimate.com/github/Tavernari/SimpleMock/test_coverage)

## Introduction

Simple Mock Swift is a lightweight and powerful mocking tool designed specifically for Swift developers. With features supporting basic operations, concurrency-safe mocking, and intuitive setup, Simple Mock Swift ensures that you have the best tools at hand for effective testing.

## Motivation

While there are many mocking libraries available, crafting mocks from scratch is often a challenging task. Simple Mock Swift strives to offer a solution that's lightweight, yet comprehensive. As [Uncle Bob](https://blog.cleancoder.com/uncle-bob/2014/05/10/WhenToMock.html) rightly said: "Writing your own mocks means you have to design your mocking structure. And that’s never a bad idea."

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Tavernari/SimpleMock", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["SimpleMock"]
    )
]
```

## Usage

### Basic Mocking (`Mock`)

For typical mocking scenarios, your mock object should conform to the `Mock` protocol. Define an Enum with cases representing the methods you intend to use. Utilize the methods provided by `Mock` to set up and resolve your expectations.

```swift
class ServiceMock: Service, Mock<ServiceMock.Methods> {
    enum Methods: Hashable {
        case save(_ id: String, _ value: Int)
        case load(_ id: String)
    }
    
    func save(_ id: String, _ value: Int) throws {
        return try self.resolve(method: .save(id, value))
    }
    
    func load(_ id: String) throws -> Int {
        return try self.resolve(method: .load(id))
    }
}
```

### Concurrency-Safe Mocking (`ActorMock`)

For scenarios involving concurrency, your mocks should adhere to the `ActorMock` protocol. This ensures that your mocks can handle concurrent accesses in a safe manner.

```swift
class ActorServiceMock: Service, ActorMock {
    enum Methods: Hashable {
        case save(_ id: String, _ value: Int)
        case load(_ id: String)
    }
    
    func save(_ id: String, _ value: Int) async throws {
        return try await self.resolve(method: .save(id, value))
    }
    
    func load(_ id: String) async throws -> Int {
        return try await self.resolve(method: .load(id))
    }
}
```

## Testing

A comprehensive suite of tests is provided to validate the behavior of the mocks. These tests cover various scenarios, from basic mock expectations to complex concurrent interactions.

## Conclusion

Simple Mock Swift is dedicated to being a versatile and efficient tool for all your Swift mocking needs. Feedback, contributions, and suggestions are always welcome!

## References

- [Uncle Bob - When to Mock](https://blog.cleancoder.com/uncle-bob/2014/05/10/WhenToMock.html)

