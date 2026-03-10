//
//  TensorPoolServiceFactory.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// Factory for creating ``TensorPoolService`` instances.
    public enum ServiceFactory {
        /// Create a new TensorPool service with the given API token.
        ///
        /// - Parameters:
        ///   - apiToken: The API token from the [TensorPool Dashboard](https://tensorpool.dev/dashboard/api-key).
        ///   - basePath: The base URL for the API. Defaults to ``TensorPool/baseURL``.
        ///   - httpClient: The HTTP client to use. Defaults to a platform-appropriate client.
        /// - Returns: A configured ``TensorPoolService`` instance.
        public static func service(
            apiToken: String,
            basePath: String = TensorPool.baseURL,
            httpClient: TPHTTPClient? = nil
        ) -> TensorPoolService {
            DefaultTensorPoolService(
                apiToken: apiToken,
                basePath: basePath,
                httpClient: httpClient
            )
        }
    }
}
