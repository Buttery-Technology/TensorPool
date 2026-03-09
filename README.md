# TensorPool

A pure Swift client for the [TensorPool](https://tensorpool.dev) GPU cloud platform API. Provision GPU clusters, manage jobs, attach NFS storage, and track async operations — all from Swift.

## Requirements

- Swift 6.1+
- macOS 14+ / iOS 17+

## Installation

### Swift Package Manager

Add TensorPool as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(path: "../TensorPool"),
    // or from a remote URL:
    // .package(url: "https://github.com/your-org/TensorPool.git", from: "1.0.0"),
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["TensorPool"]
),
```

## Quick Start

```swift
import TensorPool

// 1. Create a service with your API token
let service = TensorPool.ServiceFactory.service(
    apiToken: "your-api-token"  // From https://tensorpool.dev/dashboard/api-key
)

// 2. Verify authentication
let userData = try await service.me()

// 3. Create a GPU cluster
let cluster = try await service.createCluster(
    .init(instanceType: .h100x8, clusterName: "training-run")
)
print("Cluster ID: \(cluster.clusterId)")

// 4. Poll until provisioned
var status = try await service.getRequestInfo(cluster.requestId!)
while !status.status.isTerminal {
    try await Task.sleep(for: .seconds(10))
    status = try await service.getRequestInfo(cluster.requestId!)
}
```

## Authentication

TensorPool uses Bearer token authentication. Generate your API token from the [TensorPool Dashboard](https://tensorpool.dev/dashboard/api-key).

```swift
let service = TensorPool.ServiceFactory.service(apiToken: "your-token")

// Verify your token is valid
let me = try await service.me()
```

The token is automatically included as `Authorization: Bearer <token>` on every request.

## API Reference

### Clusters

GPU clusters are the core compute resource. Each cluster provisions one or more GPU nodes.

#### Available Instance Types

```swift
// NVIDIA B300
TensorPool.InstanceType.b300x1  // "1xB300"
TensorPool.InstanceType.b300x8  // "8xB300"

// NVIDIA B200
TensorPool.InstanceType.b200x1  // "1xB200"
TensorPool.InstanceType.b200x8  // "8xB200" (multi-node capable)

// NVIDIA H200
TensorPool.InstanceType.h200x1  // "1xH200"
TensorPool.InstanceType.h200x8  // "8xH200" (multi-node capable)

// NVIDIA H100
TensorPool.InstanceType.h100x1  // "1xH100"
TensorPool.InstanceType.h100x8  // "8xH100"

// NVIDIA L40S
TensorPool.InstanceType.l40sx1  // "1xL40S"

// CPU
TensorPool.InstanceType.cpu32   // "32xCPU"
TensorPool.InstanceType.cpu64   // "64xCPU"
```

#### Create a Cluster

```swift
let response = try await service.createCluster(.init(
    instanceType: .h100x8,
    numNodes: 2,                          // Optional, defaults to 1
    clusterName: "my-training-cluster",   // Optional
    publicKeys: ["ssh-rsa AAAA..."],      // Optional SSH keys
    deletionProtection: true,             // Optional
    saveKeys: true                        // Optional, defaults to true
))

print("Cluster: \(response.clusterId)")
print("Instances: \(response.instanceIds)")
print("Track with: \(response.requestId ?? "immediate")")
```

#### List Clusters

```swift
// List your clusters
let clusters = try await service.listClusters(includeOrg: nil, instances: nil)

// Include organization clusters and instance details
let allClusters = try await service.listClusters(includeOrg: true, instances: true)

for cluster in allClusters.clusters {
    print("\(cluster.name ?? "unnamed") - \(cluster.instanceType ?? "unknown")")
}
```

#### Get Cluster Details

```swift
let info = try await service.getClusterInfo("c-abc123")
// or by name:
let info = try await service.getClusterInfo("my-cluster")

print("Instances: \(info.clusterInfo.instances?.count ?? 0)")
print("Protected: \(info.clusterInfo.deletionProtection ?? false)")
```

#### Edit a Cluster

```swift
let result = try await service.editCluster("c-abc123", request: .init(
    clusterName: "renamed-cluster",
    deletionProtection: true
))
```

#### Get a Pricing Quote

```swift
let quote = try await service.getClusterQuote(
    instanceType: TensorPool.InstanceType.h100x8.rawValue,
    numNodes: 4
)
print("Hourly rate: $\(quote.hourlyRate)")
```

#### Destroy a Cluster

```swift
let result = try await service.destroyCluster("c-abc123")
// Track the destroy operation
if let requestId = result.requestId {
    let status = try await service.getRequestInfo(requestId)
}
```

### Jobs

Jobs represent compute tasks running on your clusters.

#### Get Job Config Template

```swift
let template = try await service.getJobConfigTemplate()
print(template.config ?? "No template")
```

#### List Jobs

```swift
let jobs = try await service.listJobs(org: nil)

