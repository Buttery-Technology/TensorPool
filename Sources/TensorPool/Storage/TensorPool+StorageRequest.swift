//
//  TensorPool+StorageRequest.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

extension TensorPool {
    /// Request body for creating a new storage volume.
    public struct StorageCreateRequest: Codable, Sendable {
        /// The size of the storage volume in GB. Minimum 1.
        public let sizeGb: Int
        /// An optional name for the storage volume.
        public let tpStorageName: String?
        /// Whether to enable deletion protection.
        public let deletionProtection: Bool?

        public init(sizeGb: Int, storageName: String? = nil, deletionProtection: Bool? = nil) {
            self.sizeGb = sizeGb
            self.tpStorageName = storageName
            self.deletionProtection = deletionProtection
        }
    }

    /// Request body for editing a storage volume.
    public struct StorageEditRequest: Codable, Sendable {
        /// The new name for the storage volume.
        public let tpStorageName: String?
        /// The new size in GB. Can only expand, not shrink.
        public let sizeGb: Int?
        /// Whether to enable deletion protection.
        public let deletionProtection: Bool?

        public init(storageName: String? = nil, sizeGb: Int? = nil, deletionProtection: Bool? = nil) {
            self.tpStorageName = storageName
            self.sizeGb = sizeGb
            self.deletionProtection = deletionProtection
        }
    }

    /// Request body for attaching storage to a cluster.
    ///
    /// - Warning: Attaching storage will restart all nodes in the target cluster.
    public struct StorageAttachRequest: Codable, Sendable {
        /// The storage volume ID. Must start with "s-".
        public let storageId: String
        /// The cluster IDs to attach to. Maximum 1 cluster.
        public let clusterIds: [String]

        public init(storageId: String, clusterIds: [String]) {
            self.storageId = storageId
            self.clusterIds = clusterIds
        }
    }

    /// Request body for detaching storage from a cluster.
    ///
    /// - Warning: Detaching storage will restart all nodes in the target cluster.
    public struct StorageDetachRequest: Codable, Sendable {
        /// The storage volume ID. Must start with "s-".
        public let storageId: String
        /// The cluster ID to detach from.
        public let clusterId: String

        public init(storageId: String, clusterId: String) {
            self.storageId = storageId
            self.clusterId = clusterId
        }
    }
}
