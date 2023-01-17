terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIARNUDVN3IH5PO2YBX"
  secret_key = "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"
}

resource "aws_security_group" "k8s" {
    name = "k8s"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
resource "aws_instance" "k8s-master" {
    ami                    = "ami-06878d265978313ca"
    instance_type          = "t3.small"
    key_name               = "k8s"
    subnet_id              = "subnet-43c5f124"
    vpc_security_group_ids = [aws_security_group.k8s.id]
    associate_public_ip_address = true
    ebs_optimized          = false

    root_block_device {
        volume_size           = 8
        volume_type           = "gp2"
        delete_on_termination = true
        encrypted             = false
    }
    tags = {
        Name = "K8s Master"
    }
}

resource "aws_instance" "k8s-slave" {
    ami                    = "ami-06878d265978313ca"
    instance_type          = "t3.small"
    key_name               = "k8s"
    subnet_id              = "subnet-43c5f124"
    vpc_security_group_ids = [aws_security_group.k8s.id]
    associate_public_ip_address = true
    ebs_optimized          = false

    root_block_device {
        volume_size           = 8
        volume_type           = "gp2"
        delete_on_termination = true
        encrypted             = false
    }
    tags = {
        Name = "K8s Slave"
    }
}

output "ec2_k8s-master_ip" {
  value = ["${aws_instance.k8s-master.*.public_ip}"]
}
output "ec2_k8s-slave_ip" {
  value = ["${aws_instance.k8s-slave.*.public_ip}"]
}