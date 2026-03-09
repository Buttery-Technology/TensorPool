//
//  TensorPoolService.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

/// A protocol defining all operations available on the TensorPool API.
public protocol TensorPoolService: Sendable {

    // MARK: - Authentication

    /// Verify the API token and get authenticated user info.
    func me() async throws -> Data

    // MARK: - Cluster

    /// Create a new GPU cluster.
    ///
    /// - Parameter request: The cluster creation parameters.
    /// - Returns: The cluster creation response with cluster ID and instance IDs.
    func createCluster(_ request: TensorPool.ClusterCreateRequest) async throws -> TensorPool.ClusterCreateResponse

    /// List all clusters.
    ///
    /// - Parameters:
    ///   - includeOrg: Whether to include organization clusters.
    ///   - instances: Whether to include instance details.
    /// - Returns: The cluster list response.
    func listClusters(includeOrg: Bool?, instances: Bool?) async throws -> TensorPool.ClusterListResponse

    /// Get details about a specific cluster.
    ///
    /// - Parameter cluster: The cluster ID or name.
    /// - Returns: The cluster info response.
    func getClusterInfo(_ cluster: String) async throws -> TensorPool.ClusterInfoResponse

    /// Edit a cluster's name or deletion protection.
    ///
    /// - Parameters:
    ///   - cluster: The cluster ID or name.
    ///   - request: The edit parameters.
    /// - Returns: The edit response.
    func editCluster(_ cluster: String, request: TensorPool.ClusterEditRequest) async throws -> TensorPool.EditResponse

    /// Get a pricing quote for a cluster configuration.
    ///
    /// - Parameters:
    ///   - instanceType: The GPU instance type.
    ///   - numNodes: The number of nodes.
    /// - Returns: The pricing quote response.
    func getClusterQuote(instanceType: String, numNodes: Int?) async throws -> TensorPool.QuoteResponse

    /// Destroy a cluster.
    ///
    /// - Parameter cluster: The cluster ID or name.
    /// - Returns: The cluster destroy response.
    func destroyCluster(_ cluster: String) async throws -> TensorPool.ClusterDestroyResponse

    // MARK: - Job

    /// Get an empty TOML job config template.
    func getJobConfigTemplate() async throws -> TensorPool.JobInitResponse

    /// List all jobs.
    ///
    /// - Parameter org: Whether to include organization jobs.
    /// - Returns: The job list response.
    func listJobs(org: Bool?) async throws -> TensorPool.JobListResponse

    /// Get details about a specific job.
    ///
    /// - Parameter jobId: The job ID.
    /// - Returns: The job info response.
    func getJobInfo(_ jobId: String) async throws -> TensorPool.JobInfoResponse

    /// Cancel a running or pending job.
    ///
    /// - Parameter jobId: The job ID.
    /// - Returns: The job cancel response.
    func cancelJob(_ jobId: String) async throws -> TensorPool.JobCancelResponse

    /// Get download URLs or rsync commands for job output files.
    ///
    /// - Parameters:
    ///   - jobId: The job ID.
    ///   - system: The operating system type for rsync commands.
    ///   - privateKeyPath: Optional path to the SSH private key.
    ///   - dryRun: Whether to perform a dry run.
    /// - Returns: The job pull response.
    func pullJobOutput(_ jobId: String, system: TensorPool.SystemType?, privateKeyPath: String?, dryRun: Bool?) async throws -> TensorPool.JobPullResponse

    // MARK: - Storage

    /// Create a new NFS storage volume.
    ///
    /// - Parameter request: The storage creation parameters.
    /// - Returns: The storage creation response.
    func createStorage(_ request: TensorPool.StorageCreateRequest) async throws -> TensorPool.StorageCreateResponse

    /// List all storage volumes.
    ///
    /// - Parameter includeOrg: Whether to include organization storage volumes.
    /// - Returns: The storage list response.
    func listStorage(includeOrg: Bool?) async throws -> TensorPool.StorageListResponse

    /// Get details about a specific storage volume.
    ///
    /// - Parameter storageId: The storage volume ID.
    /// - Returns: The storage info response.
    func getStorageInfo(_ storageId: String) async throws -> TensorPool.StorageInfoResponse

    /// Edit a storage volume's name, size, or deletion protection.
    ///
    /// - Parameters:
    ///   - storageId: The storage volume ID.
    ///   - request: The edit parameters.
    /// - Returns: The edit response.
    func editStorage(_ storageId: String, request: TensorPool.StorageEditRequest) async throws -> TensorPool.EditResponse

    /// Get a pricing quote for a storage volume.
    ///
    /// - Parameter sizeGb: The storage size in GB.
    /// - Returns: The pricing quote response.
    func getStorageQuote(sizeGb: Int) async throws -> TensorPool.QuoteResponse

    /// Attach a storage volume to a cluster.
    ///
    /// - Warning: This will restart all nodes in the target cluster.
    /// - Parameter request: The attach parameters.
    /// - Returns: The attach response.
    func attachStorage(_ request: TensorPool.StorageAttachRequest) async throws -> TensorPool.StorageAttachResponse

    /// Detach a storage volume from a cluster.
    ///
    /// - Warning: This will restart all nodes in the target cluster.
    /// - Parameter request: The detach parameters.
    /// - Returns: The detach response.
    func detachStorage(_ request: TensorPool.StorageDetachRequest) async throws -> TensorPool.StorageDetachResponse

    /// Destroy a storage volume.
    ///
    /// - Parameter storageId: The storage volume ID.
    /// - Returns: The storage destroy response.
    func destroyStorage(_ storageId: String) async throws -> TensorPool.StorageDestroyResponse

    // MARK: - SSH

    /// Get the SSH command for connecting to an instance.
    ///
    /// - Parameters:
    ///   - instanceId: The instance ID.
    ///   - system: The operating system type.
    /// - Returns: The SSH command response.
    func getSSHCommand(instanceId: String, system: TensorPool.SystemType?) async throws -> TensorPool.SSHCommandResponse

    // MARK: - Request Tracking

    /// Poll the status of an async operation.
    ///
    /// - Parameter requestId: The request ID to poll.
    /// - Returns: The request info response.
    func getRequestInfo(_ requestId: String) async throws -> TensorPool.RequestInfoResponse

    // MARK: - User

    /// Get the authenticated user's preferences.
    func getUserPreferences() async throws -> TensorPool.UserPreferences

    /// Update the authenticated user's preferences.
    ///
    /// - Parameter preferences: The preferences to update.
    /// - Returns: The updated preferences.
    func updateUserPreferences(_ preferences: TensorPool.UserPreferences) async throws -> TensorPool.UserPreferences

    /// Get the user's organization info.
    func getOrganizationInfo() async throws -> TensorPool.OrganizationInfo

    /// Add an SSH key to the user's account.
    ///
    /// - Parameter request: The SSH key creation parameters.
    /// - Returns: The SSH key creation response.
    func addSSHKey(_ request: TensorPool.SSHKeyCreateRequest) async throws -> TensorPool.SSHKeyCreateResponse

    /// List the user's SSH keys.
    ///
    /// - Parameter includeOrg: Whether to include organization SSH keys.
    /// - Returns: The SSH key list response.
    func listSSHKeys(includeOrg: Bool?) async throws -> TensorPool.SSHKeyListResponse

    /// Remove an SSH key from the user's account.
    ///
    /// - Parameter keyId: The SSH key ID to remove.
    func removeSSHKey(_ keyId: String) async throws
}
