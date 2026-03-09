import Foundation
import Testing
@testable import TensorPool

// MARK: - Model Tests

@Suite("Instance Types")
struct InstanceTypeTests {

    @Test("All GPU instance types have correct raw values")
    func gpuInstanceTypeRawValues() {
        #expect(TensorPool.InstanceType.b300x1.rawValue == "1xB300")
        #expect(TensorPool.InstanceType.b300x2.rawValue == "2xB300")
        #expect(TensorPool.InstanceType.b300x4.rawValue == "4xB300")
        #expect(TensorPool.InstanceType.b300x8.rawValue == "8xB300")
        #expect(TensorPool.InstanceType.b200x1.rawValue == "1xB200")
        #expect(TensorPool.InstanceType.b200x2.rawValue == "2xB200")
        #expect(TensorPool.InstanceType.b200x4.rawValue == "4xB200")
        #expect(TensorPool.InstanceType.b200x8.rawValue == "8xB200")
        #expect(TensorPool.InstanceType.h200x1.rawValue == "1xH200")
        #expect(TensorPool.InstanceType.h200x2.rawValue == "2xH200")
        #expect(TensorPool.InstanceType.h200x4.rawValue == "4xH200")
        #expect(TensorPool.InstanceType.h200x8.rawValue == "8xH200")
        #expect(TensorPool.InstanceType.h100x1.rawValue == "1xH100")
        #expect(TensorPool.InstanceType.h100x2.rawValue == "2xH100")
        #expect(TensorPool.InstanceType.h100x4.rawValue == "4xH100")
        #expect(TensorPool.InstanceType.h100x8.rawValue == "8xH100")
        #expect(TensorPool.InstanceType.l40sx1.rawValue == "1xL40S")
    }

    @Test("CPU instance types have correct raw values")
    func cpuInstanceTypeRawValues() {
        #expect(TensorPool.InstanceType.cpu32.rawValue == "32xCPU")
        #expect(TensorPool.InstanceType.cpu64.rawValue == "64xCPU")
    }

    @Test("All instance types are iterable via CaseIterable")
    func instanceTypeCaseIterable() {
        #expect(TensorPool.InstanceType.allCases.count == 19)
    }

    @Test("Instance types round-trip through JSON")
    func instanceTypeJSONRoundTrip() throws {
        for instanceType in TensorPool.InstanceType.allCases {
            let data = try JSONEncoder().encode(instanceType)
            let decoded = try JSONDecoder().decode(TensorPool.InstanceType.self, from: data)
            #expect(decoded == instanceType)
        }
    }
}

// MARK: - Job Status Tests

@Suite("Job Status")
struct JobStatusTests {

    @Test("Terminal states are identified correctly")
    func terminalStates() {
        let terminal: [TensorPool.JobStatus] = [.completed, .error, .failed, .canceled]
        let nonTerminal: [TensorPool.JobStatus] = [.pending, .running, .canceling]

        for status in terminal {
            #expect(status.isTerminal, "Expected \(status) to be terminal")
        }
        for status in nonTerminal {
            #expect(!status.isTerminal, "Expected \(status) to NOT be terminal")
        }
    }

    @Test("Job status decodes from JSON strings")
    func jobStatusDecoding() throws {
        let cases: [(String, TensorPool.JobStatus)] = [
            ("\"pending\"", .pending),
            ("\"running\"", .running),
            ("\"completed\"", .completed),
            ("\"error\"", .error),
            ("\"failed\"", .failed),
            ("\"canceling\"", .canceling),
            ("\"canceled\"", .canceled),
        ]
        for (json, expected) in cases {
            let decoded = try JSONDecoder().decode(TensorPool.JobStatus.self, from: Data(json.utf8))
            #expect(decoded == expected)
        }
    }
}

// MARK: - Request Status Tests

@Suite("Request Status")
struct RequestStatusTests {

