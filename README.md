# aws-terraform

This repository contains reusable Terraform module skeletons for common AWS resources.

Modules added:

- vpc
- subnets
- internet_gateway
- nat_gateway
- route_tables
- security_groups
- network_acl
- transit_gateway
- vpn_gateway
- direct_connect
- ec2
- launch_template
- auto_scaling_group
- load_balancer_alb
- load_balancer_nlb
- target_group
- eks
- ecs
- ecr
- lambda
- api_gateway
- cloudfront
- route53

Each module is a minimal skeleton located under `modules/<module-name>/` with `main.tf`, `variables.tf`, `outputs.tf`, and a `README.md` with usage notes.

Customize variables and implement resources in each module according to your environment and requirements.
