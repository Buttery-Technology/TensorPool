//
//  TensorPool+ClusterRequest.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

extension TensorPool {
    /// Request body for creating a new GPU cluster.
    public struct ClusterCreateRequest: Codable, Sendable {
        /// The GPU instance type to provision. See ``InstanceType`` for available options.
        public let instanceType: String
        /// The number of nodes to provision. Defaults to 1.
        public let numNodes: Int?
        /// An optional name for the cluster.
        public let tpClusterName: String?
        /// SSH public keys to install on the cluster nodes.
        public let publicKeys: [String]?
        /// An optional container image to use.
        public let experimentalContainer: String?
        /// Whether to enable deletion protection. Defaults to false.
        public let deletionProtection: Bool?
        /// Whether to save SSH keys for future use. Defaults to true.
        public let saveKeys: Bool?

        /// Create a new cluster creation request.
        ///
        /// - Parameters:
        ///   - instanceType: The GPU instance type to provision.
        ///   - numNodes: The number of nodes to provision. Defaults to 1.
        ///   - clusterName: An optional name for the cluster.
        ///   - publicKeys: SSH public keys to install on the cluster nodes.
        ///   - experimentalContainer: An optional container image to use.
        ///   - deletionProtection: Whether to enable deletion protection.
        ///   - saveKeys: Whether to save SSH keys for future use.
        public init(
            instanceType: InstanceType,
            numNodes: Int? = nil,
            clusterName: String? = nil,
            publicKeys: [String]? = nil,
            experimentalContainer: String? = nil,
            deletionProtection: Bool? = nil,
            saveKeys: Bool? = nil
        ) {
            self.instanceType = instanceType.rawValue
            self.numNodes = numNodes
            self.tpClusterName = clusterName
            self.publicKeys = publicKeys
            self.experimentalContainer = experimentalContainer
            self.deletionProtection = deletionProtection
            self.saveKeys = saveKeys
        }

        /// Create a new cluster creation request with a raw instance type string.
        ///
        /// - Parameters:
        ///   - instanceType: The GPU instance type string (e.g., "8xH100").
        ///   - numNodes: The number of nodes to provision. Defaults to 1.
        ///   - clusterName: An optional name for the cluster.
        ///   - publicKeys: SSH public keys to install on the cluster nodes.
        ///   - experimentalContainer: An optional container image to use.
        ///   - deletionProtection: Whether to enable deletion protection.
        ///   - saveKeys: Whether to save SSH keys for future use.
        public init(
            instanceType: String,
            numNodes: Int? = nil,
            clusterName: String? = nil,
            publicKeys: [String]? = nil,
            experimentalContainer: String? = nil,
            deletionProtection: Bool? = nil,
            saveKeys: Bool? = nil
        ) {
            self.instanceType = instanceType
            self.numNodes = numNodes
            self.tpClusterName = clusterName
            self.publicKeys = publicKeys
            self.experimentalContainer = experimentalContainer
            self.deletionProtection = deletionProtection
            self.saveKeys = saveKeys
        }
    }

    /// Request body for editing a cluster.
    public struct ClusterEditRequest: Codable, Sendable {
        /// The new name for the cluster.
        public let tpClusterName: String?
        /// Whether to enable deletion protection.
        public let deletionProtection: Bool?

        public init(clusterName: String? = nil, deletionProtection: Bool? = nil) {
            self.tpClusterName = clusterName
            self.deletionProtection = deletionProtection
        }
    }
}