    @Test("Terminal states are identified correctly")
    func terminalStates() {
        #expect(TensorPool.RequestStatus.completed.isTerminal)
        #expect(TensorPool.RequestStatus.failed.isTerminal)
        #expect(!TensorPool.RequestStatus.pending.isTerminal)
        #expect(!TensorPool.RequestStatus.processing.isTerminal)
        #expect(!TensorPool.RequestStatus.retrying.isTerminal)
    }

    @Test("Request type decodes from uppercase JSON strings")
    func requestTypeDecoding() throws {
        let cases: [(String, TensorPool.RequestType)] = [
            ("\"CLUSTER_CLAIM\"", .clusterClaim),
            ("\"CLUSTER_RELEASE\"", .clusterRelease),
            ("\"CLUSTER_EDIT\"", .clusterEdit),
            ("\"STORAGE_CREATE\"", .storageCreate),
            ("\"STORAGE_DESTROY\"", .storageDestroy),
            ("\"STORAGE_ATTACH\"", .storageAttach),
            ("\"STORAGE_DETACH\"", .storageDetach),
            ("\"STORAGE_EDIT\"", .storageEdit),
        ]
        for (json, expected) in cases {
            let decoded = try JSONDecoder().decode(TensorPool.RequestType.self, from: Data(json.utf8))
            #expect(decoded == expected)
        }
    }

    @Test("Request status decodes from uppercase JSON strings")
    func requestStatusDecoding() throws {
        let cases: [(String, TensorPool.RequestStatus)] = [
            ("\"PENDING\"", .pending),
            ("\"PROCESSING\"", .processing),
            ("\"RETRYING\"", .retrying),
            ("\"COMPLETED\"", .completed),
            ("\"FAILED\"", .failed),
        ]
        for (json, expected) in cases {
            let decoded = try JSONDecoder().decode(TensorPool.RequestStatus.self, from: Data(json.utf8))
            #expect(decoded == expected)
        }
    }
}

// MARK: - Cluster Model Tests

@Suite("Cluster Models")
struct ClusterModelTests {

    @Test("ClusterCreateRequest encodes with snake_case keys")
    func createRequestEncoding() throws {
        let request = TensorPool.ClusterCreateRequest(
            instanceType: .h100x8,
            numNodes: 2,
            clusterName: "my-cluster",
            publicKeys: ["ssh-rsa AAAA..."],
            deletionProtection: true,
            saveKeys: false
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["instance_type"] as? String == "8xH100")
        #expect(json["num_nodes"] as? Int == 2)
        #expect(json["tp_cluster_name"] as? String == "my-cluster")
        #expect((json["public_keys"] as? [String])?.first == "ssh-rsa AAAA...")
        #expect(json["deletion_protection"] as? Bool == true)
        #expect(json["save_keys"] as? Bool == false)
    }

