# Session 20: Monitoring, Observability, and GitOps Continuous Delivery

This session covers the foundations of system observability (Monitoring vs. Observability, Metrics, Logs, and Traces), metric collection with **Prometheus**, real-time visualization with **Grafana**, and declarative continuous deployment using **GitOps and Argo CD**.

---

## 1. Monitoring vs. Observability

| Paradigm | Primary Focus | Key Question Answered | Characteristic |
| :--- | :--- | :--- | :--- |
| **Monitoring** | Tracks pre-defined metrics and system alerts | *"Is the system working right now?"* | Black-box checking of known failure modes |
| **Observability** | Infers internal system health from telemetry outputs | *"Why is the system behaving this way?"* | Exploration of unknown system states via telemetry |

### Demo Application Cluster Setup

![Demo App Cluster Setup](./screenshots/img-1.png)

### Log Inspection & Resource Description

![Log Inspection and Describe Output](./screenshots/img-2.png)

### Cluster Teardown & Environment Cleanup

![Environment Cleanup](./screenshots/img-3.png)

---

## 2. Telemetry Signals: Metrics, Logs, and Traces

Observability relies on three distinct types of telemetry signals:

| Telemetry Signal | Description | Example |
| :--- | :--- | :--- |
| **Metrics** | Numerical time-series data aggregated over time | CPU utilization (80%), HTTP throughput (200 req/s) |
| **Logs** | Immutable, timestamped textual event records | `2026-10-08 15:00:00 [INFO] Database connection established` |
| **Traces** | End-to-end request lifecycle paths across microservices | API Gateway ──► Auth Service ──► DB Query (Span ID) |

---

## 3. Prometheus — Time-Series Metrics Scraper

**Prometheus** is an open-source time-series monitoring system that actively **pulls (scrapes)** metrics from HTTP `/metrics` endpoints exposed by target workloads.

- **PromQL (Prometheus Query Language):** Powerful query language used to compute rates, quantiles, and aggregations (e.g., `up == 1` confirms a target is active).
- **Target Scraping:** Collects numerical metrics at periodic intervals.

### Launching Prometheus Container

![Prometheus Server Startup](./screenshots/img-4.png)

### Querying Target Health (`up`) via PromQL

![PromQL Target Health Query](./screenshots/img-5.png)

### Stopping Prometheus Service

![Stopping Prometheus](./screenshots/img-6.png)

---

## 4. Grafana — Visual Dashboarding Platform

**Grafana** is a visualization platform that queries metrics from datasources like Prometheus and renders interactive dashboards.

- **Datasource Connection:** Configured to read Prometheus metrics via internal network URLs (e.g. `http://prometheus:9090`).
- **Panels & Dashboards:** Transforms raw PromQL queries into real-time graphs, gauges, and status indicators.

### Launching Prometheus & Grafana via Docker Compose

![Docker Compose Startup](./screenshots/img-7.png)

### Adding Prometheus Datasource in Grafana

![Grafana Datasource Configuration](./screenshots/img-8.png)

### Creating Custom Metrics Panel & Dashboard

![Grafana Panel Setup](./screenshots/img-9.png)

### Stopping Monitoring Stack

![Teardown Monitoring Stack](./screenshots/img-10.png)

---

## 5. Introduction to GitOps

**GitOps** is an operational model that applies DevOps best practices (version control, pull requests, CI/CD) to infrastructure and application management.

| Traditional Ops | GitOps Model |
| :--- | :--- |
| Engineers run manual `kubectl apply` commands | GitOps controller reconciles cluster automatically |
| Cluster state drifts over time without audit trails | **Git is the Single Source of Truth**; drift is auto-reverted |
| Difficult to audit changes or rollback failures | Every change is a versioned, peer-reviewed Git commit |

![GitOps Conceptual Architecture](./screenshots/img-11.png)

---

## 6. Git as the Single Source of Truth

With GitOps, modifying system state requires making a commit to a Git repository rather than manually editing live cluster resources.

### Initializing the Manifest Repository

![GitOps Repository Initialization](./screenshots/img-12.png)

### Updating Desired State via Git Commit

![Git Commit Workflow](./screenshots/img-13.png)

---

## 7. Declarative CD with Argo CD

**Argo CD** is a Kubernetes-native GitOps continuous delivery tool that monitors Git repositories and synchronizes cluster resources to match the desired state.

- **Sync Policy Features:**
  - **Prune:** Deletes cluster resources removed from Git.
  - **Self-Heal:** Overwrites manual out-of-band `kubectl` edits to match Git state.

```text
Developer Git Push ──► GitHub Repository ──► Argo CD Controller ──► Kubernetes Cluster Updated
```

### Checking Cluster Readiness

![Cluster Status Check](./screenshots/img-14.png)

### Installing Argo CD Controller Manifests

![Installing Argo CD Controller](./screenshots/img-15.png)

### Accessing Argo CD Web UI

![Argo CD Web UI Access](./screenshots/img-16.png)

### Registering Application in Argo CD

![Creating Argo CD Application](./screenshots/img-17.png)

### Verifying Synced Application State

![Argo CD Application Synced](./screenshots/img-18.png)

### Inspecting Running Application Pods

![Running Application Pods](./screenshots/img-19.png)

### Scaling to 2 Replicas via Git Commit

![Git Push Scale to 2 Replicas](./screenshots/img-20.png)

### Scaling to 3 Replicas via Git Commit

![Git Push Scale to 3 Replicas](./screenshots/img-21.png)

### Cleaning Up Release Resources

![Argo CD Release Cleanup](./screenshots/img-22.png)

---

## 8. Mini Project: End-to-End GitOps Pipeline

Deploying an application via Argo CD, scaling it declaratively, and verifying self-healing automated reconciliation.

```text
Git Repository (Desired State)  ──►  Argo CD (Reconciler)  ──►  Kubernetes (Actual State)
```

### Deploying Cluster & Argo CD

![Mini Project Cluster Setup](./screenshots/img-23.png)

### Verifying Application Synced Status

![Mini Project Application Synced](./screenshots/img-24.png)

### Scaling Deployment to 3 Replicas in Git

Updating `replicas: 3` in `deployment.yaml`, committing, and pushing to Git:

![Scaling to 3 Replicas in Git](./screenshots/img-25.png)

### Demonstrating Argo CD Self-Healing

A manual manual scale command (`kubectl scale --replicas=1`) is automatically detected as configuration drift and reconciled back to `replicas: 3` by Argo CD to match Git.

![Argo CD Self Healing Verification](./screenshots/img-26.png)

### System Logs & State Verification

![Observing System Logs and Status](./screenshots/img-27.png)

---

## Key Takeaways

- **Observability:** **Metrics, Logs, and Traces** provide complete visibility into system behavior.
- **Monitoring Tools:** **Prometheus** handles time-series metrics ingestion; **Grafana** handles visualization.
- **GitOps Paradigm:** **Git** is the single source of truth for all environment manifests.
- **Automated Sync:** **Argo CD** maintains alignment between Git (desired state) and Kubernetes (actual state) through continuous automated reconciliation and self-healing.