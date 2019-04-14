
# AWS region to run
variable "aws_region" {
  default = "us-east-2"
}

# Public key
variable "ssh_pub_key" {}

# AWS profile
variable "aws_profile" {
  default = "default"
}

# Using AWS provider
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

module "docker-builder" {
  source = "github.com/g4s8/docker-worker"
  tag_name = "docker-builder"
  ssh_pub_key = "${var.ssh_pub_key}"
  aws_zone = "us-east-2a"
  init_scripts = "${list("./init.sh")}"
}

output "public-ip" {
  value = "${module.docker-builder.ip}"
}