    @Test("ClusterCreateRequest with raw string instance type")
    func createRequestRawInstanceType() throws {
        let request = TensorPool.ClusterCreateRequest(instanceType: "custom-gpu")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["instance_type"] as? String == "custom-gpu")
    }

    @Test("ClusterCreateRequest encodes nil values as absent keys")
    func createRequestOmitsNils() throws {
        let request = TensorPool.ClusterCreateRequest(instanceType: .h100x1)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["instance_type"] as? String == "1xH100")
        #expect(json["num_nodes"] == nil)
        #expect(json["tp_cluster_name"] == nil)
        #expect(json["public_keys"] == nil)
    }

    @Test("ClusterCreateResponse decodes from snake_case JSON")
    func createResponseDecoding() throws {
        let json = """
        {
            "cluster_id": "c-abc123",
            "instance_ids": ["i-001", "i-002", "i-003"],
            "request_id": "r-xyz789",
            "message": "Cluster creation initiated"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.ClusterCreateResponse.self, from: Data(json.utf8))

        #expect(response.clusterId == "c-abc123")
        #expect(response.instanceIds == ["i-001", "i-002", "i-003"])
        #expect(response.requestId == "r-xyz789")
        #expect(response.message == "Cluster creation initiated")
    }

    @Test("ClusterCreateResponse decodes with null request_id")
    func createResponseNullRequestId() throws {
        let json = """
        {
            "cluster_id": "c-abc123",
            "instance_ids": ["i-001"],
            "request_id": null,
            "message": "Done"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.ClusterCreateResponse.self, from: Data(json.utf8))

        #expect(response.requestId == nil)
    }

    @Test("ClusterDestroyResponse decodes correctly")
    func destroyResponseDecoding() throws {
        let json = """
        {"cluster_id": "c-del", "request_id": "r-del", "message": "Destroying"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.ClusterDestroyResponse.self, from: Data(json.utf8))

        #expect(response.clusterId == "c-del")
        #expect(response.requestId == "r-del")
    }

    @Test("ClusterListResponse decodes with empty clusters array")
    func listResponseEmpty() throws {
        let json = """
        {"clusters": [], "message": "No clusters found"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.ClusterListResponse.self, from: Data(json.utf8))

        #expect(response.clusters.isEmpty)
        #expect(response.message == "No clusters found")
    }

    @Test("ClusterInfo decodes with all fields")
    func clusterInfoDecoding() throws {
        let json = """
        {
            "id": "c-full",
            "name": "training-cluster",
            "instance_type": "8xH100",
            "instances": [{"id": "i-1", "status": "running"}, {"id": "i-2", "status": "pending"}],
            "storage": ["s-001"],
            "deletion_protection": true
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let info = try decoder.decode(TensorPool.ClusterInfo.self, from: Data(json.utf8))

        #expect(info.id == "c-full")
        #expect(info.name == "training-cluster")
        #expect(info.instanceType == "8xH100")
        #expect(info.instances?.count == 2)
        #expect(info.instances?.first?.status == "running")
        #expect(info.storage == ["s-001"])
        #expect(info.deletionProtection == true)
    }

    @Test("ClusterEditRequest encodes correctly")
    func editRequestEncoding() throws {
        let request = TensorPool.ClusterEditRequest(clusterName: "renamed", deletionProtection: false)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["tp_cluster_name"] as? String == "renamed")
        #expect(json["deletion_protection"] as? Bool == false)
    }

    @Test("QuoteResponse decodes hourly rate")
    func quoteResponseDecoding() throws {
        let json = """
        {"hourly_rate": 32.50}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.QuoteResponse.self, from: Data(json.utf8))

        #expect(response.hourlyRate == 32.50)
    }
}

// MARK: - Job Model Tests

@Suite("Job Models")
struct JobModelTests {

    @Test("JobInfoResponse decodes with all fields")
    func jobInfoResponseDecoding() throws {
        let json = """
        {
            "message": "Job details",
            "job_info": {
                "id": "j-abc",
                "status": "completed",
                "exit_code": 0
            }
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.JobInfoResponse.self, from: Data(json.utf8))

        #expect(response.jobInfo.id == "j-abc")
        #expect(response.jobInfo.status == .completed)
        #expect(response.jobInfo.exitCode == 0)
    }

    @Test("JobInfo decodes with null optional fields")
    func jobInfoNullFields() throws {
        let json = """
        {"id": null, "status": null, "exit_code": null}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let info = try decoder.decode(TensorPool.JobInfo.self, from: Data(json.utf8))

        #expect(info.id == nil)
        #expect(info.status == nil)
        #expect(info.exitCode == nil)
    }

    @Test("JobCancelResponse decodes correctly")
    func jobCancelResponseDecoding() throws {
        let json = """
        {"job_id": "j-cancel", "message": "Job canceling", "status": "canceling"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.JobCancelResponse.self, from: Data(json.utf8))

        #expect(response.jobId == "j-cancel")
        #expect(response.status == "canceling")
    }

    @Test("JobPullResponse decodes with download map")
    func jobPullResponseWithDownloadMap() throws {
        let json = """
        {
            "message": "Download ready",
            "download_map": {"output/model.bin": "https://s3.example.com/signed-url", "output/log.txt": null},
            "command": null,
            "command_show_stdout": null
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.JobPullResponse.self, from: Data(json.utf8))

        #expect(response.downloadMap?.count == 2)
        #expect(response.downloadMap?["output/model.bin"] == "https://s3.example.com/signed-url")
        #expect(response.command == nil)
    }

