# AWS Production-Grade Reusable Terraform Modules

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![HCL](https://img.shields.io/badge/hcl-%23000000.svg?style=for-the-badge&logo=hashicorp&logoColor=white)

This repository contains highly reusable, production-ready, and audited Terraform modules for AWS resources.

Each module is organized under `modules/<module-name>/` and implements:
- `main.tf`: Clean and standardized resources with zero hardcoding.
- `variables.tf`: Fully typed variables with descriptions and secure defaults.
- `outputs.tf`: Comprehensive outputs to facilitate integration.
- `README.md`: Usage examples, architecture details, and inputs/outputs tables.

All modules are formatted (`terraform fmt`) and validated (`terraform validate`).

---

## Repository Structure & Modules List

### 1. Core Networking & Security
- [vpc](modules/vpc) — Virtual Private Cloud config.
- [subnets](modules/subnets) — Public, Private, and Database subnet groups.
- [internet_gateway](modules/internet_gateway) — Internet routing boundary.
- [nat_gateway](modules/nat_gateway) — Outbound-only NAT routing.
- [route_tables](modules/route_tables) — Custom subnets routing tables.
- [security_groups](modules/security_groups) — Scoped firewall rule groups.
- [network_acl](modules/network_acl) — Subnet boundary access control lists.
- [kms](modules/kms) — Customer managed KMS keys and key policies.
- [iam](modules/iam) — Reusable IAM roles, instance profiles, and policies.

### 2. Storage & Databases
- [s3](modules/s3) — Encrypted secure storage buckets with lifecycles.
- [efs](modules/efs) — Elastic File System with access points.
- [fsx](modules/fsx) — Managed Lustre/Windows storage.
- [dynamodb](modules/dynamodb) — NoSQL tables with point-in-time recovery.
- [rds](modules/rds) — Relational Database Service instances.
- [aurora](modules/aurora) — Aurora MySQL/PostgreSQL serverless/provisioned clusters.
- [elasticache](modules/elasticache) — Redis/Memcached cluster caching.
- [redshift](modules/redshift) — Data warehousing clusters.
- [secrets_manager](modules/secrets_manager) — Secrets rotation and security storage.
- [ssm_parameter_store](modules/ssm_parameter_store) — Config parameters storage.

### 3. Compute, Scaling & Load Balancing
- [ec2](modules/ec2) — Standard virtual server instances.
- [launch_template](modules/launch_template) — Standard templates enforcing IMDSv2.
- [auto_scaling_group](modules/auto_scaling_group) — ASG configurations.
- [load_balancer_alb](modules/load_balancer_alb) — Application Load Balancers.
- [load_balancer_nlb](modules/load_balancer_nlb) — Network Load Balancers.
- [target_group](modules/target_group) — Target groups configuration.

### 4. Containers & Serverless
- [ecr](modules/ecr) — Docker registry with image scanning.
- [ecs](modules/ecs) — Fargate/EC2 ECS container clusters.
- [eks](modules/eks) — Elastic Kubernetes Service clusters.
- [lambda](modules/lambda) — Serverless functions.
- [api_gateway](modules/api_gateway) — REST/HTTP API Gateways.
- [step_functions](modules/step_functions) — State machine workflows.
- [eventbridge](modules/eventbridge) — Serverless event bus routing.

### 5. Advanced Domain Routing & Content Delivery
- [transit_gateway](modules/transit_gateway) — Multi-VPC hub routing.
- [vpn_gateway](modules/vpn_gateway) — IPSec VPN connections.
- [direct_connect](modules/direct_connect) — Dedicated hybrid connections.
- [acm](modules/acm) — TLS/SSL public certificate validation.
- [route53](modules/route53) — Public/Private DNS zone routing.
- [waf](modules/waf) — Web Application Firewall rules.
- [cloudfront](modules/cloudfront) — Global CDN distributions.

### 6. Observability, Security & Governance
- [cloudtrail](modules/cloudtrail) — Compliance logging trails.
- [cloudwatch](modules/cloudwatch) — Metrics dashboards and alarms.
- [config](modules/config) — AWS Config compliance rules.
- [guardduty](modules/guardduty) — Malware and threat detection.
- [inspector](modules/inspector) — Automated vulnerability scans.
- [security_hub](modules/security_hub) — Security standards and controls compliance.
- [shield](modules/shield) — Advanced DDoS protection groups.
- [sns](modules/sns) — Encrypted pub-sub messaging.
- [sqs](modules/sqs) — Message queues with Dead Letter Queues (DLQ).
- [backup](modules/backup) — Backup plans, vaults, and policies.
- [organizations](modules/organizations) — Multi-account Organization Units and SCPs.
- [opensearch](modules/opensearch) — Multi-AZ OpenSearch domains.

### 7. Developer Tools & CI/CD
- [codecommit](modules/codecommit) — Git repositories.
- [codebuild](modules/codebuild) — Compute build projects.
- [codedeploy](modules/codedeploy) — Multi-platform application deployments.
- [codepipeline](modules/codepipeline) — Multi-stage release pipelines.

### 8. Alternative Compute, Streaming & Messaging
- [app_runner](modules/app_runner) — Containerized web application compute.
- [batch](modules/batch) — Dynamic batch computing environments.
- [elastic_beanstalk](modules/elastic_beanstalk) — Beanstalk environment management.
- [emr](modules/emr) — EMR clusters with master/core topologies.
- [msk](modules/msk) — Streaming Apache Kafka clusters.
- [mq](modules/mq) — ActiveMQ/RabbitMQ broker setups.

### 9. Analytics & Landing Zones
- [glue](modules/glue) — Databases, catalog tables, crawlers, and Spark jobs.
- [athena](modules/athena) — Serverless SQL query workgroups.
- [lake_formation](modules/lake_formation) — Data lake permissions and LF-tags.
- [resource_groups](modules/resource_groups) — Dynamic tag-based queries.
- [cloudformation_stack](modules/cloudformation_stack) — Nested and standalone stacks/StackSets.
- [service_catalog](modules/service_catalog) — CloudFormation portfolios.

### 10. Private Certificate Authority & Workspace Compute
- [private_ca](modules/private_ca) — ROOT/SUBORDINATE CA activation.
- [certificate_manager](modules/certificate_manager) — ACM integration with Private CA.
- [ses](modules/ses) — Email/domain identity verification and receipt rules.
- [workspaces](modules/workspaces) — Desktop workspaces with enforced encryption.

### 11. Enterprise Connectivity & Mesh Routing
- [vpc_endpoints](modules/vpc_endpoints) — Gateway and Interface VPC endpoints.
- [elastic_ip](modules/elastic_ip) — Public Elastic IP allocations.
- [placement_groups](modules/placement_groups) — Custom placement strategies (cluster, spread, partition).
- [app_mesh](modules/app_mesh) — App Mesh meshes, virtual nodes, and routing rules.
- [cloud_map](modules/cloud_map) — Public/Private DNS and HTTP namespaces.
- [service_discovery](modules/service_discovery) — Service and instances registrations.
- [global_accelerator](modules/global_accelerator) — Regional accelerators and endpoints.
- [outposts](modules/outposts) — AWS Outposts subnets and LNIs.
- [local_zones](modules/local_zones) — Local zone subnets.
- [wavelength](modules/wavelength) — Carrier gateways and Wavelength subnets.

### 12. Advanced Edge Security, Directories & Identity
- [network_firewall](modules/network_firewall) — AWS Network Firewall and logging.
- [verified_access](modules/verified_access) — Verified Access instances, groups, and endpoints.
- [identity_center](modules/identity_center) — SSO Permission Sets and account assignments.
- [managed_ad_microsoft_ad](modules/managed_ad_microsoft_ad) — Directory Service Managed Active Directory.
- [transfer_family](modules/transfer_family) — SFTP, FTPS, FTP servers and user registry.
- [resource_access_manager](modules/resource_access_manager) — RAM resource sharing.
- [detective](modules/detective) — Threat graph analysis.
- [audit_manager](modules/audit_manager) — Assessments compliance tracking.
- [access_analyzer](modules/access_analyzer) — IAM Access Analyzers.

---

## Best Practices Enforced

1. **Tagging Convention**: All resources dynamically merge a `Name` tag with the user's `tags` map:
   ```hcl
   tags = merge({ Name = var.name }, var.tags)
   ```
2. **Security & Encryption**:
   - Volume encryption (KMS) enabled by default on all databases, instances, EMR, and WorkSpaces.
   - S3 buckets block all public access, require SSL, and use server-side encryption.
3. **No Hardcoding**: Region, account IDs, and partitions are dynamically queried using standard data sources:
   - `data.aws_region.current.region`
   - `data.aws_partition.current.partition`
   - `data.aws_caller_identity.current.account_id`
