## Provisioning a Docker Container With SuperMario Image 
---
 
#### Objective 

Provide a custom docker image (pengbai/docker-supermario) inside of a docker container using Terraform.

#### Requirements
Docker
Terraform

#### Practice

1) Create a local folder
 ```$ mkdir tf-supermario```
2) Access tf-supermario folder
 ```$ cd tf-supermario```
3) Create a main file named "main.tf" 
 ```$ touch main.tf```
4) Open "main.tf" file (generic text editor or using "nano" command)
 ```$ nano main.tf```
5) Open "registry.terraform.io" and search for "kreuzwerker/docker" provider
6) Locate the "USE PROVIDER" button and copy the content
7) Paste the content inside of "main.tf" file
 ```
    terraform {
        required_providers {
            docker = {
                source = "kreuzwerker/docker"
                version = "2.22.0"
            }
        }
    }
 ```
 8) Save "main.tf" file
 9) Initialize Terraform repository
 ``` $ terraform init ```
 10) Open "main.tf" file
 ``` $ nano main.tf ```
 11) Append to the end of the file a docker image resource (found at registry.terraform.io -> krewuzwerker/docker -> resources -> docker_image)
 ```
    resource "docker_image" "custom_resource_name_image" {
        name = "pengbai/docker-supermario:latest"
    }
 ```
 12) Run the Terraform plan routine to check the output and the resources that will be provisioned
    ``` $ terraform plan ```

 13) Open "main.tf" file
    ``` $ nano main.tf```
 14) Append the docker_container resource (found at registry.terraform.io -> krewuzwerker/docker -> resources -> docker_container) at the end of the file
```
    resource "docker_container" "custom_resource_name_container" {
        name = "supermario-container"
        image = "${docker_image.custom_resource_name_image.image_id}"
        ports {
            internal = "8080"
            external = "5000"
        }
    }
```
15) Save "main.tf" file
16) Run Terraform plan routine again and check the modified resources
    ``` $ terraform plan```

17) Run Terraform apply command to confirm the changes
    ``` $ terraform apply```
18) Go to a web browser and navigate to ``` localhost:5000 ``` (external port in "main.tf" file)

19) Destroy the provisioned resources
    ``` $ terraform destroy ```

#### References
[Terraform Registry - Docker](https://registry.terraform.io/providers/kreuzwerker/docker)
[Docker Hub - Pengbai/Super Mario](https://hub.docker.com/r/pengbai/docker-supermario)