    @Test("JobPullResponse decodes with rsync command")
    func jobPullResponseWithRsync() throws {
        let json = """
        {
            "message": "Use rsync",
            "download_map": null,
            "command": "rsync -avz user@host:/output/ ./local/",
            "command_show_stdout": true
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.JobPullResponse.self, from: Data(json.utf8))

        #expect(response.command == "rsync -avz user@host:/output/ ./local/")
        #expect(response.commandShowStdout == true)
        #expect(response.downloadMap == nil)
    }

    @Test("JobListResponse decodes with multiple jobs")
    func jobListResponseDecoding() throws {
        let json = """
        {
            "jobs": [
                {"id": "j-1", "status": "running", "exit_code": null},
                {"id": "j-2", "status": "completed", "exit_code": 0},
                {"id": "j-3", "status": "failed", "exit_code": 1}
            ],
            "message": "3 jobs found"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.JobListResponse.self, from: Data(json.utf8))

        #expect(response.jobs.count == 3)
        #expect(response.jobs[0].status == .running)
        #expect(response.jobs[1].exitCode == 0)
        #expect(response.jobs[2].status == .failed)
    }

    @Test("SystemType raw values match API expectations")
    func systemTypeRawValues() {
        #expect(TensorPool.SystemType.windows.rawValue == "windows")
        #expect(TensorPool.SystemType.linux.rawValue == "linux")
        #expect(TensorPool.SystemType.darwin.rawValue == "darwin")
    }
}

// MARK: - Storage Model Tests

@Suite("Storage Models")
struct StorageModelTests {

    @Test("StorageCreateRequest encodes correctly")
    func createRequestEncoding() throws {
        let request = TensorPool.StorageCreateRequest(
            sizeGb: 500,
            storageName: "training-data",
            deletionProtection: true
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["size_gb"] as? Int == 500)
        #expect(json["tp_storage_name"] as? String == "training-data")
        #expect(json["deletion_protection"] as? Bool == true)
    }

