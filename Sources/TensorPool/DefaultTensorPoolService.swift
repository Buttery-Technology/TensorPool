//
//  DefaultTensorPoolService.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The default implementation of ``TensorPoolService`` using URLSession.
public struct DefaultTensorPoolService: TensorPoolService {
    private let apiToken: String
    private let basePath: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        apiToken: String,
        basePath: String = TensorPool.baseURL,
        session: URLSession = .shared
    ) {
        self.apiToken = apiToken
        self.basePath = basePath
        self.session = session

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    // MARK: - Authentication

    public func me() async throws -> Data {
        let (data, _) = try await perform(.get, endpoint: .me)
        return data
    }

    // MARK: - Cluster

    public func createCluster(_ request: TensorPool.ClusterCreateRequest) async throws -> TensorPool.ClusterCreateResponse {
        try await perform(.post, endpoint: .clusterCreate, body: request)
    }

    public func listClusters(includeOrg: Bool? = nil, instances: Bool? = nil) async throws -> TensorPool.ClusterListResponse {
        var queryItems: [URLQueryItem] = []
        if let includeOrg { queryItems.append(.init(name: "include_org", value: String(includeOrg))) }
        if let instances { queryItems.append(.init(name: "instances", value: String(instances))) }
        return try await perform(.get, endpoint: .clusterList, queryItems: queryItems)
    }

    public func getClusterInfo(_ cluster: String) async throws -> TensorPool.ClusterInfoResponse {
        try await perform(.get, endpoint: .clusterInfo(cluster: cluster))
    }

    public func editCluster(_ cluster: String, request: TensorPool.ClusterEditRequest) async throws -> TensorPool.EditResponse {
        try await perform(.patch, endpoint: .clusterEdit(cluster: cluster), body: request)
    }

    public func getClusterQuote(instanceType: String, numNodes: Int? = nil) async throws -> TensorPool.QuoteResponse {
        var queryItems: [URLQueryItem] = [.init(name: "instance_type", value: instanceType)]
        if let numNodes { queryItems.append(.init(name: "num_nodes", value: String(numNodes))) }
        return try await perform(.get, endpoint: .clusterQuote, queryItems: queryItems)
    }

    public func destroyCluster(_ cluster: String) async throws -> TensorPool.ClusterDestroyResponse {
        try await perform(.delete, endpoint: .clusterDestroy(cluster: cluster))
    }

    // MARK: - Job

    public func getJobConfigTemplate() async throws -> TensorPool.JobInitResponse {
        try await perform(.get, endpoint: .jobInit)
    }

    public func listJobs(org: Bool? = nil) async throws -> TensorPool.JobListResponse {
        var queryItems: [URLQueryItem] = []
        if let org { queryItems.append(.init(name: "org", value: String(org))) }
        return try await perform(.get, endpoint: .jobList, queryItems: queryItems)
    }

    public func getJobInfo(_ jobId: String) async throws -> TensorPool.JobInfoResponse {
        try await perform(.get, endpoint: .jobInfo(jobId: jobId))
    }

    public func cancelJob(_ jobId: String) async throws -> TensorPool.JobCancelResponse {
        try await perform(.post, endpoint: .jobCancel(jobId: jobId))
    }

    public func pullJobOutput(_ jobId: String, system: TensorPool.SystemType? = nil, privateKeyPath: String? = nil, dryRun: Bool? = nil) async throws -> TensorPool.JobPullResponse {
        var queryItems: [URLQueryItem] = []
        if let system { queryItems.append(.init(name: "system", value: system.rawValue)) }
        if let privateKeyPath { queryItems.append(.init(name: "private_key_path", value: privateKeyPath)) }
        if let dryRun { queryItems.append(.init(name: "dry_run", value: String(dryRun))) }
        return try await perform(.get, endpoint: .jobPull(jobId: jobId), queryItems: queryItems)
    }

    // MARK: - Storage

    public func createStorage(_ request: TensorPool.StorageCreateRequest) async throws -> TensorPool.StorageCreateResponse {
        try await perform(.post, endpoint: .storageCreate, body: request)
    }

    public func listStorage(includeOrg: Bool? = nil) async throws -> TensorPool.StorageListResponse {
        var queryItems: [URLQueryItem] = []
        if let includeOrg { queryItems.append(.init(name: "include_org", value: String(includeOrg))) }
        return try await perform(.get, endpoint: .storageList, queryItems: queryItems)
    }

    public func getStorageInfo(_ storageId: String) async throws -> TensorPool.StorageInfoResponse {
        try await perform(.get, endpoint: .storageInfo(storageId: storageId))
    }

    public func editStorage(_ storageId: String, request: TensorPool.StorageEditRequest) async throws -> TensorPool.EditResponse {
        try await perform(.patch, endpoint: .storageEdit(storageId: storageId), body: request)
    }

    public func getStorageQuote(sizeGb: Int) async throws -> TensorPool.QuoteResponse {
        let queryItems: [URLQueryItem] = [.init(name: "size_gb", value: String(sizeGb))]
        return try await perform(.get, endpoint: .storageQuote, queryItems: queryItems)
    }

    public func attachStorage(_ request: TensorPool.StorageAttachRequest) async throws -> TensorPool.StorageAttachResponse {
        try await perform(.post, endpoint: .storageAttach, body: request)
    }

    public func detachStorage(_ request: TensorPool.StorageDetachRequest) async throws -> TensorPool.StorageDetachResponse {
        try await perform(.post, endpoint: .storageDetach, body: request)
    }

    public func destroyStorage(_ storageId: String) async throws -> TensorPool.StorageDestroyResponse {
        try await perform(.delete, endpoint: .storageDestroy(storageId: storageId))
    }

    // MARK: - SSH

    public func getSSHCommand(instanceId: String, system: TensorPool.SystemType? = nil) async throws -> TensorPool.SSHCommandResponse {
        var queryItems: [URLQueryItem] = []
        if let system { queryItems.append(.init(name: "system", value: system.rawValue)) }
        return try await perform(.get, endpoint: .ssh(instanceId: instanceId), queryItems: queryItems)
    }

    // MARK: - Request Tracking

    public func getRequestInfo(_ requestId: String) async throws -> TensorPool.RequestInfoResponse {
        try await perform(.get, endpoint: .requestInfo(requestId: requestId))
    }

    // MARK: - User

    public func getUserPreferences() async throws -> TensorPool.UserPreferences {
        try await perform(.get, endpoint: .userPreferences)
    }

    public func updateUserPreferences(_ preferences: TensorPool.UserPreferences) async throws -> TensorPool.UserPreferences {
        try await perform(.patch, endpoint: .userPreferences, body: preferences)
    }

    public func getOrganizationInfo() async throws -> TensorPool.OrganizationInfo {
        try await perform(.get, endpoint: .organizationInfo)
    }

    public func addSSHKey(_ request: TensorPool.SSHKeyCreateRequest) async throws -> TensorPool.SSHKeyCreateResponse {
        try await perform(.post, endpoint: .sshKeyAdd, body: request)
    }

    public func listSSHKeys(includeOrg: Bool? = nil) async throws -> TensorPool.SSHKeyListResponse {
        var queryItems: [URLQueryItem] = []
        if let includeOrg { queryItems.append(.init(name: "include_org", value: String(includeOrg))) }
        return try await perform(.get, endpoint: .sshKeyList, queryItems: queryItems)
    }

    public func removeSSHKey(_ keyId: String) async throws {
        let _: TensorPool.EditResponse = try await perform(.delete, endpoint: .sshKeyRemove(keyId: keyId))
    }

    // MARK: - Private

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    private func perform<T: Decodable>(
        _ method: HTTPMethod,
        endpoint: TensorPool.API,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        let (data, _) = try await perform(method, endpoint: endpoint, queryItems: queryItems)
        return try decode(data)
    }

    private func perform<T: Decodable, B: Encodable>(
        _ method: HTTPMethod,
        endpoint: TensorPool.API,
        body: B,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        let bodyData = try encode(body)
        let (data, _) = try await perform(method, endpoint: endpoint, body: bodyData, queryItems: queryItems)
        return try decode(data)
    }

    private func perform(
        _ method: HTTPMethod,
        endpoint: TensorPool.API,
        body: Data? = nil,
        queryItems: [URLQueryItem] = []
    ) async throws(TensorPool.APIError) -> (Data, HTTPURLResponse) {
        guard let url = endpoint.url(base: basePath, queryItems: queryItems) else {
            throw .requestFailed(description: "Invalid URL: \(basePath)\(endpoint.path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw .requestFailed(description: error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .requestFailed(description: "Invalid response type")
        }

        try validateResponse(httpResponse, data: data)
        return (data, httpResponse)
    }

    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws(TensorPool.APIError) {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw .unauthorized
        case 402:
            throw .insufficientBalance
        case 403:
            throw .forbidden
        case 404:
            let message = (try? decoder.decode(TensorPool.ErrorResponse.self, from: data))?.detail ?? "Resource not found"
            throw .notFound(message: message)
        case 409:
            let message = (try? decoder.decode(TensorPool.ErrorResponse.self, from: data))?.detail ?? "Conflict"
            throw .conflict(message: message)
        case 422:
            if let validationError = try? decoder.decode(TensorPool.ValidationErrorResponse.self, from: data) {
                throw .validationError(detail: validationError.detail)
            }
            throw .responseUnsuccessful(statusCode: 422, message: "Validation error")
        default:
            let message = (try? decoder.decode(TensorPool.ErrorResponse.self, from: data))?.detail
                ?? (try? decoder.decode(TensorPool.ErrorResponse.self, from: data))?.message
                ?? "Unknown error"
            throw .responseUnsuccessful(statusCode: response.statusCode, message: message)
        }
    }

    private func encode<T: Encodable>(_ value: T) throws(TensorPool.APIError) -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw .encodingFailed(description: error.localizedDescription)
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws(TensorPool.APIError) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .decodingFailed(description: error.localizedDescription)
        }
    }
}
