AWS AppConfig Example with ECS
=======================

Example project that demonstrates the usage of AWS AppConfig along with an ECS
service.

The VPC and networking is created from VPC module at
`registry.opentofu.org/aws-ia/vpc/aws`, with 2 AZs (2 private + 2 public
subnets, routes and an IGW). Configure the VPC parent CIDR using `vpc_cidr`
variable.