    @Test("StorageEditRequest encodes only provided fields")
    func editRequestEncoding() throws {
        let request = TensorPool.StorageEditRequest(sizeGb: 1000)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["size_gb"] as? Int == 1000)
        #expect(json["tp_storage_name"] == nil)
        #expect(json["deletion_protection"] == nil)
    }

    @Test("StorageAttachRequest encodes correctly")
    func attachRequestEncoding() throws {
        let request = TensorPool.StorageAttachRequest(storageId: "s-abc", clusterIds: ["c-xyz"])

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["storage_id"] as? String == "s-abc")
        #expect((json["cluster_ids"] as? [String]) == ["c-xyz"])
    }

    @Test("StorageDetachRequest encodes correctly")
    func detachRequestEncoding() throws {
        let request = TensorPool.StorageDetachRequest(storageId: "s-abc", clusterId: "c-xyz")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["storage_id"] as? String == "s-abc")
        #expect(json["cluster_id"] as? String == "c-xyz")
    }

    @Test("StorageCreateResponse decodes correctly")
    func createResponseDecoding() throws {
        let json = """
        {"storage_id": "s-new", "request_id": "r-new", "message": "Creating"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.StorageCreateResponse.self, from: Data(json.utf8))

        #expect(response.storageId == "s-new")
        #expect(response.requestId == "r-new")
    }

    @Test("StorageInfo decodes with all fields")
    func storageInfoDecoding() throws {
        let json = """
        {
            "id": "s-full",
            "name": "datasets",
            "size_gb": 250,
            "hourly_rate": 0.12,
            "attached_clusters": ["c-1", "c-2"],
            "deletion_protection": false
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let info = try decoder.decode(TensorPool.StorageInfo.self, from: Data(json.utf8))

        #expect(info.id == "s-full")
        #expect(info.name == "datasets")
        #expect(info.sizeGb == 250)
        #expect(info.hourlyRate == 0.12)
        #expect(info.attachedClusters?.count == 2)
        #expect(info.deletionProtection == false)
    }

    @Test("StorageAttachResponse decodes correctly")
    func attachResponseDecoding() throws {
        let json = """
        {
            "storage_id": "s-abc",
            "cluster_ids": ["c-xyz"],
            "request_ids": ["r-attach"],
            "message": "Attaching"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.StorageAttachResponse.self, from: Data(json.utf8))

        #expect(response.storageId == "s-abc")
        #expect(response.clusterIds == ["c-xyz"])
        #expect(response.requestIds == ["r-attach"])
    }

    @Test("StorageDetachResponse decodes correctly")
    func detachResponseDecoding() throws {
        let json = """
        {"storage_id": "s-abc", "cluster_id": "c-xyz", "request_id": "r-detach", "message": "Detaching"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.StorageDetachResponse.self, from: Data(json.utf8))

        #expect(response.storageId == "s-abc")
        #expect(response.clusterId == "c-xyz")
        #expect(response.requestId == "r-detach")
    }

    @Test("StorageDestroyResponse decodes correctly")
    func destroyResponseDecoding() throws {
        let json = """
        {"storage_id": "s-gone", "request_id": null, "message": "Destroyed"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.StorageDestroyResponse.self, from: Data(json.utf8))

        #expect(response.storageId == "s-gone")
        #expect(response.requestId == nil)
    }
}

// MARK: - User Model Tests

@Suite("User Models")
struct UserModelTests {

    @Test("UserPreferences encodes and decodes correctly")
    func preferencesRoundTrip() throws {
        let prefs = TensorPool.UserPreferences(
            notifyEmailClusterCreate: true,
            notifyEmailClusterDestroy: false,
            autopayEnabled: true,
            balanceWarningThreshold: 100.0,
            autopayReloadThreshold: 20.0
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(prefs)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(TensorPool.UserPreferences.self, from: data)

        #expect(decoded.notifyEmailClusterCreate == true)
        #expect(decoded.notifyEmailClusterDestroy == false)
        #expect(decoded.autopayEnabled == true)
        #expect(decoded.balanceWarningThreshold == 100.0)
        #expect(decoded.autopayReloadThreshold == 20.0)
    }

    @Test("UserPreferences with partial fields")
    func preferencesPartial() throws {
        let json = """
        {"notify_email_cluster_create": true}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let prefs = try decoder.decode(TensorPool.UserPreferences.self, from: Data(json.utf8))

        #expect(prefs.notifyEmailClusterCreate == true)
        #expect(prefs.autopayEnabled == nil)
    }

    @Test("OrganizationInfo decodes correctly")
    func orgInfoDecoding() throws {
        let json = """
        {
            "org_name": "Buttery AI",
            "members": [
                {"uid": "u-001", "email": "alice@example.com"},
                {"uid": "u-002", "email": "bob@example.com"}
            ],
            "balance": 1500.75
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let info = try decoder.decode(TensorPool.OrganizationInfo.self, from: Data(json.utf8))

        #expect(info.orgName == "Buttery AI")
        #expect(info.members.count == 2)
        #expect(info.members[0].email == "alice@example.com")
        #expect(info.balance == 1500.75)
    }

    @Test("SSHKeyCreateRequest encodes correctly")
    func sshKeyCreateRequestEncoding() throws {
        let request = TensorPool.SSHKeyCreateRequest(publicKey: "ssh-ed25519 AAAA...", name: "my-key")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["public_key"] as? String == "ssh-ed25519 AAAA...")
        #expect(json["name"] as? String == "my-key")
    }

    @Test("SSHKeyCreateRequest without name omits it")
    func sshKeyCreateRequestNoName() throws {
        let request = TensorPool.SSHKeyCreateRequest(publicKey: "ssh-rsa key")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] == nil)
    }

    @Test("SSHKeyListResponse decodes correctly")
    func sshKeyListDecoding() throws {
        let json = """
        {
            "keys": [
                {"id": "k-1", "name": "work-laptop", "public_key": "ssh-rsa ..."},
                {"id": "k-2", "name": null, "public_key": "ssh-ed25519 ..."}
            ],
            "message": "2 keys"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.SSHKeyListResponse.self, from: Data(json.utf8))

        #expect(response.keys.count == 2)
        #expect(response.keys[0].name == "work-laptop")
        #expect(response.keys[1].name == nil)
    }

    @Test("SSHKeyCreateResponse decodes correctly")
    func sshKeyCreateResponseDecoding() throws {
        let json = """
        {"key_id": "k-new", "message": "Key added"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.SSHKeyCreateResponse.self, from: Data(json.utf8))

        #expect(response.keyId == "k-new")
    }
}

// MARK: - Request Tracking Model Tests

@Suite("Request Tracking Models")
struct RequestTrackingTests {

    @Test("RequestInfoResponse decodes fully")
    func requestInfoDecoding() throws {
        let json = """
        {
            "request_id": "r-track",
            "request_type": "CLUSTER_CLAIM",
            "status": "PROCESSING",
            "created_at": "2026-03-08T12:00:00Z",
            "object_id": "c-target",
            "external_message": "Provisioning GPU nodes"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.RequestInfoResponse.self, from: Data(json.utf8))

        #expect(response.requestId == "r-track")
        #expect(response.requestType == .clusterClaim)
        #expect(response.status == .processing)
        #expect(response.createdAt == "2026-03-08T12:00:00Z")
        #expect(response.objectId == "c-target")
        #expect(response.externalMessage == "Provisioning GPU nodes")
    }

    @Test("RequestInfoResponse decodes with null optional fields")
    func requestInfoNullOptionals() throws {
        let json = """
        {
            "request_id": "r-min",
            "request_type": "STORAGE_CREATE",
            "status": "PENDING",
            "created_at": "2026-03-08T12:00:00Z",
            "object_id": null,
            "external_message": null
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.RequestInfoResponse.self, from: Data(json.utf8))

        #expect(response.objectId == nil)
        #expect(response.externalMessage == nil)
    }
}

// MARK: - SSH Model Tests

@Suite("SSH Models")
struct SSHModelTests {

    @Test("SSHCommandResponse decodes correctly")
    func sshCommandDecoding() throws {
        let json = """
        {"command": "ssh -i ~/.ssh/id_rsa root@10.0.0.1"}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(TensorPool.SSHCommandResponse.self, from: Data(json.utf8))

        #expect(response.command == "ssh -i ~/.ssh/id_rsa root@10.0.0.1")
    }
}

