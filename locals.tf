
locals {
  security_groups = {
    public = {
      name        = "pht-public-sg"
      description = "public-sg open only to your connection"
      tags = {
        Name = "pht-public-sg"
      }

      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.ssh_access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        nginx = {
          from        = 8000
          to          = 8000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    rds = {
      name        = "${var.name_prefix}-rds-sg"
      description = "mysql-sg only for your VPC"
      tags = {
        Name = "${var.name_prefix}-rds-sg"
      }
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [var.vpc_cidr_block]
        }
      }
    }
  }
}


# Networking related locals.terraform {
locals {
  public_cidr  = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr_block, 8, i)]
  private_cidr = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr_block, 8, i)]
}

locals {
  public_subnet_cidr_block  = var.auto_create_subnet_cidr ? local.public_cidr : split(",", var.public_subnet_cidr_block)
  private_subnet_cidr_block = var.auto_create_subnet_cidr ? local.private_cidr : split(",", var.private_subnet_cidr_block)
}

