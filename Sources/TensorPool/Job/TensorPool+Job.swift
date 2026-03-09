//
//  TensorPool+Job.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

import Foundation

extension TensorPool {
    /// The possible states of a TensorPool job.
    public enum JobStatus: String, Codable, Sendable {
        case pending
        case running
        case completed
        case error
        case failed
        case canceling
        case canceled

        /// Whether this is a terminal state that will not change.
        public var isTerminal: Bool {
            switch self {
            case .completed, .error, .failed, .canceled:
                return true
            case .pending, .running, .canceling:
                return false
            }
        }
    }

    /// Response returned when listing jobs.
    public struct JobListResponse: Codable, Sendable {
        /// The list of jobs.
        public let jobs: [JobInfo]
        /// A human-readable status message.
        public let message: String

        public init(jobs: [JobInfo], message: String) {
            self.jobs = jobs
            self.message = message
        }
    }

    /// Response returned when fetching job details.
    public struct JobInfoResponse: Codable, Sendable {
        /// A human-readable status message.
        public let message: String
        /// The job details.
        public let jobInfo: JobInfo

        public init(message: String, jobInfo: JobInfo) {
            self.message = message
            self.jobInfo = jobInfo
        }
    }

    /// Detailed information about a job.
    public struct JobInfo: Codable, Sendable, Identifiable {
        /// The unique identifier of the job.
        public let id: String?
        /// The current status of the job.
        public let status: JobStatus?
        /// The exit code of the job, if completed.
        public let exitCode: Int?

        public init(id: String?, status: JobStatus?, exitCode: Int?) {
            self.id = id
            self.status = status
            self.exitCode = exitCode
        }
    }

    /// Response returned when canceling a job.
    public struct JobCancelResponse: Codable, Sendable {
        /// The unique identifier of the canceled job.
        public let jobId: String
        /// A human-readable status message.
        public let message: String
        /// The new status of the job.
        public let status: String

        public init(jobId: String, message: String, status: String) {
            self.jobId = jobId
            self.message = message
            self.status = status
        }
    }

    /// The operating system type for SSH/pull commands.
    public enum SystemType: String, Codable, Sendable {
        case windows
        case linux
        case darwin
    }

    /// Response returned when pulling job output files.
    public struct JobPullResponse: Codable, Sendable {
        /// A human-readable status message.
        public let message: String
        /// A map of file paths to presigned S3 download URLs (for completed jobs).
        public let downloadMap: [String: String?]?
        /// An rsync command for downloading files from a running job.
        public let command: String?
        /// Whether to display stdout from the rsync command.
        public let commandShowStdout: Bool?

        public init(message: String, downloadMap: [String: String?]?, command: String?, commandShowStdout: Bool?) {
            self.message = message
            self.downloadMap = downloadMap
            self.command = command
            self.commandShowStdout = commandShowStdout
        }
    }

    /// Response returned when requesting a job config template.
    public struct JobInitResponse: Codable, Sendable {
        /// The TOML configuration template.
        public let config: String?
        /// A human-readable status message.
        public let message: String?

        public init(config: String?, message: String?) {
            self.config = config
            self.message = message
        }
    }
}
