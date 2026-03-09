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
        ///   - session: The URLSession to use. Defaults to `.shared`.
        /// - Returns: A configured ``TensorPoolService`` instance.
        public static func service(
            apiToken: String,
            basePath: String = TensorPool.baseURL,
            session: URLSession = .shared
        ) -> TensorPoolService {
            DefaultTensorPoolService(
                apiToken: apiToken,
                basePath: basePath,
                session: session
            )
        }
    }
}
