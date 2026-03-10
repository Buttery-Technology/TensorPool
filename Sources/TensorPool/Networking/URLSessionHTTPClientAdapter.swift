//
//  URLSessionHTTPClientAdapter.swift
//  TensorPool
//
//  URLSession-based HTTP client for Apple platforms.
//

#if !os(Linux)
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct URLSessionHTTPClientAdapter: TPHTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: TPHTTPRequest) async throws -> (Data, TPHTTPResponse) {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpBody = request.body

        let (data, urlResponse) = try await session.data(for: urlRequest)

        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        var headers: [String: String] = [:]
        for (key, value) in httpURLResponse.allHeaderFields {
            if let k = key as? String, let v = value as? String {
                headers[k] = v
            }
        }

        return (data, TPHTTPResponse(statusCode: httpURLResponse.statusCode, headers: headers))
    }
}
#endif
