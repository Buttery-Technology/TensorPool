//
//  TensorPool+SSH.swift
//  TensorPool
//
//  Created by Jonathan Holland on 3/8/26.
//

extension TensorPool {
    /// Response returned when requesting an SSH command for an instance.
    public struct SSHCommandResponse: Codable, Sendable {
        /// The SSH command to connect to the instance.
        public let command: String

        public init(command: String) {
            self.command = command
        }
    }
}