// Include organization jobs
let allJobs = try await service.listJobs(org: true)

for job in allJobs.jobs {
    print("\(job.id ?? "?") - \(job.status?.rawValue ?? "unknown")")
}
```

#### Get Job Details

```swift
let jobInfo = try await service.getJobInfo("j-abc123")
print("Status: \(jobInfo.jobInfo.status?.rawValue ?? "unknown")")
print("Exit code: \(jobInfo.jobInfo.exitCode.map(String.init) ?? "N/A")")
```

#### Cancel a Job

```swift
let cancelResult = try await service.cancelJob("j-abc123")
print("New status: \(cancelResult.status)")
```

#### Pull Job Output

For **completed** jobs, you get presigned S3 download URLs. For **running** jobs, you get an rsync command.

```swift
// Get output for a completed job
let output = try await service.pullJobOutput(
    "j-abc123",
    system: .darwin,         // Optional: windows, linux, darwin
    privateKeyPath: nil,     // Optional: SSH key path for rsync
    dryRun: nil              // Optional: preview without downloading
)

if let downloadMap = output.downloadMap {
    for (file, url) in downloadMap {
        print("\(file) -> \(url ?? "unavailable")")
    }
}

if let rsyncCommand = output.command {
    print("Run: \(rsyncCommand)")
}
```

#### Checking Job Terminal States

```swift
let status = jobInfo.jobInfo.status
if status?.isTerminal == true {
    // Job is done: .completed, .error, .failed, or .canceled
} else {
    // Job is still active: .pending, .running, or .canceling
}
```

### Storage (NFS)

Persistent NFS storage volumes that can be attached to clusters.

#### Create Storage

```swift
let storage = try await service.createStorage(.init(
    sizeGb: 500,
    storageName: "training-datasets",
    deletionProtection: true
))
print("Storage ID: \(storage.storageId)")
```

#### List Storage

```swift
let volumes = try await service.listStorage(includeOrg: true)
for vol in volumes.volumes {
    print("\(vol.name ?? "unnamed") - \(vol.sizeGb ?? 0) GB")
}
```

#### Get Storage Details

```swift
let info = try await service.getStorageInfo("s-abc123")
print("Size: \(info.storageInfo.sizeGb ?? 0) GB")
print("Rate: $\(info.storageInfo.hourlyRate ?? 0)/hr")
print("Attached to: \(info.storageInfo.attachedClusters ?? [])")
```

#### Edit Storage

Storage can only be expanded, not shrunk.

```swift
let result = try await service.editStorage("s-abc123", request: .init(
    storageName: "new-name",        // Optional
    sizeGb: 1000,                   // Optional, expand only
    deletionProtection: true        // Optional
))
```

#### Get Storage Pricing

```swift
let quote = try await service.getStorageQuote(sizeGb: 500)
print("Hourly rate: $\(quote.hourlyRate)")
```

#### Attach Storage to Cluster

> **Warning:** Attaching storage will restart all nodes in the target cluster.

```swift
let result = try await service.attachStorage(.init(
    storageId: "s-abc123",
    clusterIds: ["c-xyz789"]    // Max 1 cluster
))
```

#### Detach Storage from Cluster

> **Warning:** Detaching storage will restart all nodes in the target cluster.

```swift
let result = try await service.detachStorage(.init(
    storageId: "s-abc123",
    clusterId: "c-xyz789"
))
```

#### Destroy Storage

```swift
let result = try await service.destroyStorage("s-abc123")
```

### SSH

Get SSH commands for connecting to cluster instances.

```swift
let ssh = try await service.getSSHCommand(
    instanceId: "i-abc123",
    system: .darwin      // Optional: .windows, .linux, .darwin
)
print("Connect with: \(ssh.command)")
// e.g., "ssh -i ~/.ssh/id_rsa root@10.0.0.1"
```

### Request Tracking

Many operations (cluster creation, storage attach, etc.) are asynchronous. Use request tracking to poll their status.

```swift
let cluster = try await service.createCluster(.init(instanceType: .h100x8))

// Poll until the operation completes
if let requestId = cluster.requestId {
    var info = try await service.getRequestInfo(requestId)

    while !info.status.isTerminal {
        // The API suggests a Retry-After interval, but a 10s default works well
        try await Task.sleep(for: .seconds(10))
        info = try await service.getRequestInfo(requestId)
        print("Status: \(info.status.rawValue) - \(info.externalMessage ?? "")")
    }

    switch info.status {
    case .completed:
        print("Operation completed! Object: \(info.objectId ?? "N/A")")
    case .failed:
        print("Operation failed: \(info.externalMessage ?? "Unknown error")")
    default:
        break
    }
}
```

#### Request Types

| Type | Description |
|------|-------------|
| `CLUSTER_CLAIM` | Cluster creation |
| `CLUSTER_RELEASE` | Cluster destruction |
| `CLUSTER_EDIT` | Cluster edit operation |
| `STORAGE_CREATE` | Storage volume creation |
| `STORAGE_DESTROY` | Storage volume destruction |
| `STORAGE_ATTACH` | Storage attachment to cluster |
| `STORAGE_DETACH` | Storage detachment from cluster |
| `STORAGE_EDIT` | Storage volume edit |

#### Request Statuses

| Status | Terminal | Description |
|--------|----------|-------------|
| `PENDING` | No | Queued for processing |
| `PROCESSING` | No | Currently being processed |
| `RETRYING` | No | Retrying after a transient failure |
| `COMPLETED` | Yes | Successfully completed |
| `FAILED` | Yes | Failed permanently |

### User & Organization

#### Get/Update Preferences

```swift
// Get current preferences
let prefs = try await service.getUserPreferences()
print("Autopay: \(prefs.autopayEnabled ?? false)")

