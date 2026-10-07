# Session 14: Kubernetes Troubleshooting Framework

Effective Kubernetes troubleshooting relies on a structured, systematic methodology rather than executing random commands. Follow this standardized diagnostic pipeline:

```text
kubectl get ──► kubectl describe ──► Check Events ──► Inspect Logs ──► Exec Shell ──► Identify Fix ──► Verify Resolution
```

---

## 1. `kubectl get` — Instant Cluster State

`kubectl get` provides an immediate high-level summary of your resources. Focus primary attention on the **`STATUS`**, **`READY`**, and **`RESTARTS`** columns.

### Listing Pods & Extended Wide Metadata

![kubectl get pods wide output](./Screenshots/img-1.png)

### Inspecting Other Cluster Resources

![kubectl get other resources](./Screenshots/img-2.png)

### Watching Real-Time State Transitions

![kubectl get watch mode](./Screenshots/img-3.png)

---

## 2. `kubectl describe` — Deep Resource Diagnostics

`kubectl describe` reveals **why** a resource is in a specific state. Key sections to inspect include container **`State`**, **`Conditions`**, and **`Events`** at the bottom of the output.

![kubectl describe output](./Screenshots/img-4.png)

---

## 3. `kubectl logs` — Application Execution Output

Inspect standard output (`stdout`) and standard error (`stderr`) generated directly by containerized applications.

- **`-f` (follow):** Streams live log output.
- **`--previous`:** Fetches logs from the previously terminated/crashed container instance.
- **`-c <container_name>`:** Targets a specific container inside a multi-container Pod.

![kubectl logs command](./Screenshots/img-5.png)

---

## 4. `kubectl exec` — In-Pod Diagnostics

Executes commands directly inside a running container to test network connectivity, environment variables, or local files.

> ⚠️ **Note:** `exec` requires a running container. It cannot be used on pods stuck in `CrashLoopBackOff` or `Pending` states.

### Interactive Shell Access

![kubectl exec interactive shell](./Screenshots/img-6.png)

### One-Off Command Execution

![kubectl exec direct command](./Screenshots/img-7.png)

---

## 5. Kubernetes Events

Events record significant cluster activities—such as scheduling decisions, image pulling attempts, and container restarts. Events are retained for approximately 1 hour.

### Listing Cluster Events

![Listing Cluster Events](./Screenshots/img-8.png)

### Viewing Events via `describe` & `kubectl events`

![Events in describe output](./Screenshots/img-9.png)

---

## 6. Debugging `CrashLoopBackOff`

`CrashLoopBackOff` indicates that a container starts, encounters a failure, exits, and Kubernetes continuously attempts to restart it with an exponential delay. It is a symptom—the root cause must be identified via `kubectl logs`.

### Identifying Broken Pod State

![CrashLoopBackOff Pod State](./Screenshots/img-10.png)

### Extracting Crash Logs

![Logs showing exit code 1](./Screenshots/img-11.png)

### Applying Fix & Verifying Resolution

![Fixed Pod running state](./Screenshots/img-12.png)

---

## 7. Debugging `ImagePullBackOff` / `ErrImagePull`

Occurs when Kubernetes cannot pull the specified container image due to invalid image names, non-existent tags, registry authentication failures, or network issues.

### Inspecting Image Pull Error

![ImagePullBackOff error](./Screenshots/img-13.png)

### Resolving Image Tag & Deploying Fix

![ImagePullBackOff resolved](./Screenshots/img-14.png)

---

## 8. Debugging `Pending` Pods

A Pod remains in `Pending` when the Kubernetes scheduler cannot assign it to any node. Common reasons include node selector mismatches, insufficient CPU/memory resources, or unbound PVCs.

### Analyzing Unscheduled Pod

![Pending pod due to nodeSelector](./Screenshots/img-15.png)

### Correcting Node Specifications

![Pending pod resolved](./Screenshots/img-16.png)

---

## 9. Debugging Services & DNS Resolution

A Service routes network traffic to Pods matching its **`selector`**. If the selector does not match the target Pod **`labels`**, the Service will have `<none>` endpoints, and traffic will fail even if Pods are healthy.

```text
Pod Labels  ──►  Service Selector  ──►  Endpoints  ──►  Service ClusterIP  ──►  CoreDNS Record
```

### Identifying Mismatched Selectors

![Service showing empty endpoints](./Screenshots/img-17.png)

### Updating Selector & Verifying Endpoints

