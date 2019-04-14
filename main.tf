# MIT License
#
# Copyright (c) 2019 Kirill
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

locals {
  # Worker SSH key-pair name
  ssh_key_pair = "docker-worker-kp"
  # Security group name
  sec_group_name = "docker-worker-sg"
}

# EC2 worker instance
resource "aws_instance" "worker" {
  ami           = "ami-02bcbb802e03574ba"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_zone}"
  key_name = "${local.ssh_key_pair}"
  security_groups = ["${aws_security_group.worker.name}"] 
  root_block_device {
    volume_size = "${var.disk_size}"
  }
  connection {
    user = "ec2-user"
    agent = true
  }
  provisioner "remote-exec" {
    scripts = "${concat(list("${path.module}/init.sh"), var.init_scripts)}"
  }
  tags = {
    Name = "${var.tag_name}"
  }
}

# Public IP address
resource "aws_eip" "worker" {
  instance = "${aws_instance.worker.id}"
  tags = {
    Name = "${var.tag_name}"
  }
}

# Instance key-pair for SSH connecting
resource "aws_key_pair" "worker" {
  key_name   = "${local.ssh_key_pair}"
  public_key = "${var.ssh_pub_key}"
}

# Security groups to access via SSH
resource "aws_security_group" "worker" {
  name = "${local.sec_group_name}"
   ingress {
     cidr_blocks = ["0.0.0.0/0"]
     from_port = 22
     to_port = 22
     protocol = "tcp"
   }
   egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name}"
  }
}
