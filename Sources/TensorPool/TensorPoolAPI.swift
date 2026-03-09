//
//  TensorPoolAPI.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// Defines all TensorPool API endpoints.
    enum API {
        // MARK: - Cluster
        case clusterCreate
        case clusterList
        case clusterInfo(cluster: String)
        case clusterEdit(cluster: String)
        case clusterQuote
        case clusterDestroy(cluster: String)

        // MARK: - Job
        case jobInit
        case jobList
        case jobInfo(jobId: String)
        case jobCancel(jobId: String)
        case jobPull(jobId: String)

        // MARK: - Storage
        case storageCreate
        case storageList
        case storageInfo(storageId: String)
        case storageEdit(storageId: String)
        case storageQuote
        case storageAttach
        case storageDetach
        case storageDestroy(storageId: String)

        // MARK: - SSH
        case ssh(instanceId: String)

        // MARK: - Request Tracking
        case requestInfo(requestId: String)

        // MARK: - User
        case me
        case userPreferences
        case organizationInfo
        case sshKeyAdd
        case sshKeyList
        case sshKeyRemove(keyId: String)

        /// The HTTP path for this endpoint.
        var path: String {
            switch self {
            case .clusterCreate:
                return "/cluster/create"
            case .clusterList:
                return "/cluster/list"
            case .clusterInfo(let cluster):
                return "/cluster/info/\(cluster)"
            case .clusterEdit(let cluster):
                return "/cluster/edit/\(cluster)"
            case .clusterQuote:
                return "/cluster/quote"
            case .clusterDestroy(let cluster):
                return "/cluster/\(cluster)"
            case .jobInit:
                return "/job/init"
            case .jobList:
                return "/job/list"
            case .jobInfo(let jobId):
                return "/job/info/\(jobId)"
            case .jobCancel(let jobId):
                return "/job/cancel/\(jobId)"
            case .jobPull(let jobId):
                return "/job/pull/\(jobId)"
            case .storageCreate:
                return "/storage/create"
            case .storageList:
                return "/storage/list"
            case .storageInfo(let storageId):
                return "/storage/info/\(storageId)"
            case .storageEdit(let storageId):
                return "/storage/edit/\(storageId)"
            case .storageQuote:
                return "/storage/quote"
            case .storageAttach:
                return "/storage/attach"
            case .storageDetach:
                return "/storage/detach"
            case .storageDestroy(let storageId):
                return "/storage/\(storageId)"
            case .ssh(let instanceId):
                return "/ssh/\(instanceId)"
            case .requestInfo(let requestId):
                return "/request/info/\(requestId)"
            case .me:
                return "/me"
            case .userPreferences:
                return "/user/preferences"
            case .organizationInfo:
                return "/user/organization/info"
            case .sshKeyAdd:
                return "/user/ssh-key/add"
            case .sshKeyList:
                return "/user/ssh-key/list"
            case .sshKeyRemove(let keyId):
                return "/user/ssh-key/remove/\(keyId)"
            }
        }

        /// The full URL for this endpoint.
        func url(base: String = TensorPool.baseURL, queryItems: [URLQueryItem] = []) -> URL? {
            var components = URLComponents(string: base + path)
            if !queryItems.isEmpty {
                components?.queryItems = queryItems
            }
            return components?.url
        }
    }
}
