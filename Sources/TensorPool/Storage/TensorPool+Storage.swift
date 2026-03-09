//
//  TensorPool+Storage.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// Response returned when creating a storage volume.
    public struct StorageCreateResponse: Codable, Sendable {
        /// The unique identifier of the created storage volume.
        public let storageId: String
        /// The request ID for tracking the async operation.
        public let requestId: String?
        /// A human-readable status message.
        public let message: String

        public init(storageId: String, requestId: String?, message: String) {
            self.storageId = storageId
            self.requestId = requestId
            self.message = message
        }
    }

    /// Response returned when listing storage volumes.
    public struct StorageListResponse: Codable, Sendable {
        /// The list of storage volumes.
        public let volumes: [StorageInfo]
        /// A human-readable status message.
        public let message: String

        public init(volumes: [StorageInfo], message: String) {
            self.volumes = volumes
            self.message = message
        }
    }

    /// Response returned when fetching storage volume details.
    public struct StorageInfoResponse: Codable, Sendable {
        /// A human-readable status message.
        public let message: String
        /// The storage volume details.
        public let storageInfo: StorageInfo

        public init(message: String, storageInfo: StorageInfo) {
            self.message = message
            self.storageInfo = storageInfo
        }
    }

    /// Detailed information about a storage volume.
    public struct StorageInfo: Codable, Sendable, Identifiable {
        /// The unique identifier of the storage volume.
        public let id: String?
        /// The name of the storage volume.
        public let name: String?
        /// The size of the storage volume in GB.
        public let sizeGb: Int?
        /// The hourly rate in USD.
        public let hourlyRate: Double?
        /// The cluster IDs this volume is attached to.
        public let attachedClusters: [String]?
        /// Whether deletion protection is enabled.
        public let deletionProtection: Bool?

        public init(
            id: String?,
            name: String?,
            sizeGb: Int?,
            hourlyRate: Double?,
            attachedClusters: [String]?,
            deletionProtection: Bool?
        ) {
            self.id = id
            self.name = name
            self.sizeGb = sizeGb
            self.hourlyRate = hourlyRate
            self.attachedClusters = attachedClusters
            self.deletionProtection = deletionProtection
        }
    }

    /// Response returned when destroying a storage volume.
    public struct StorageDestroyResponse: Codable, Sendable {
        /// The unique identifier of the destroyed storage volume.
        public let storageId: String
        /// The request ID for tracking the async operation.
        public let requestId: String?
        /// A human-readable status message.
        public let message: String

        public init(storageId: String, requestId: String?, message: String) {
            self.storageId = storageId
            self.requestId = requestId
            self.message = message
        }
    }

    /// Response returned when attaching storage to a cluster.
    public struct StorageAttachResponse: Codable, Sendable {
        /// The storage volume ID.
        public let storageId: String
        /// The cluster IDs the storage was attached to.
        public let clusterIds: [String]
        /// The request IDs for tracking each async attach operation.
        public let requestIds: [String]
        /// A human-readable status message.
        public let message: String

        public init(storageId: String, clusterIds: [String], requestIds: [String], message: String) {
            self.storageId = storageId
            self.clusterIds = clusterIds
            self.requestIds = requestIds
            self.message = message
        }
    }

    /// Response returned when detaching storage from a cluster.
    public struct StorageDetachResponse: Codable, Sendable {
        /// The storage volume ID.
        public let storageId: String
        /// The cluster ID the storage was detached from.
        public let clusterId: String
        /// The request ID for tracking the async detach operation.
        public let requestId: String?
        /// A human-readable status message.
        public let message: String

        public init(storageId: String, clusterId: String, requestId: String?, message: String) {
            self.storageId = storageId
            self.clusterId = clusterId
            self.requestId = requestId
            self.message = message
        }
    }
}
