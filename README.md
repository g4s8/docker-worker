# docker-worker
Terraform module: EC2 worker instance with installed Docker, configured SSH access and public IP address to connect

## Why
I'm creating AWS EC2 instance just to run some Docker image quite often,
after run I'm terminating this instance, because it's not needed anymore.
To create new instance I'm always following same steps:
 1. Start new instance, configure it's type, disk size
 2. Configure security groups
 3. Create public IP
 4. Configure SSH connection
 5. SSH into instance and install docker

I've found a way to automate all these steps using Terraform,
this module starts new instance, configures SSH using my local public key,
configures security groups and IP address, installs Docker to this instance
and configures access for `ec2-user` just in one command:
```bash
terraform apply
```
also it's flexible enough to configure EC2 type and disk size or to
run my local scripts after installation.


## Before start
Before using this terraform module make sure you have
[Terraform installed](https://learn.hashicorp.com/terraform/getting-started/install.html)
also you'll need to create SSH key pair and
add this key to ssh-agent for EC2 instance provisioning.
If you don't have existing key-pair, use `ssh-keygen` command to generate new,
for example to create new key-pair with default params and `test` name use:
```bash
ssh-keygen -f test
```
then use public key as `ssh_pub_key` variable, e.g. put it into `.tfvars` file:
```tfvars
ssh_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7GIt4h7gEeStrBSGL2yWjAFddcaURRKaRiRyZtt6cZT8hpQ6r3ITWdZEh8lwNuD4d+c7Pxc3nKU3L+/RGO9s+H7AT6ZQYOTBATAwNEYTnVRcTu+WH3juGGxAnT7wXZDRVabhF8+inXgAGef93Ncvvbi5W9OyVml/hNkVzdWMk9yCSM+m+OPW0NLWlX4l/X5yYmGIa9ogAJmPiztI/ILzrp2CMPMhdhL3Wl8pH/By49GW6v2YRC9DU3FSmso4ZuK4rkCL7yIIlm/h3FOUX1lXLcU3AGVsQdZ5yaA1I0lalbYwYSV/2lGyy7zSlestz2MvPaVI/AMB6SSfOa9EZIy97 g4s8@g4s8"
```
and add private key to ssh-agent:
```bash
eval $(ssh-agent)
ssh-add ./test
```
## Configuration
Variables to configure:

| Name            | Type     | Required | Default           | Destription                                               |
|-----------------|----------|----------|-------------------|-----------------------------------------------------------|
| `instance_type` | `string` | no       | `"t2.micro"`      | EC2 instance type                                         |
| `disk_size`     | `number` | no       | `8`               | EC2 instance root disk size in GB                         |
| `tag_name`      | `string` | no       | `"docker-worker"` | AWS tag `Name` which will be added to each resource       |
| `ssh_pub_key`   | `string` | yes      | -                 | SSH public key                                            |
| `aws_zone`      | `string` | yes      | -                 | AWS availability zone, e.g. `us-east-2a`                  |
| `init_scripts`  | `list`   | no       | `[]`              | List of paths to scripts to run on setup when creating    |


## Example
*Check example in
[./example](https://github.com/g4s8/docker-worker/tree/master/example)
directory.*

Add module to your `.tf` file:
```terraform
provider "aws" {
  region = "us-east"
  profile = "default"
}

module "my-worker" {
  source = "github.com/g4s8/docker-worker"
  ssh_pub_name = "${var.ssh_pub_name}"
  aws_zone = "us-east-2a"
  instance_type = "t2.medium"
  disk_size = 64
  tag_name = "my-worker"
  init_scripts = "${list("./init.sh")}"
}

output "public-ip" {
  value = "${module.docker-builder.ip}"
}
```
Call `terraform get` to get the module,
`terraform init` to init and `terraform apply` to create worker in your AWS account.

IP address will be printed in the output:
```
Outputs:

public-ip = 1.2.3.4
```

then you can access it using command:
```bash
ssh ec2-user@1.2.3.4
```

docker will be installed and configured to use with default `ec2-user` user.
