//
//  TensorPool+Error.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// Errors returned by the TensorPool API.
    public enum APIError: Error, Sendable {
        /// The request failed before reaching the server.
        case requestFailed(description: String)
        /// The server returned a non-success status code.
        case responseUnsuccessful(statusCode: Int, message: String)
        /// Authentication failed (401).
        case unauthorized
        /// Insufficient permissions (403).
        case forbidden
        /// Resource not found (404).
        case notFound(message: String)
        /// Insufficient balance (402).
        case insufficientBalance
        /// Conflict, such as deletion protection enabled (409).
        case conflict(message: String)
        /// Validation error (422).
        case validationError(detail: [ValidationErrorDetail])
        /// Failed to decode the response.
        case decodingFailed(description: String)
        /// Failed to encode the request.
        case encodingFailed(description: String)

        public var displayDescription: String {
            switch self {
            case .requestFailed(let description):
                return "Request failed: \(description)"
            case .responseUnsuccessful(let statusCode, let message):
                return "Response unsuccessful (\(statusCode)): \(message)"
            case .unauthorized:
                return "Unauthorized: Invalid or missing API token"
            case .forbidden:
                return "Forbidden: Insufficient permissions"
            case .notFound(let message):
                return "Not found: \(message)"
            case .insufficientBalance:
                return "Insufficient balance"
            case .conflict(let message):
                return "Conflict: \(message)"
            case .validationError(let detail):
                let messages = detail.map(\.msg).joined(separator: ", ")
                return "Validation error: \(messages)"
            case .decodingFailed(let description):
                return "Decoding failed: \(description)"
            case .encodingFailed(let description):
                return "Encoding failed: \(description)"
            }
        }
    }

    /// A validation error detail returned in 422 responses.
    public struct ValidationErrorDetail: Codable, Sendable {
        /// The location of the error in the request.
        public let loc: [String]
        /// A human-readable error message.
        public let msg: String
        /// The error type identifier.
        public let type: String
    }

    /// The standard error response body from TensorPool.
    public struct ErrorResponse: Codable, Sendable {
        public let detail: String?
        public let message: String?
    }

    /// A validation error response body (422).
    public struct ValidationErrorResponse: Codable, Sendable {
        public let detail: [ValidationErrorDetail]
    }
}
