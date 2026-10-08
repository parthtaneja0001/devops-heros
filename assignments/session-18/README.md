# Session 18: Terraform & Infrastructure as Code (IaC)

**Infrastructure as Code (IaC)** is the practice of managing and provisioning computing infrastructure through machine-readable definition files rather than manual physical hardware configuration or interactive configuration tools in cloud consoles.

| Manual Console Provisioning | Infrastructure as Code (Terraform) |
| :--- | :--- |
| ❌ Error-prone, repeated manually by hand | ✅ Deterministic execution—same code produces identical infrastructure |
| ❌ Lacks audit trail or historical versioning | ✅ Fully versioned, peer-reviewed, and stored in Git repositories |
| ❌ Difficult to replicate across multiple environments | ✅ Highly reusable across Dev, Test, and Prod using variables |

---

## 1. Infrastructure as Code (IaC) Basics

### AWS Credentials & Environment Setup

![AWS Configuration & Setup](./screenshots/img-1.png)

### Initialization, Formatting, Validation & Planning

![Terraform Init Format Validate Plan](./screenshots/img-2.png)

### Applying Configuration & Infrastructure Verification

![Terraform Apply & Verification](./screenshots/img-3.png)

### Teardown & Resource Cleanup

![Terraform Destroy Execution](./screenshots/img-4.png)

---

## 2. Terraform Core Architecture

```text
.tf Definition Files  ──►  Terraform CLI  ──►  AWS Provider  ──►  AWS Cloud Infrastructure (S3, EC2, VPC)
                                 │
                                 ▼
                         terraform.tfstate
```

Terraform follows a **declarative paradigm**: you describe the desired end-state of your infrastructure in configuration files, and Terraform automatically calculates the necessary API calls to reach that target state.

### Declarative Execution Workflow

![Terraform Declarative Execution Workflow](./screenshots/img-5.png)

![Terraform Plan Summary](./screenshots/img-6.png)

---

## 3. Providers & Authentication

A **Provider** is a plugin that exposes resource types and enables Terraform to interact with remote APIs (e.g. AWS, Azure, GCP, Kubernetes).

- Providers like `hashicorp/aws` (e.g. version constraints `~> 6.0`) are fetched automatically during `terraform init`.
- Authentication credentials are derived securely from local environment variables or standard AWS CLI configuration (`aws configure`) and **must never be hardcoded inside `.tf` files**.

### Configuring AWS Provider Settings

![AWS Provider Configuration](./screenshots/img-7.png)

![Terraform Init Downloading Provider](./screenshots/img-8.png)

![Provider Initialization Confirmation](./screenshots/img-9.png)

---

## 4. Declaring & Managing Resources

