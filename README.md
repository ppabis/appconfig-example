AWS AppConfig Example with ECS
=======================

Example project that demonstrates the usage of AWS AppConfig along with an ECS
service.

The VPC and networking is created from VPC module at
`registry.opentofu.org/aws-ia/vpc/aws`, with 2 AZs (2 private + 2 public
subnets, routes and an IGW). Configure the VPC parent CIDR using `vpc_cidr`
variable [`vpc.tf`](vpc.tf).

The SSL certificate is issued by ACM, validated by DNS ownership in module
`terraform-aws-modules/acm/aws` [`acm.tf`](acm.tf).

Loadbalancer is created using `terraform-aws-modules/alb/aws` with a single
target group, HTTPS listener with above certificate, redirect HTTP->HTTPS and
open to the wide internet [`alb.tf`](alb.tf).

Route53 domain of the loadbalancer is defined in [`dns.tf`](dns.tf).
