variable "name_prefix" {}

variable "region" {}

# variable "public_subnet_cidr_block" {}
# variable "private_subnet_cidr_block" {}

variable "ssh_access_ip" {}

# Networking related variables

variable "vpc_cidr_block" {}

variable "auto_create_subnet_cidr" {
  type        = bool
  description = "to decide if subnet cidr creation automatically or manually"
}
variable "public_subnet_count" {}
variable "private_subnet_count" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}

# variable "security_groups" {}

variable "create_db_subnet_group" {
  type        = bool
  description = "Decision whether to create db_subet_group"
}


# Database related variables
variable "db_storage" {}
variable "db_instance_class" {}

variable "db_engine" {}
variable "db_engine_version" {}

variable "db_identifier" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}

variable "skip_db_snapshot" {}


# LoadBalancer related Variables
variable "tg_port" {}
variable "tg_protocol" {}

variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_interval" {}
variable "lb_timeout" {}

variable "lb_listener_port" {}
variable "lb_listener_protocol" {}

# Compute related variables
variable "key_name" {}
variable "public_key" {}
variable "private_key" {}

variable "public_key_path" {}

variable "instance_count" {}
variable "instance_type" {}

# variable "public_sg" {}
# variable "public_subnets" {}

# variable "dbuser" {}
variable "dbpass" {}
# variable "db_endpoint" {}
# variable "dbname" {}

variable "instance_vol_size" {}

variable "private_key_path" {}

# variable "lb_target_group_arn" {}
variable "host_port" {}


