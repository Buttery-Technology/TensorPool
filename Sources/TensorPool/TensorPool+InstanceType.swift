//
//  TensorPool+InstanceType.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

extension TensorPool {
    /// Available GPU and CPU instance types on TensorPool.
    public enum InstanceType: String, Codable, Sendable, CaseIterable {
        // MARK: - NVIDIA B300
        case b300x1 = "1xB300"
        case b300x2 = "2xB300"
        case b300x4 = "4xB300"
        case b300x8 = "8xB300"

        // MARK: - NVIDIA B200
        case b200x1 = "1xB200"
        case b200x2 = "2xB200"
        case b200x4 = "4xB200"
        case b200x8 = "8xB200"

        // MARK: - NVIDIA H200
        case h200x1 = "1xH200"
        case h200x2 = "2xH200"
        case h200x4 = "4xH200"
        case h200x8 = "8xH200"

        // MARK: - NVIDIA H100
        case h100x1 = "1xH100"
        case h100x2 = "2xH100"
        case h100x4 = "4xH100"
        case h100x8 = "8xH100"

        // MARK: - NVIDIA L40S
        case l40sx1 = "1xL40S"

        // MARK: - CPU
        case cpu32 = "32xCPU"
        case cpu64 = "64xCPU"
    }
}
