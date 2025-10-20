data "aws_ami" "my_instance_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "random_id" "my_node_id" {
  count = var.instance_count

  byte_length = 2
  # Adding keepers below so a new random_id will be created if there is a change to key_name
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "my_node_key" {
  key_name = var.key_name

  public_key = var.public_key
}

resource "aws_instance" "my_node" {
  count = var.instance_count

  instance_type = var.instance_type
  ami           = data.aws_ami.my_instance_ami.id

  key_name = aws_key_pair.my_node_key.key_name

  vpc_security_group_ids = [aws_security_group.my_security_groups["public"].id]
  subnet_id              = aws_subnet.my_public_subnets[count.index].id

  user_data = templatefile("${path.module}/scripts/userdata.tftpl",
    {
      nodename    = "${var.name_prefix}-nodeid-${random_id.my_node_id[count.index].dec}"
      dbuser      = var.dbuser
      dbpass      = var.dbpassword
      db_endpoint = aws_db_instance.my_db_instance.endpoint
      dbname      = var.dbname
    }
  )

  tags = {
    Name = "${var.name_prefix}-nodeid-${random_id.my_node_id[count.index].dec}"
  }

  root_block_device {
    volume_size = var.instance_vol_size #10
  }

}

resource "aws_lb_target_group_attachment" "my_lb_target_group_attachment" {
  count = var.instance_count

  target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  target_id        = aws_instance.my_node[count.index].id

  port = var.host_port
}