![Service endpoints populated](./Screenshots/img-18.png)

### Testing Cluster DNS & HTTP Connectivity

Kubernetes internal DNS convention: `service-name.namespace.svc.cluster.local`.

![DNS lookup and HTTP wget test](./Screenshots/img-19.png)

### Inspecting Broken Service Configurations

![Broken service details](./Screenshots/img-20.png)

### Verifying CoreDNS Component Health

![CoreDNS pods check](./Screenshots/img-21.png)

---

## 10. Mini Project: Troubleshooting Scenario

### Step 1: Deploying the Application Workload

![Deploying Mini Project Application](./Screenshots/img-22.png)

### Step 2: Verifying Workload Status

![Checking Mini Project Pods](./Screenshots/img-23.png)

### Step 3: Inspecting Service & Endpoints

![Checking Service Endpoints](./Screenshots/img-24.png)

### Step 4: Investigating Broken Pod Instance

![Broken Pod State](./Screenshots/img-25.png)

#### Diagnostic Q&A

- **Q1: What is the observed Pod status?**  
  `ErrImagePull` progressing into `ImagePullBackOff`.
- **Q2: What is the root cause error?**  
  Kubernetes failed to pull the specified image because the requested tag was not found in the container registry.
- **Q3: Which command pinpointed the exact root cause?**  
  `kubectl describe pod project-broken-pod` (inspected under the `Events` section).
- **Q4: What is specifically wrong with the image reference?**  
  The tag `nginx:this-tag-does-not-exist` does not exist in Docker Hub / registry.
- **Q5: What is the resolution step?**  
  Update the image tag to a valid version (e.g. `nginx:1.27`), delete the failing Pod, and re-apply the manifest.

### Step 5: Diagnosing Service Selector Mismatch

![Service Selector Issue](./Screenshots/img-26.png)

### Step 6: Root Cause Resolution & Verification

![Root Cause Fixed](./Screenshots/img-27.png)

---

## Troubleshooting Matrix

| Issue Type | Observed Status | Diagnostic Command | Root Cause | Resolution |
| :--- | :--- | :--- | :--- | :--- |
| **Crash Failure** | `CrashLoopBackOff` | `kubectl logs --previous` | Container exit code failure (`exit 1`) | Fix application code or start command |
| **Routing Failure** | Endpoints `<none>` | `kubectl get endpoints`, `kubectl get pods --show-labels` | Service selector mismatch | Update Service selector to match Pod labels |
| **Image Failure** | `ImagePullBackOff` | `kubectl describe pod` | Non-existent image tag or repository | Specify valid container image and tag |

---

## Knowledge Review Questions

1. **What information does `kubectl get` convey?**  
   Provides a high-level overview of resources, focusing on runtime `STATUS`, `READY` container counts, and `RESTARTS`.
2. **What is the key difference between `kubectl get` and `kubectl describe`?**  
   `kubectl get` presents a compact summary table, while `kubectl describe` provides comprehensive resource specs, state conditions, and lifecycle events.
3. **Why is `kubectl logs` essential during troubleshooting?**  
   It captures stdout/stderr printed by the containerized application, exposing internal runtime errors causing application crashes.
4. **When should `kubectl exec` be utilized?**  
   When a container is actively running and you need to perform in-pod diagnostics, such as checking network endpoints or local files.
5. **What does `CrashLoopBackOff` signify?**  
   The container starts, fails, and terminates repeatedly, prompting Kubernetes to apply exponential restart back-off delays.
6. **What causes `ImagePullBackOff`?**  
   Failure to retrieve a container image due to invalid image names, incorrect tags, missing registry credentials, or network timeouts.
7. **Why might a Pod remain stuck in `Pending`?**  
   The scheduler cannot place the Pod due to unsatisfied node selectors, resource exhaustion (CPU/Memory), unfulfilled taints/affinity, or unbound PVCs.
8. **Why would a Kubernetes Service have empty (`<none>`) Endpoints?**  
   The Service's `selector` does not match labels on any running Pods, or the matching Pods are failing readiness checks.
9. **How do Pod labels and Service selectors interact?**  
   A Service routes network traffic exclusively to Pods whose labels exactly match all key-value pairs specified in the Service's selector.
10. **What role does Kubernetes DNS (CoreDNS) fulfill?**  
    CoreDNS automatically resolves internal domain names (e.g., `web-service.default.svc.cluster.local`) to Service ClusterIPs, enabling service discovery across the cluster.