output "load_balancer_endpoint" {
  value = aws_lb.my_lb.dns_name
}

output "instance_ips" {
  value = { for i in aws_instance.my_node[*] : i.tags.Name => "${i.public_ip}:${aws_lb_target_group_attachment.my_lb_target_group_attachment[0].port}" }
}

output "kubeconfig" {
  value = [for i in aws_instance.my_node[*] : "export KUBECONFIG=./k3s-${i.tags.Name}.yaml"]
}

# Compute related Outputs
output "instance_outputs" {
  value = aws_instance.my_node[*]
}

output "instance_port" {
  value = aws_lb_target_group_attachment.my_lb_target_group_attachment[0].port
}

# Database related Outputs

output "db_endpoint" {
  value = aws_db_instance.my_db_instance.endpoint
}

# LoadBalancer related Outputs


output "lb_target_group_arn" {
  value = aws_lb_target_group.my_lb_target_group.arn
}

output "lb_endpoint" {
  value = aws_lb.my_lb.dns_name
}

# Networking related Outputs

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}


output "vpc_security_group_ids" {
  value = [aws_security_group.my_security_groups["rds"].id]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.my_db_subnet_group[*].name
}


output "public_sg" {
  value = [aws_security_group.my_security_groups["public"].id]
}

output "public_subnets" {
  value = aws_subnet.my_public_subnets[*].id
}
