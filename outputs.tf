output "load_balancer_endpoint" {
  value = aws_lb.pht_lb.dns_name
}

# output "instance_ips" {
#   value = {for i in module.compute.instance_outputs : i.tags.Name => "${i.public_ip}:${module.compute.instance_port}"}
# }

# output "kubeconfig" {
#   value = [for i in module.compute.instance_outputs : "export KUBECONFIG=../k3s-${i.tags.Name}.yaml"]
# }

# Compute related Outputs
output "instance_outputs" {
  value = aws_instance.pht_node[*]
}

output "instance_port" {
  value = aws_lb_target_group_attachment.pht_lb_target_group_attachment[0].port
}

# Database related Outputs
# output "db_endpoint" {
#   value = aws_db_instance.pht_db_instance.endpoint
# }

# LoadBalancer related Outputs

/*
output "lb_target_group_arn" {
  value = aws_lb_target_group.pht_lb_target_group.arn
}

output "lb_endpoint" {
  value = aws_lb.pht_lb.dns_name
}

# Networking related Outputs

output "vpc_id" {
  value = aws_vpc.pht_vpc.id
}

/*
output "vpc_security_group_ids" {
  value = [aws_security_group.pht_security_groups["rds"].id]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.pht_db_subnet_group[*].name
}


output "public_sg" {
  value = [aws_security_group.pht_security_groups["public"].id]
}

output "public_subnets" {
  value = aws_subnet.pht_public_subnets[*].id
}
*/