// Update preferences
let updated = try await service.updateUserPreferences(.init(
    notifyEmailClusterCreate: true,
    notifyEmailClusterDestroy: true,
    autopayEnabled: false,
    balanceWarningThreshold: 100.0,
    autopayReloadThreshold: 20.0
))
```

#### Organization Info

```swift
let org = try await service.getOrganizationInfo()
print("Org: \(org.orgName)")
print("Balance: $\(org.balance)")
for member in org.members {
    print("  \(member.email)")
}
```

#### SSH Key Management

```swift
// Add a key
let keyResult = try await service.addSSHKey(.init(
    publicKey: "ssh-ed25519 AAAA...",
    name: "work-laptop"              // Optional
))
print("Key ID: \(keyResult.keyId)")

// List keys
let keys = try await service.listSSHKeys(includeOrg: true)
for key in keys.keys {
    print("\(key.name ?? "unnamed") - \(key.id ?? "?")")
}

// Remove a key
try await service.removeSSHKey("k-abc123")
```

## Error Handling

All API errors are thrown as `TensorPool.APIError` with specific cases for each HTTP error type:

```swift
do {
    let cluster = try await service.createCluster(.init(instanceType: .h100x8))
} catch let error as TensorPool.APIError {
    switch error {
    case .unauthorized:
        print("Check your API token")
    case .insufficientBalance:
        print("Add funds at https://tensorpool.dev/dashboard")
    case .forbidden:
        print("You don't have permission for this operation")
    case .notFound(let message):
        print("Resource not found: \(message)")
    case .conflict(let message):
        print("Conflict: \(message)")  // e.g., deletion protection enabled
    case .validationError(let details):
        for detail in details {
            print("Field \(detail.loc.joined(separator: ".")): \(detail.msg)")
        }
    case .responseUnsuccessful(let code, let message):
        print("HTTP \(code): \(message)")
    case .requestFailed(let description):
        print("Network error: \(description)")
    case .decodingFailed(let description):
        print("Response parsing error: \(description)")
    case .encodingFailed(let description):
        print("Request encoding error: \(description)")
    }

    // Or use the convenience property:
    print(error.displayDescription)
}
```

## Advanced Configuration

### Custom Base URL

For testing or self-hosted deployments:

```swift
let service = TensorPool.ServiceFactory.service(
    apiToken: "token",
    basePath: "http://localhost:8080"
)
```

### Custom URLSession

```swift
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30
config.timeoutIntervalForResource = 120
let session = URLSession(configuration: config)

let service = TensorPool.ServiceFactory.service(
    apiToken: "token",
    session: session
)
```

### Protocol-Based Mocking

The `TensorPoolService` protocol makes it easy to create mock implementations for testing:

```swift
struct MockTensorPoolService: TensorPoolService {
    func me() async throws -> Data { Data() }

    func createCluster(_ request: TensorPool.ClusterCreateRequest) async throws -> TensorPool.ClusterCreateResponse {
        .init(clusterId: "mock-cluster", instanceIds: ["mock-i-1"], requestId: nil, message: "Mock created")
    }

    // ... implement remaining protocol methods
}
```

## Architecture

The package follows the Composable Architecture Pattern (CAP) used across the Buttery monorepo:

```
TensorPool (namespace enum)
├── InstanceType              # GPU/CPU instance type enum
├── APIError                  # Typed error cases
├── API                       # Endpoint path definitions
├── ServiceFactory            # Static factory for creating services
├── Cluster models            # ClusterCreateRequest/Response, ClusterInfo, etc.
├── Job models                # JobInfo, JobStatus, JobPullResponse, etc.
├── Storage models            # StorageCreateRequest/Response, StorageInfo, etc.
├── User models               # UserPreferences, OrganizationInfo, SSHKey*, etc.
├── Request models            # RequestInfoResponse, RequestType, RequestStatus
└── SSH models                # SSHCommandResponse

TensorPoolService (protocol)  # Defines all API operations
DefaultTensorPoolService      # URLSession-based implementation
```

## Running Tests

```bash
cd TensorPool
swift test
```

All tests run offline against serialized JSON fixtures — no API token or network access required.
