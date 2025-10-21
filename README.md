## Example Usage

```terraform
module "networking" {
  source = "github.com/aumthakkar/tf-aws-vpc-with-rancher-k3s.git"

  name_prefix = "pht-dev"
  region      = var.region

  ssh_access_ip  = var.ssh_access_ip
  vpc_cidr_block = var.vpc_cidr_block

  public_subnet_count  = 2
  private_subnet_count = 3

  auto_create_subnet_cidr   = true
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block

  create_nat_gateway = true

  create_db_subnet_group = true
  db_storage             = 10
  db_instance_class      = "db.t3.micro"
  db_engine              = "mysql"
  db_engine_version      = "8.0.39"

  db_identifier = "pht-db"
  dbname        = var.dbname
  dbuser        = var.dbuser
  dbpassword    = var.dbpassword

  skip_db_snapshot = true

  tg_port     = 8000
  tg_protocol = "HTTP"

  lb_healthy_threshold   = 3
  lb_unhealthy_threshold = 3
  lb_interval            = 30
  lb_timeout             = 3

  lb_listener_port     = 80
  lb_listener_protocol = "HTTP"

  instance_count = 1
  instance_type  = "t3.micro"

  key_name   = "mtckey"
  public_key = var.public_key

  instance_vol_size = 10
  dbpass            = var.dbpassword

  host_port = 8000
}

```