Resources represent cloud components like S3 buckets, EC2 instances, or VPC networks:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-unique-bucket-name"
}
#        │               │
#        ▼               ▼
#  Resource Type    Local Resource Identifier
```

The combination `aws_s3_bucket.demo` forms the unique address Terraform uses to track this specific resource in state.

### Creating New Resources

![Resource Creation Plan](./screenshots/img-10.png)

### In-Place Resource Updates (Adding Tags)

![Resource Modification Tag Update](./screenshots/img-11.png)

### Targeted Resource Deletion

![Resource Destruction Output](./screenshots/img-12.png)

---

## 5. Parameterizing Infrastructure via Variables

Input variables parameterize Terraform configurations, making code reusable across Development, Testing, and Production environments without modifying source code.

> 🔒 **Security Notice:** Variable values can be supplied via `default` values, `terraform.tfvars`, or command-line flags (`-var`). Keep `terraform.tfvars` containing secrets out of version control (`.gitignore`).

### Planning Deployment for Development Environment

![Terraform Plan with Dev Variables](./screenshots/img-13.png)

### Planning Deployment for Testing Environment

![Terraform Plan with Test Variables](./screenshots/img-14.png)

---

## 6. Exposing Outputs

Outputs export attributes of provisioned infrastructure (such as IP addresses, resource IDs, or ARNs) to the CLI console, external automation tools, or parent modules.

![Defining Terraform Outputs](./screenshots/img-15.png)

![Inspecting Output Display](./screenshots/img-16.png)

![Extracting Specific Output Values](./screenshots/img-17.png)

---

## 7. The Standard Terraform Lifecycle

| Command | Primary Responsibility |
| :--- | :--- |
| **`terraform init`** | Initializes project directory, downloads providers, and configures backend state storage. |
| **`terraform fmt`** | Formats configuration files according to HCL canonical standards. |
| **`terraform validate`** | Validates syntax, block structures, and variable references for correctness. |
| **`terraform plan`** | Generates an execution plan showing actions (`+` create, `~` update, `-` destroy). |
| **`terraform apply`** | Executes proposed infrastructure changes upon user confirmation (`yes`). |

### Running Initialization through Execution Planning

![Terraform Init and Plan](./screenshots/img-18.png)

### Executing Infrastructure Changes

![Terraform Apply Confirmation](./screenshots/img-19.png)

### Deterministic Deployments using Saved Plans

Using `terraform plan -out=tfplan` saves an exact execution plan to a file. Running `terraform apply tfplan` guarantees that only the pre-approved plan is executed.

![Applying Saved Execution Plan](./screenshots/img-20.png)

---

## 8. Resource Deletion (`destroy`)

The `terraform destroy` command terminates all managed infrastructure defined within the current workspace. Always run `terraform plan -destroy` first to preview resources queued for deletion.

![Terraform Destroy Plan Preview](./screenshots/img-21.png)

![Terraform Destroy Execution Complete](./screenshots/img-22.png)

---

## 9. Terraform State Management (`terraform.tfstate`)

Terraform maintains state in a `terraform.tfstate` file. State acts as a database mapping your configuration files to real-world cloud resources, tracking metadata and performance state.

> ⚠️ **Important:** State files contain sensitive resource attributes. Never manually edit `terraform.tfstate` or commit state files directly to version control repositories.

### Inspecting Managed State Objects

![Listing State Resources](./screenshots/img-23.png)

### Viewing Full State Content

![Viewing Detailed Terraform State](./screenshots/img-24.png)

### Verifying Empty State Post-Teardown

![State File Empty After Destroy](./screenshots/img-25.png)

---

## 10. Hands-On Project: Automated AWS S3 Bucket Provisioning

A complete multi-file Terraform project structured following industry best practices:

```text
terraform-s3-demo/
├── terraform.tf   # Terraform CLI & required provider version constraints
├── providers.tf   # Provider configuration and region settings
├── variables.tf   # Input variable declarations and defaults
├── main.tf        # Primary resource definitions (S3 bucket, tags, ACLs)
└── outputs.tf     # Output definitions (Bucket Name, ARN, Domain Name)
```

### Initializing & Previewing Plan

![Project Initialization](./screenshots/img-26.png)

![Project Execution Plan](./screenshots/img-27.png)

### Applying Configuration & Extracting Outputs

![Project Apply Output](./screenshots/img-28.png)

![Project Outputs Verification](./screenshots/img-29.png)

### AWS CLI Infrastructure Verification

![AWS CLI Verification of S3 Bucket](./screenshots/img-30.png)

### Environment Teardown

![S3 Project Resource Teardown](./screenshots/img-31.png)

---

## Summary & Key Takeaways

- **Standard Lifecycle:** Always execute **`init` ──► `fmt` ──► `validate` ──► `plan` ──► `apply` ──► `destroy`**.
- **Plan Verification:** Never run `apply` without reviewing `plan` results first; use `plan -out` for automated CI/CD pipelines.
- **State Integrity:** **State (`terraform.tfstate`)** is Terraform's single source of truth—protect state files and store them remotely in production.
- **Security Best Practices:** Keep credentials (`aws configure`), state files (`*.tfstate`), and sensitive variable overrides (`*.tfvars`) out of Git repositories (`.gitignore`).