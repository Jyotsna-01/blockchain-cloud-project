# Secure Patient Data Management using Blockchain, AI, and AWS Cloud Architecture

This project presents the architecture design of a secure patient data management system built around AWS cloud services, blockchain-based data integrity, and AI-assisted security concepts. The main focus of this repository is cloud architecture, security planning, AWS component design, and system structure, while deployment and execution are kept as supporting evidence.

## Project Summary

- **Project Type:** Cloud Architecture Design
- **Domain:** Healthcare Data Security
- **Platform:** AWS Cloud
- **Core Concepts:** Blockchain, AI, IAM/RBAC, Network Security
- **Primary Emphasis:** Architecture and AWS components
- **Secondary Emphasis:** Deployment and execution proof

## Project Goal

The goal is to design a secure and scalable healthcare platform that protects patient records through layered cloud security, controlled access, and integrity-focused architecture. The design combines AWS networking, IAM, storage, compute, and database services with blockchain and AI concepts to strengthen trust, traceability, and monitoring.

## Architecture Overview

The system follows a layered design:

- **User Interface Layer:** Patients, hospital staff, and administrators interact with the system through web-based interfaces.
- **Application Layer:** Handles authentication, authorization, business logic, and integration with backend services.
- **Database Layer:** Stores patient data in a structured and secure relational database.
- **Blockchain Layer:** Supports tamper detection and integrity verification for sensitive records.
- **AI Layer:** Adds conceptual intelligence for anomaly detection and security monitoring.
- **AWS Infrastructure Layer:** Provides the network, compute, storage, and access control foundation.

### High-Level Flow

Internet → Application Load Balancer → EC2 Application Server → RDS MySQL in Private Subnet

Supporting services include S3 for storage and logs, IAM for permissions, and security groups for traffic control.

## AWS Components

This design uses the following AWS services:

- **Amazon VPC** for isolated networking.
- **Public and Private Subnets** for separation of internet-facing and internal resources.
- **Route Tables and Internet Gateway** for controlled traffic flow.
- **Amazon EC2** for hosting the application server.
- **Application Load Balancer** for routing incoming traffic.
- **Amazon RDS MySQL** for managed database storage.
- **Amazon S3** for static assets, media files, and logs.
- **AWS IAM** for roles, policies, and access control.
- **Security Groups** for layered traffic restrictions.
- **Monitoring-related permissions** for logging and systems management.

## Security Design

Security is a central part of the architecture.

- The database remains in private subnets.
- The application layer is the only internet-facing compute layer.
- Security groups restrict traffic between ALB, EC2, and RDS.
- IAM roles replace hardcoded credentials.
- S3 uses access restrictions, versioning, and encryption.
- Blockchain supports record integrity and auditability.
- AI supports future anomaly detection and monitoring.

## IAM and RBAC

The project uses multi-layer access control:

- **AWS IAM:** Controls service and infrastructure permissions.
- **Infrastructure Role:** Gives EC2 access to services such as S3, logging, and parameter access.
- **Application RBAC:** Supports role-based access for patients and hospital users.

This layered model improves governance and supports healthcare security requirements.

## Deliverables

The repository should include:

- Architecture diagrams.
- Network design.
- IAM and RBAC model.
- Security reference architecture.
- Cost estimate.
- Terraform-based architecture structure as design documentation.

## Repository Structure

```bash
blockchain-cloud-project/
├── .qodo/(VsCode)
├── .terraform/(VsCode)
├── app/
├── modules/
│   ├── compute/
│   ├── database/
│   ├── security/
│   ├── storage/
│   └── vpc/
├── architecture-diagrams
├── network-design
├── security-architecture
├── iam-rbac-model
├── cost-estimate
├── .gitignore
├── main.tf
├── outputs.tf
├── variables.tf
├── terraform.tfvars
├── terraform.lock.hcl
├── terraform.tfstate
├── terraform.tfstate.backup
└── README.md
```

## Terraform Execution

The Terraform files in this repository are included to show how the architecture is organized as infrastructure code. These commands are used to initialize, validate, and preview the AWS resources.

### Prerequisites
- Install Terraform
- Configure AWS credentials locally
- Make sure the required providers are available

### Terraform Commands

```bash
terraform init
terraform validate
terraform plan
```

### Optional Deployment Command

If you want to actually create the AWS resources, use:

```bash
terraform apply
```

### To Remove Resources

If resources were created for testing, they can be removed with:

```bash
terraform destroy
```

## Cost Estimate

The architecture is designed with AWS cost planning in mind. The main services considered for estimation are EC2, RDS MySQL, Application Load Balancer, S3, and data transfer. This keeps the design practical and suitable for a student-scale cloud project.

## Blockchain and AI Note

Blockchain is used as a conceptual integrity layer to detect tampering in patient records. AI is included as a supporting idea for anomaly detection and intelligent security monitoring. These ideas strengthen the project, but the main emphasis remains on AWS architecture and security.

## Conclusion

This project is best presented as a secure AWS cloud architecture for healthcare data management. It highlights network segmentation, IAM, database security, storage protection, and clear architectural planning, with blockchain and AI used as supporting concepts.
