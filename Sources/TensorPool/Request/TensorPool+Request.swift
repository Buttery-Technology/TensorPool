//
//  TensorPool+Request.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// The type of async operation being tracked.
    public enum RequestType: String, Codable, Sendable {
        case clusterClaim = "CLUSTER_CLAIM"
        case clusterRelease = "CLUSTER_RELEASE"
        case clusterEdit = "CLUSTER_EDIT"
        case storageCreate = "STORAGE_CREATE"
        case storageDestroy = "STORAGE_DESTROY"
        case storageAttach = "STORAGE_ATTACH"
        case storageDetach = "STORAGE_DETACH"
        case storageEdit = "STORAGE_EDIT"
    }

    /// The status of an async operation.
    public enum RequestStatus: String, Codable, Sendable {
        case pending = "PENDING"
        case processing = "PROCESSING"
        case retrying = "RETRYING"
        case completed = "COMPLETED"
        case failed = "FAILED"

        /// Whether this is a terminal state that will not change.
        public var isTerminal: Bool {
            switch self {
            case .completed, .failed:
                return true
            case .pending, .processing, .retrying:
                return false
            }
        }
    }

    /// Response returned when polling an async operation's status.
    public struct RequestInfoResponse: Codable, Sendable {
        /// The unique identifier of the request.
        public let requestId: String
        /// The type of operation.
        public let requestType: RequestType
        /// The current status of the operation.
        public let status: RequestStatus
        /// When the operation was created (ISO 8601).
        public let createdAt: String
        /// The ID of the object this operation acts on.
        public let objectId: String?
        /// A human-readable message about the operation.
        public let externalMessage: String?

        public init(
            requestId: String,
            requestType: RequestType,
            status: RequestStatus,
            createdAt: String,
            objectId: String?,
            externalMessage: String?
        ) {
            self.requestId = requestId
            self.requestType = requestType
            self.status = status
            self.createdAt = createdAt
            self.objectId = objectId
            self.externalMessage = externalMessage
        }
    }
}