// MARK: - API Endpoint Tests

@Suite("API Endpoints")
struct APIEndpointTests {

    @Test("Cluster endpoint paths")
    func clusterPaths() {
        #expect(TensorPool.API.clusterCreate.path == "/cluster/create")
        #expect(TensorPool.API.clusterList.path == "/cluster/list")
        #expect(TensorPool.API.clusterInfo(cluster: "my-cluster").path == "/cluster/info/my-cluster")
        #expect(TensorPool.API.clusterEdit(cluster: "c-123").path == "/cluster/edit/c-123")
        #expect(TensorPool.API.clusterQuote.path == "/cluster/quote")
        #expect(TensorPool.API.clusterDestroy(cluster: "c-del").path == "/cluster/c-del")
    }

    @Test("Job endpoint paths")
    func jobPaths() {
        #expect(TensorPool.API.jobInit.path == "/job/init")
        #expect(TensorPool.API.jobList.path == "/job/list")
        #expect(TensorPool.API.jobInfo(jobId: "j-100").path == "/job/info/j-100")
        #expect(TensorPool.API.jobCancel(jobId: "j-200").path == "/job/cancel/j-200")
        #expect(TensorPool.API.jobPull(jobId: "j-300").path == "/job/pull/j-300")
    }

    @Test("Storage endpoint paths")
    func storagePaths() {
        #expect(TensorPool.API.storageCreate.path == "/storage/create")
        #expect(TensorPool.API.storageList.path == "/storage/list")
        #expect(TensorPool.API.storageInfo(storageId: "s-info").path == "/storage/info/s-info")
        #expect(TensorPool.API.storageEdit(storageId: "s-edit").path == "/storage/edit/s-edit")
        #expect(TensorPool.API.storageQuote.path == "/storage/quote")
        #expect(TensorPool.API.storageAttach.path == "/storage/attach")
        #expect(TensorPool.API.storageDetach.path == "/storage/detach")
        #expect(TensorPool.API.storageDestroy(storageId: "s-del").path == "/storage/s-del")
    }

