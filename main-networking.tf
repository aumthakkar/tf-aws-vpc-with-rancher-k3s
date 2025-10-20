resource "random_integer" "rand_int" {
  min = 1
  max = 10
}

resource "aws_vpc" "my_vpc" {
  lifecycle {
    create_before_destroy = true
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.name_prefix}-vpc-${random_integer.rand_int.result}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names

  result_count = 10
}

resource "aws_subnet" "my_public_subnets" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true

  availability_zone = random_shuffle.az_list.result[count.index]
  cidr_block        = local.public_subnet_cidr_block[count.index]

  tags = {
    Name = "my-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "my_private_subnets" {
  count = var.private_subnet_count

  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true

  availability_zone = random_shuffle.az_list.result[count.index]
  cidr_block        = local.private_subnet_cidr_block[count.index]

  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "my_public_rt_association" {
  count = var.public_subnet_count

  route_table_id = aws_route_table.my_public_route_table.id
  subnet_id      = aws_subnet.my_public_subnets[count.index].id

}

resource "aws_route" "my_public_route" {
  route_table_id = aws_route_table.my_public_route_table.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id

}

resource "aws_default_route_table" "default_private_route_table" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  tags = {
    Name = "${var.name_prefix}-main-default-private-route-table"
  }
}


resource "aws_route_table" "my_private_route_table" {
  count = var.create_nat_gateway ? 1 : 0

  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_eip" "my_nat_gw_eip" {
  count = var.create_nat_gateway ? 1 : 0
  depends_on = [aws_internet_gateway.my_igw]

  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-gw-eip"
  }
}


resource "aws_nat_gateway" "my_nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0
  depends_on = [aws_internet_gateway.my_igw]

  allocation_id = aws_eip.my_nat_gw_eip[0].id
  subnet_id     = aws_subnet.my_public_subnets[0].id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
}

resource "aws_route_table_association" "my_private_rt_association" {
  count = var.create_nat_gateway ? var.private_subnet_count : 0

  route_table_id = try(aws_route_table.my_private_route_table[0].id, null)
  subnet_id      = aws_subnet.my_private_subnets[count.index].id
}


resource "aws_route" "my_private_route" {
  count = var.create_nat_gateway ? 1 : 0

  route_table_id = aws_route_table.my_private_route_table[0].id
  gateway_id             = aws_nat_gateway.my_nat_gateway[0].id

  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_security_group" "my_security_groups" {
  for_each = local.security_groups

  vpc_id = aws_vpc.my_vpc.id

  name        = each.value.name
  description = each.value.description
  tags        = each.value.tags

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  count = var.create_db_subnet_group ? 1 : 0

  subnet_ids = aws_subnet.my_private_subnets.*.id

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

