//
//  HTTPClient.swift
//  TensorPool
//
//  Platform-agnostic HTTP client abstraction.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol that abstracts HTTP client functionality for cross-platform support.
public protocol TPHTTPClient: Sendable {
    func data(for request: TPHTTPRequest) async throws -> (Data, TPHTTPResponse)
}

/// A platform-agnostic HTTP request.
public struct TPHTTPRequest: Sendable {
    public var url: URL
    public var method: String
    public var headers: [String: String]
    public var body: Data?

    public init(url: URL, method: String, headers: [String: String], body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

/// A platform-agnostic HTTP response.
public struct TPHTTPResponse: Sendable {
    public var statusCode: Int
    public var headers: [String: String]

    public init(statusCode: Int, headers: [String: String] = [:]) {
        self.statusCode = statusCode
        self.headers = headers
    }
}

/// Factory that creates the appropriate HTTP client for the current platform.
public enum TPHTTPClientFactory {
    public static func createDefault() -> TPHTTPClient {
        #if os(Linux)
        return AsyncHTTPClientAdapter.createDefault()
        #else
        return URLSessionHTTPClientAdapter()
        #endif
    }
}
