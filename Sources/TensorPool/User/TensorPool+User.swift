//
//  TensorPool+User.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// User preferences for notifications and billing.
    public struct UserPreferences: Codable, Sendable {
        /// Whether to receive email notifications when a cluster is created.
        public let notifyEmailClusterCreate: Bool?
        /// Whether to receive email notifications when a cluster is destroyed.
        public let notifyEmailClusterDestroy: Bool?
        /// Whether autopay is enabled for automatic balance reloading.
        public let autopayEnabled: Bool?
        /// The balance threshold at which to send a warning notification.
        public let balanceWarningThreshold: Double?
        /// The balance threshold at which to automatically reload funds.
        public let autopayReloadThreshold: Double?

        public init(
            notifyEmailClusterCreate: Bool? = nil,
            notifyEmailClusterDestroy: Bool? = nil,
            autopayEnabled: Bool? = nil,
            balanceWarningThreshold: Double? = nil,
            autopayReloadThreshold: Double? = nil
        ) {
            self.notifyEmailClusterCreate = notifyEmailClusterCreate
            self.notifyEmailClusterDestroy = notifyEmailClusterDestroy
            self.autopayEnabled = autopayEnabled
            self.balanceWarningThreshold = balanceWarningThreshold
            self.autopayReloadThreshold = autopayReloadThreshold
        }
    }

    /// Information about the user's organization.
    public struct OrganizationInfo: Codable, Sendable {
        /// The organization name.
        public let orgName: String
        /// The organization members.
        public let members: [OrganizationMember]
        /// The current account balance in USD.
        public let balance: Double

        public init(orgName: String, members: [OrganizationMember], balance: Double) {
            self.orgName = orgName
            self.members = members
            self.balance = balance
        }
    }

    /// A member of an organization.
    public struct OrganizationMember: Codable, Sendable {
        /// The user's unique identifier.
        public let uid: String
        /// The user's email address.
        public let email: String

        public init(uid: String, email: String) {
            self.uid = uid
            self.email = email
        }
    }

    /// Response returned when creating an SSH key.
    public struct SSHKeyCreateResponse: Codable, Sendable {
        /// The unique identifier of the created SSH key.
        public let keyId: String
        /// A human-readable status message.
        public let message: String

        public init(keyId: String, message: String) {
            self.keyId = keyId
            self.message = message
        }
    }

    /// Response returned when listing SSH keys.
    public struct SSHKeyListResponse: Codable, Sendable {
        /// The list of SSH keys.
        public let keys: [SSHKeyInfo]
        /// A human-readable status message.
        public let message: String

        public init(keys: [SSHKeyInfo], message: String) {
            self.keys = keys
            self.message = message
        }
    }

    /// Information about an SSH key.
    public struct SSHKeyInfo: Codable, Sendable, Identifiable {
        /// The unique identifier of the SSH key.
        public let id: String?
        /// The name of the SSH key.
        public let name: String?
        /// The public key string.
        public let publicKey: String?

        public init(id: String?, name: String?, publicKey: String?) {
            self.id = id
            self.name = name
            self.publicKey = publicKey
        }
    }

    /// Request body for creating an SSH key.
    public struct SSHKeyCreateRequest: Codable, Sendable {
        /// The SSH public key string.
        public let publicKey: String
        /// An optional name for the key.
        public let name: String?

        public init(publicKey: String, name: String? = nil) {
            self.publicKey = publicKey
            self.name = name
        }
    }
}
