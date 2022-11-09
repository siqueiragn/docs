## Terraform Guide 
---
 
### Introduction

Terraform is an Infrastructure as Code tool to provide resources in different providers like AWS, Oracle Cloud, Docker Containers, Kubernets, etc.

Terraform use it own programming language known as HCL (Hashicorp Configuration Language) to create and manage resources. HCL is considered an declarative language, because as a developer you don't need to know how it works, it just works if you write the configuration properly.

HCL contains some importants components as a programming language like if statements, loops, variables, arrays and data types as we will see further in this guide.

### Concepts

Terraform use configuration files to manage infrastructure and settings on different providers. You can setup and manage infrastructure in different providers using the same Terraform project if you are working with multicloud archictectures. 

Terraform works using plans before apply, so if you are in doubt about what resources will be affected after the configuration files changed, just run a plan and the output should be a simulation of the final result.

A property of Terraform is the idempotence, which means once you setup your infrastructure and apply the configuration, it won't be duplicated if you re-apply the same commands. It happens because Terraform can keep a file named ```terraform.tfstate``` saving the last state of the infrastructure project. 

If you change some property of an infrastructure resource like the number of vCPUs in a virtual instance, once you run a Terraform plan, the output should report you highligthing the modified resource. 

### HCL Components

#### Variables
#### Outputs
#### Resources
#### Data
#### Module



### Best Practices

Usually when writing IAC configuration files we should organize some important settings, like variables, outputs, main code and a lot of other things for each enviroment or project we will manage.


### Hands On

- [1.0 - Provisioning Docker Containers](1.0.md)
- [2.0 - Provisioning AWS VPC](2.0.md)
- 
### References
[Terraform Registry - Docker](https://registry.terraform.io/providers/kreuzwerker/docker)
[Docker Hub - Pengbai/Super Mario](https://hub.docker.com/r/pengbai/docker-supermario)
