# Session 13: Storage, HPA, and Probes

## 1. Kubernetes Volumes

Container storage is ephemeral by default—any data written directly inside a container is permanently lost when that container terminates or restarts. Kubernetes **Volumes** solve this by providing a dedicated storage volume attached to the Pod lifecycle.

| Storage Type | Location | Survives Pod Deletion? | Typical Use Cases |
| :--- | :--- | :--- | :--- |
| **`emptyDir`** | Temporary directory created on the host node | ❌ **No** | Scratch space, cache, temporary processing files |
| **`hostPath`** | Specific directory mounted from the host node's filesystem | ✅ **Yes** (on the same host node) | Host-level monitoring tools, single-node local testing |

### Executing an `emptyDir` Pod

![emptyDir Pod Setup](./screenshots/img-1.png)

### Creating Data Inside the Volume

![Writing Data to emptyDir](./screenshots/img-2.png)

### Verifying Ephemeral Nature on Pod Deletion

When the Pod is deleted, the attached `emptyDir` volume is deleted along with it.

![emptyDir Data Loss Verification](./screenshots/img-3.png)

---

## 2. PersistentVolumes (PV) and PersistentVolumeClaims (PVC)

For production applications, storage must persist independently of the Pod lifecycle:

- **PersistentVolume (PV):** A piece of storage in the cluster provisioned by an administrator or dynamically provisioned by a StorageClass.
- **PersistentVolumeClaim (PVC):** A request for storage by a user/Pod. Pods consume PVC resources, not PVs directly.
- **Binding:** When a matching PV satisfies a PVC's requirements, the status updates to `Bound`.
- **Persistence:** Storage outlives the Pod. Deleting a Pod does not erase the underlying PV data.

```text
Pod  ──►  PersistentVolumeClaim (PVC)  ──►  PersistentVolume (PV)  ──►  Physical Storage
```

### Provisioning PV, PVC, and Pod

![PV PVC Pod Provisioning](./screenshots/img-4.png)

### Testing Persistent Storage

![Writing Data to PVC](./screenshots/img-5.png)

### Verifying Persistence Across Pod Lifecycle

Deleting the Pod leaves the underlying PV intact. A new Pod attached to the same PVC retains full access to the stored data.

![Data Persistence Verification](./screenshots/img-6.png)

---

## 3. StorageClass & Dynamic Provisioning

- A **StorageClass** provides a way for administrators to describe the "classes" of storage they offer.
- It enables **Dynamic Provisioning**: when a PVC specifies a StorageClass, a matching PV is created automatically on demand.
- Minikube provides a default StorageClass named `standard`.
- PVCs created without an explicit `storageClassName` default to the cluster's default StorageClass.

```text
PVC Created  ──►  StorageClass Intercepts  ──►  PV Provisioned Dynamically  ──►  PVC Bound
```

### Inspecting StorageClasses in Cluster

![Check StorageClasses](./screenshots/img-7.png)

### Dynamic PVC Binding

![Dynamic Provisioning Verification](./screenshots/img-8.png)

---

## 4. Horizontal Pod Autoscaler (HPA)

The **Horizontal Pod Autoscaler (HPA)** automatically updates a workload resource (like a Deployment) to scale out or scale in matching demand based on targeted metrics (e.g., CPU utilization).

- **Prerequisites:** Requires the **Metrics Server** running in the cluster and explicit `resources.requests.cpu` defined on container specs.
- **Scaling Behavior:** Scale-out occurs rapidly upon load spikes, whereas scale-in includes a stabilization window (~5 minutes) to prevent flapping.

### Deploying Workload & Service

![HPA Target Deployment and Service](./screenshots/img-9.png)

### Verifying Metrics Server Availability

![Metrics Server Status](./screenshots/img-10.png)

### Configuring the HPA Resource

![Create HPA Rule](./screenshots/img-11.png)

### Simulating CPU Load

![HPA Load Generation](./screenshots/img-12.png)

### Observing Scale-In After Load Relates

![HPA Scale Down](./screenshots/img-13.png)

---

## 5. Container Health Probes

A Pod reported as `Running` by Kubernetes only guarantees the container process started, not that the application inside is functional. **Probes** perform active diagnostic checks on the containerized app.

| Probe Type | Primary Responsibility | Action On Failure |
| :--- | :--- | :--- |
| **Startup Probe** | Verifies if the container application has fully booted up. | Kubelet kills container and enforces restart policy. |
| **Readiness Probe** | Verifies if the container is ready to accept user network traffic. | Pod IP removed from matching Service Endpoints (no restart). |
| **Liveness Probe** | Verifies if the container application is still healthy and running. | Kubelet kills container and triggers restart. |

### Liveness Probe Configuration

![Liveness Probe Setup](./screenshots/img-14.png)

### Readiness Probe Configuration

![Readiness Probe Setup](./screenshots/img-15.png)

### Startup Probe Configuration

![Startup Probe Setup](./screenshots/img-16.png)

### Simulating Readiness Failure

![Breaking Readiness Probe](./screenshots/img-17.png)

### Simulating Liveness Failure

![Breaking Liveness Probe](./screenshots/img-18.png)

---

## 6. Mini Project: End-to-End Production Setup

Deploying a resilient web application in the `production-webapp` namespace combining persistent storage, automatic scaling, and health monitoring.

| Module | Implementation Specifications |
| :--- | :--- |
| **Storage** | PVC `web-data`, requesting `500Mi`, mounted at path `/data` |
| **Scaling** | HPA scaling between 2 to 5 replicas target at 50% CPU threshold |
| **Health Check** | Integrated Startup, Readiness, and Liveness probes |

### Applying Deployment Spec

![Mini Project Deployment](./screenshots/img-19.png)

### Confirming Storage Persistence

![Mini Project Storage Persistence](./screenshots/img-20.png)

### Validating Service Endpoints

![Mini Project Service Endpoints](./screenshots/img-21.png)

### Testing HPA Auto-Scaling Under Load

![Mini Project HPA Scaling](./screenshots/img-22.png)

---

## Summary & Key Takeaways

- **`emptyDir` vs PVC:** `emptyDir` lifecycle is tied to the Pod, whereas **PVCs** ensure data outlives Pod restarts and deletions.
- **Dynamic Storage:** **StorageClass** automates PV creation, eliminating manual volume administration.
- **Automated Scaling:** **HPA** dynamically adjusts replica counts based on real-time CPU/memory metrics.
- **Traffic vs Restarts:** **Readiness probes** manage traffic routing at the Service level, while **Liveness/Startup probes** govern container lifecycle restarts.