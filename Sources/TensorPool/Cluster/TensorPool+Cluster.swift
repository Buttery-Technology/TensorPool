//
//  TensorPool+Cluster.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// Response returned when creating a new GPU cluster.
    public struct ClusterCreateResponse: Codable, Sendable {
        /// The unique identifier of the created cluster.
        public let clusterId: String
        /// The instance IDs provisioned for this cluster.
        public let instanceIds: [String]
        /// The request ID for tracking the async provisioning operation.
        public let requestId: String?
        /// A human-readable status message.
        public let message: String

        public init(clusterId: String, instanceIds: [String], requestId: String?, message: String) {
            self.clusterId = clusterId
            self.instanceIds = instanceIds
            self.requestId = requestId
            self.message = message
        }
    }

    /// Response returned when destroying a cluster.
    public struct ClusterDestroyResponse: Codable, Sendable {
        /// The unique identifier of the destroyed cluster.
        public let clusterId: String
        /// The request ID for tracking the async destroy operation.
        public let requestId: String?
        /// A human-readable status message.
        public let message: String

        public init(clusterId: String, requestId: String?, message: String) {
            self.clusterId = clusterId
            self.requestId = requestId
            self.message = message
        }
    }

    /// Response returned when listing clusters.
    public struct ClusterListResponse: Codable, Sendable {
        /// The list of clusters.
        public let clusters: [ClusterInfo]
        /// A human-readable status message.
        public let message: String

        public init(clusters: [ClusterInfo], message: String) {
            self.clusters = clusters
            self.message = message
        }
    }

    /// Response returned when fetching cluster details.
    public struct ClusterInfoResponse: Codable, Sendable {
        /// A human-readable status message.
        public let message: String
        /// The cluster details.
        public let clusterInfo: ClusterInfo

        public init(message: String, clusterInfo: ClusterInfo) {
            self.message = message
            self.clusterInfo = clusterInfo
        }
    }

    /// Detailed information about a cluster.
    public struct ClusterInfo: Codable, Sendable, Identifiable {
        /// The unique identifier of the cluster.
        public let id: String?
        /// The cluster name.
        public let name: String?
        /// The instance type used by this cluster.
        public let instanceType: String?
        /// The instances belonging to this cluster.
        public let instances: [InstanceInfo]?
        /// Attached storage volumes.
        public let storage: [String]?
        /// Whether deletion protection is enabled.
        public let deletionProtection: Bool?

        public init(
            id: String?,
            name: String?,
            instanceType: String?,
            instances: [InstanceInfo]?,
            storage: [String]?,
            deletionProtection: Bool?
        ) {
            self.id = id
            self.name = name
            self.instanceType = instanceType
            self.instances = instances
            self.storage = storage
            self.deletionProtection = deletionProtection
        }
    }

    /// Information about a single instance within a cluster.
    public struct InstanceInfo: Codable, Sendable, Identifiable {
        public let id: String?
        public let status: String?

        public init(id: String?, status: String?) {
            self.id = id
            self.status = status
        }
    }

    /// Response returned when editing a cluster.
    public struct EditResponse: Codable, Sendable {
        /// A human-readable status message.
        public let message: String

        public init(message: String) {
            self.message = message
        }
    }

    /// Response returned when requesting a pricing quote.
    public struct QuoteResponse: Codable, Sendable {
        /// The hourly rate in USD.
        public let hourlyRate: Double

        public init(hourlyRate: Double) {
            self.hourlyRate = hourlyRate
        }
    }
}