    @Test("User endpoint paths")
    func userPaths() {
        #expect(TensorPool.API.me.path == "/me")
        #expect(TensorPool.API.userPreferences.path == "/user/preferences")
        #expect(TensorPool.API.organizationInfo.path == "/user/organization/info")
        #expect(TensorPool.API.sshKeyAdd.path == "/user/ssh-key/add")
        #expect(TensorPool.API.sshKeyList.path == "/user/ssh-key/list")
        #expect(TensorPool.API.sshKeyRemove(keyId: "k-rm").path == "/user/ssh-key/remove/k-rm")
    }

    @Test("SSH and request tracking endpoint paths")
    func miscPaths() {
        #expect(TensorPool.API.ssh(instanceId: "i-ssh").path == "/ssh/i-ssh")
        #expect(TensorPool.API.requestInfo(requestId: "r-poll").path == "/request/info/r-poll")
    }

    @Test("URL construction with base URL")
    func urlConstruction() {
        let url = TensorPool.API.clusterCreate.url()
        #expect(url?.absoluteString == "https://engine.tensorpool.dev/cluster/create")
    }

    @Test("URL construction with custom base URL")
    func urlConstructionCustomBase() {
        let url = TensorPool.API.me.url(base: "http://localhost:8080")
        #expect(url?.absoluteString == "http://localhost:8080/me")
    }

    @Test("URL construction with query items")
    func urlWithQueryItems() {
        let url = TensorPool.API.clusterList.url(queryItems: [
            URLQueryItem(name: "include_org", value: "true"),
            URLQueryItem(name: "instances", value: "true"),
        ])
        let urlString = url?.absoluteString ?? ""
        #expect(urlString.contains("include_org=true"))
        #expect(urlString.contains("instances=true"))
    }

    @Test("URL construction without query items omits question mark")
    func urlWithoutQueryItems() {
        let url = TensorPool.API.me.url()
        #expect(url?.absoluteString.contains("?") == false)
    }
}

// MARK: - Error Tests

@Suite("API Errors")
struct APIErrorTests {

    @Test("All error cases produce non-empty display descriptions")
    func allErrorDescriptions() {
        let errors: [TensorPool.APIError] = [
            .requestFailed(description: "timeout"),
            .responseUnsuccessful(statusCode: 500, message: "internal"),
            .unauthorized,
            .forbidden,
            .notFound(message: "gone"),
            .insufficientBalance,
            .conflict(message: "protected"),
            .validationError(detail: [
                TensorPool.ValidationErrorDetail(loc: ["body"], msg: "required", type: "value_error")
            ]),
            .decodingFailed(description: "bad json"),
            .encodingFailed(description: "unencodable"),
        ]

        for error in errors {
            #expect(!error.displayDescription.isEmpty)
        }
    }

