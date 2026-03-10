//
//  AsyncHTTPClientAdapter.swift
//  TensorPool
//
//  AsyncHTTPClient-based HTTP client for Linux.
//

#if os(Linux)
import AsyncHTTPClient
import Foundation
import NIOCore
import NIOFoundationCompat
import NIOHTTP1

public final class AsyncHTTPClientAdapter: TPHTTPClient, @unchecked Sendable {
    private let client: AsyncHTTPClient.HTTPClient

    public init(client: AsyncHTTPClient.HTTPClient) {
        self.client = client
    }

    deinit {
        try? client.shutdown().wait()
    }

    public static func createDefault() -> AsyncHTTPClientAdapter {
        let httpClient = AsyncHTTPClient.HTTPClient(
            eventLoopGroupProvider: .singleton,
            configuration: AsyncHTTPClient.HTTPClient.Configuration(
                certificateVerification: .fullVerification,
                timeout: .init(connect: .seconds(30), read: .seconds(60))
            )
        )
        return AsyncHTTPClientAdapter(client: httpClient)
    }

    public func data(for request: TPHTTPRequest) async throws -> (Data, TPHTTPResponse) {
        var clientRequest = HTTPClientRequest(url: request.url.absoluteString)
        clientRequest.method = NIOHTTP1.HTTPMethod(rawValue: request.method)

        for (key, value) in request.headers {
            clientRequest.headers.add(name: key, value: value)
        }

        if let body = request.body {
            clientRequest.body = .bytes(body)
        }

        let response = try await client.execute(clientRequest, deadline: .now() + .seconds(60))
        let body = try await response.body.collect(upTo: 100 * 1024 * 1024)
        let data = Data(buffer: body)

        var headers: [String: String] = [:]
        for header in response.headers {
            headers[header.name] = header.value
        }

        return (data, TPHTTPResponse(statusCode: Int(response.status.code), headers: headers))
    }
}
#endif
