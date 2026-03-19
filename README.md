# Multi-Environment AWS Infrastructure — Terraform

Production AWS infrastructure for a multi-tenant SaaS platform, managing three environments across two regions. Built to support a live datacenter-to-AWS migration.

## Overview

This repository defines infrastructure-as-code for a full-stack SaaS application running on AWS ECS (Fargate), with supporting services including MSSQL on RDS, Redis-compatible caching (ElastiCache/Valkey), S3, and a secure database bridge for external tool access.

The codebase is organized as a **modular monorepo** — reusable modules in `modules/` are instantiated independently per environment, enabling consistent infrastructure across dev and production with minimal duplication.

## Environments

| Environment | Region | Purpose |
|---|---|---|
| `development-us` | us-west-2 | Active development and QA |
| `production-uk` | eu-west-1 | EU production (deployed) |
| `production-us` | us-west-2 | US production (migration in progress) |

## Architecture

```
                         ┌─────────────────────────────┐
                         │        Cloudflare CDN        │
                         └────────────┬────────────────┘
                                      │ HTTPS (TLS 1.3 FIPS)
                         ┌────────────▼────────────────┐
                         │     Application Load         │
                         │     Balancer (ALB)           │
                         └──────┬──────────┬───────────┘
                                │          │
               ┌────────────────▼──┐  ┌───▼────────────────┐
               │   Web Service     │  │  Session Service   │
               │   (.NET / ECS)    │  │  (Node.js / ECS)   │
               └────────┬──────────┘  └────────┬───────────┘
                        │                       │
          ┌─────────────▼───────────────────────▼──────────┐
          │              Private VPC Subnets                │
          │  ┌──────────────┐  ┌───────────┐  ┌─────────┐  │
          │  │  MSSQL RDS   │  │  Valkey   │  │   S3    │  │
          │  │  (Multi-AZ)  │  │  Cache    │  │ Bucket  │  │
          │  └──────────────┘  └───────────┘  └─────────┘  │
          └─────────────────────────────────────────────────┘
```

## Modules

| Module | Description |
|---|---|
| `vpc` | VPC with public/private subnet tiers, NAT gateway, 14 VPC endpoints |
| `my_app_ecs` | ECS cluster, ALB, web + session Fargate services, IAM roles, security groups |
| `rds` | MSSQL Server on RDS — Multi-AZ, enhanced monitoring, automated backups |
| `valkey` | ElastiCache (Valkey/Redis) replication group with encryption at rest and in transit |
| `s3_bucket` | S3 with versioning, EventBridge notifications, enforced TLS, public access block |
| `database_bridge` | SSH proxy ECS service + NLB for secure external database access (Metabase, Domo) |
| `mssql_datadog` | Datadog SQL Server database monitoring sidecar |
| `microservices_ec2` | Windows EC2 for legacy microservices with SSM access and CloudWatch logging |
| `datadog_container_definition` | Reusable Datadog agent sidecar container definition |
| `ecs_cluster` | Standalone ECS cluster with CloudWatch container insights |
| `tfstate_backend` | S3 + DynamoDB remote state backend bootstrap |
| `vpc_cidrs` | Centralized CIDR block management across all environments |

## Security Highlights

- **Network**: All compute in private subnets, ALB only accepts traffic from Cloudflare IPs, ECS tasks egress via NAT gateway
- **TLS**: ALB enforces `ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04`
- **Encryption at rest**: RDS (KMS), ElastiCache (KMS), S3 (AES-256), ECR (KMS), EBS (KMS)
- **Secrets**: All sensitive configuration via AWS SSM Parameter Store (SecureString), injected into containers at task startup
- **IAM**: Least-privilege execution and task roles scoped to environment-specific SSM paths and S3 buckets
- **ALB hardening**: `drop_invalid_header_fields = true`, deletion protection enabled
- **RDS hardening**: `publicly_accessible = false`, deletion protection, 35-day backup retention in production

## State Management

Each environment directory manages its own remote Terraform state in S3 with DynamoDB locking. A `bootstrap.tf` in each directory creates the state backend resources before the main infrastructure is applied.

```
environment/
├── vpc/
│   ├── bootstrap.tf     # Creates S3 bucket + DynamoDB for VPC state
│   ├── backend.tf       # Remote state config (machine-generated after bootstrap)
│   └── main.tf
└── fc-4dx/
    ├── bootstrap.tf     # Creates S3 bucket + DynamoDB for app state
    ├── backend.tf       # Remote state config (machine-generated after bootstrap)
    └── main.tf
```

## Observability

- **Datadog APM**: Agent sidecar on all ECS tasks, profiling enabled
- **Datadog DBM**: SQL Server database monitoring via dedicated ECS task
- **CloudWatch Logs**: All services log to structured CloudWatch log groups with log forwarding to Datadog
- **ECS deployment circuit breaker**: Automatic rollback on failed deployments

## Tags

All resources are tagged consistently via provider-level `default_tags`:

```hcl
tags = {
  environment = "production-us"
  application = "my-app"
  namespace   = "my-app"
  managed-by  = "Terraform"
  Department  = "Digital Platforms"
}
```