## Description
-    This module creates an AWS VPC with all the core Networking, Load-Balancing objects consisting of:
        - Two Security groups (One public and one RDS security group)
            - In the Public security group, SSH access is kept open only for the user's single IP address which is provided in the ssh_access_ip environment variable.
        - Public and Private Subnets.
            - Based on the count of the number of subnets selected by the user in the root module, it can conditonally, automatically create those subnets along with their IP addresses using the cidrsubnet() based on the VPC CIDR block selected. 
            - However, if the user needs to use the subnet IP addresses of their choice, then those subnet IP addresses can be manually configured in the user supplied variables/*.tfvars file in the root module.
            - To do this, a value of "false" must be provided to the 'auto_create_subnet_addresses' parameter in the root module.
            - These subnets will then be created in the automatically selected, shuffled Availability Zones.  
        - Three Route tables: 
            - A Public Route Table, a Conditional Private Route table (which is created only if NAT Gateway creation is selected) alongwith their associations to the respective subnets and a default main private route table.
        - An Internet Gateway. 
        - A NAT Gateway. 
            - This NAT Gateway is conditionally created and is based on the boolean value for the create_nat_gateway argument in the root main/tf file. 
        - EC2 instance(s) as Kubernetes node(s) for the K3s Rancher Kubernetes Cluster.
            - This EC2 instance extracts the latest Ubuntu AMI for its machine image. 
        - Uploading public key onto AWS.
        - A MySQL Database.
        - Finally it  creates Rancher K3s Kubernetes Cluster which uses that MySQL DB instead of the default etcd as its database.


##### Version Requirements

| Name       | Version      |
| :--------- | :----------- |
| terraform  | >= 1.0.0     |
| aws        | >= 6.0       |

## Inputs

| Name                                           | Type         | Description                                                                                                                                  |
| :--------------------------------------------- | :----------- | :------------------------------------------------------------------------------------------------------------------------------------------- |
| name_prefix                                    | string       | Name prefix to assign to your resource names.                                                                                                |
|                                                |              |                                                                                                                                              |
| VPC related Inputs:                            |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| region                                         | string       | The AWS region for your VPC.                                                                                                                 |
| ssh_access_ip                                  | string       | User's individual public IP address.                                                                                                         |
| vpc_cidr_block                                 | string       | The VPC_CIDR of your setup.                                                                                                                  |
|                                                |              |                                                                                                                                              |
| public_subnet_count                            | number       | Number of public subnets to create.                                                                                                          |
| private_subnet_count                           | number       | Number of private subnets to create.                                                                                                         |
|                                                |              |                                                                                                                                              |
| auto_create_subnet_cidr                        | boolean      | A value of 'true' will automatically create the subnet IP addresses, a value of 'false' will abstain from creating the subnet IP addressses. |
| public_subnet_cidr_block                       | list(string) | To be entered manually if auto_create_subnet_cidr is set to false.                                                                           |
| private_subnet_cidr_block                      | list(string) | To be entered manually if auto_create_subnet_cidr is set to false.                                                                           |
|                                                |              |                                                                                                                                              |
| Database related Inputs:                       |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| create_db_subnet_group                         | boolean      | Whether to create DB subnet_group for the MySQL database. Will be needed if MySQL DB has to be created.                                      |
|                                                |              |                                                                                                                                              |
| db_storage                                     | number       | DB Storage in Gibibytes (GiB).                                                                                                               |
| db_instance_class                              | string       | DB Instance Class.                                                                                                                           |
| db_engine                                      | string       | DB Engine.                                                                                                                                   |
| db_engine_version                              | string       | DB Engine version.                                                                                                                           |
|                                                |              |                                                                                                                                              |
| db_identifier                                  | string       | DB identifier to be assigned to this database.                                                                                               |
| dbname                                         | string       | DB name to be assigned to this database.                                                                                                     |
| dbuser                                         | string       | DB user to login to this database.                                                                                                           |
| dbpassword                                     | string       | DB password to login to this database.                                                                                                       |
|                                                |              |                                                                                                                                              |
| skip_db_snapshot                               | boolean      | Whether to skip the DB snapshot at the time of deleting the DB Instance.                                                                     |
|                                                |              |                                                                                                                                              |
| Load Balancer related Inputs:                  |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| tg_port                                        | number       | Load Balancer Target group port number.                                                                                                      |
| tg_protocol                                    | string       | Load Balancer Target group protocol.                                                                                                         |
|                                                |              |                                                                                                                                              |
| lb_healthy_threshold                           | number       | Number of consecutive health check successes required before considering a target healthy. The range is 2-10. Defaults to 3.                 |
| lb_unhealthy_threshold                         | number       | Number of consecutive health check failures required before considering a target unhealthy. The range is 2-10. Defaults to 3.                |
| lb_interval                                    | number       | Approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300.                                   |
| lb_timeout                                     | number       | Amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds.                  |
|                                                |              |                                                                                                                                              |
| lb_listener_port                               | number       | LoadBalancer Listener Port.                                                                                                                  |
| lb_listener_protocol                           | string       | LoadBalancer Listener Protocol.                                                                                                              |
|                                                |              |                                                                                                                                              |
| EC2 node related inputs:                       |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| instance_count                                 | number       | The number of EC2 instances to be created.                                                                                                   |
| instance_type                                  | string       | Instance type.                                                                                                                               |
|                                                |              |                                                                                                                                              |
| key_name                                       | string       | Private key name of the key uploaded to AWS.                                                                                                 |
| public_key                                     | variable     | Pass as a variable here and its value will be picked up from the user's *.tfvars file.                                                  |
|                                                |              |                                                                                                                                              |
| instance_vol_size                              | number       | The EBS instance volume size attached to this EC2 instance.                                                                                  |
|                                                |              |                                                                                                                                              |
| host_port                                      | number       | The host port to be used by the kubernetes deployments created there.                                                                        |
|                                                |              |                                                                                                                                              |
| Resources created:                             |              |                                                                                                                                              |
|                                                |              |                                                                                                                                              |
| VPC Resources:                                 |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| aws_vpc.my_vpc                                 | resource     | AWS VPC.                                                                                                                                     |
|                                                |              |                                                                                                                                              |
| aws_availability_zones.available               | data source  | Data source to get all the possible AZ s from an AWS region.                                                                                 |
| aws_subnet.my_public_subnets                   | resource     | Public Subnets.                                                                                                                              |
| aws_route_table.my_public_route_table          | resource     | Public Route Table.                                                                                                                          |
|                                                |              |                                                                                                                                              |
| aws_internet_gateway.my_igw                    | resource     | Internet Gateway.                                                                                                                            |
|                                                |              |                                                                                                                                              |
| aws_subnet.my_private_subnets                  | resource     | Private Subnets.                                                                                                                             |
| aws_default_route_table.my_private_route_table | resource     | Default Private Route Table.                                                                                                                 |
| aws_route_table.my_private_route_table         | resource     | Private Route Table.                                                                                                                         |
|                                                |              |                                                                                                                                              |
| aws_eip.my_nat_gw_eip                          | resource     | NAT Gateway Elastic IP.                                                                                                                      |
| aws_nat_gateway.my_nat_gateway                 | resource     | NAT Gateway.                                                                                                                                 |
|                                                |              |                                                                                                                                              |
| aws_security_group.my_security_groups          | resource     | AWS VPC Security Groups.                                                                                                                     |
|                                                |              |                                                                                                                                              |
| EC2 Resources:                                 |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| aws_ami.my_instance_ami                        | resource     | AWS EC2 Ubuntu Instance AMI.                                                                                                                 |
| aws_key_pair.my_node_key                       | resource     | The Key_pair to access the EC2 instance.                                                                                                     |
|                                                |              |                                                                                                                                              |
| aws_instance.my_node                           | resource     | AWS EC2 Ubuntu Instance.                                                                                                                     |
|                                                |              |                                                                                                                                              |
| Load Balancer Resources:                       |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| aws_lb.my_lb                                   | resource     | AWS Load Balancer.                                                                                                                           |
|                                                |              |                                                                                                                                              |
| aws_lb_target_group.my_lb_target_group         | resource     | AWS Load Balancer Targt Group.                                                                                                               |
| aws_lb_listener.my_lb_listener                 | resource     | AWS Load Balancer Listener.                                                                                                                  |
|                                                |              |                                                                                                                                              |
| Database Resources:                            |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| aws_db_instance.my_db_instance                 | resource     | AWS RDS Instance.                                                                                                                            |
|                                                |              |                                                                                                                                              |
| Outputs                                        |              |                                                                                                                                              |
|                                                |              |                                                                                                                                              |
| Name                                           | Type         | Description                                                                                                                                  |
| load_balancer_endpoint                         | string       | Load Balancer DNS endpoint.                                                                                                                  |
| instance_ips                                   | string       | Instance IP and port.                                                                                                                        |
| kubeconfig                                     | string       | The command to export the kubeconfig file on the user's local workstation to connect to the K3s Kubernetes Cluster.                          |