    @Test("Error descriptions contain relevant information")
    func errorDescriptionContent() {
        let requestFailed = TensorPool.APIError.requestFailed(description: "Connection refused")
        #expect(requestFailed.displayDescription.contains("Connection refused"))

        let responseError = TensorPool.APIError.responseUnsuccessful(statusCode: 503, message: "Service unavailable")
        #expect(responseError.displayDescription.contains("503"))
        #expect(responseError.displayDescription.contains("Service unavailable"))

        let insufficientBalance = TensorPool.APIError.insufficientBalance
        #expect(insufficientBalance.displayDescription.contains("balance"))

        let forbidden = TensorPool.APIError.forbidden
        #expect(forbidden.displayDescription.contains("Forbidden"))

        let conflict = TensorPool.APIError.conflict(message: "Deletion protection is enabled")
        #expect(conflict.displayDescription.contains("Deletion protection"))

        let encoding = TensorPool.APIError.encodingFailed(description: "circular reference")
        #expect(encoding.displayDescription.contains("circular reference"))

        let decoding = TensorPool.APIError.decodingFailed(description: "missing key")
        #expect(decoding.displayDescription.contains("missing key"))
    }

    @Test("ValidationErrorDetail round-trips through JSON")
    func validationDetailRoundTrip() throws {
        let detail = TensorPool.ValidationErrorDetail(
            loc: ["body", "instance_type"],
            msg: "field required",
            type: "value_error.missing"
        )

        let data = try JSONEncoder().encode(detail)
        let decoded = try JSONDecoder().decode(TensorPool.ValidationErrorDetail.self, from: data)

        #expect(decoded.loc == ["body", "instance_type"])
        #expect(decoded.msg == "field required")
        #expect(decoded.type == "value_error.missing")
    }

    @Test("ErrorResponse decodes with detail field")
    func errorResponseWithDetail() throws {
        let json = """
        {"detail": "Not found", "message": null}
        """
        let response = try JSONDecoder().decode(TensorPool.ErrorResponse.self, from: Data(json.utf8))
        #expect(response.detail == "Not found")
        #expect(response.message == nil)
    }

    @Test("ErrorResponse decodes with message field")
    func errorResponseWithMessage() throws {
        let json = """
        {"detail": null, "message": "Something went wrong"}
        """
        let response = try JSONDecoder().decode(TensorPool.ErrorResponse.self, from: Data(json.utf8))
        #expect(response.detail == nil)
        #expect(response.message == "Something went wrong")
    }

    @Test("ValidationErrorResponse decodes array of details")
    func validationErrorResponseDecoding() throws {
        let json = """
        {
            "detail": [
                {"loc": ["body", "instance_type"], "msg": "field required", "type": "value_error"},
                {"loc": ["body", "num_nodes"], "msg": "must be positive", "type": "value_error"}
            ]
        }
        """
        let response = try JSONDecoder().decode(TensorPool.ValidationErrorResponse.self, from: Data(json.utf8))
        #expect(response.detail.count == 2)
        #expect(response.detail[0].msg == "field required")
        #expect(response.detail[1].loc == ["body", "num_nodes"])
    }
}

// MARK: - Service Factory Tests

@Suite("Service Factory")
struct ServiceFactoryTests {

    @Test("Factory creates DefaultTensorPoolService")
    func createsDefaultService() {
        let service = TensorPool.ServiceFactory.service(apiToken: "test-token")
        #expect(service is DefaultTensorPoolService)
    }

    @Test("Factory accepts custom base path")
    func customBasePath() {
        let service = TensorPool.ServiceFactory.service(
            apiToken: "token",
            basePath: "http://localhost:9090"
        )
        #expect(service is DefaultTensorPoolService)
    }

    @Test("Factory accepts custom URLSession")
    func customSession() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        let session = URLSession(configuration: config)

        let service = TensorPool.ServiceFactory.service(
            apiToken: "token",
            session: session
        )
        #expect(service is DefaultTensorPoolService)
    }
}

// MARK: - Base URL Test

@Suite("TensorPool Namespace")
struct TensorPoolNamespaceTests {

    @Test("Base URL is correct")
    func baseURL() {
        #expect(TensorPool.baseURL == "https://engine.tensorpool.dev")
    }
}
