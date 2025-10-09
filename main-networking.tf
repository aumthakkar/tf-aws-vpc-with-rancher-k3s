resource "random_integer" "rand_int" {
  min = 1
  max = 10
}

resource "aws_vpc" "pht_vpc" {
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

resource "aws_subnet" "pht_public_subnets" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.pht_vpc.id
  map_public_ip_on_launch = true

  availability_zone = random_shuffle.az_list.result[count.index]
  cidr_block        = local.public_subnet_cidr_block[count.index]

  tags = {
    Name = "pht-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "pht_private_subnets" {
  count = var.private_subnet_count

  vpc_id                  = aws_vpc.pht_vpc.id
  map_public_ip_on_launch = true

  availability_zone = random_shuffle.az_list.result[count.index]
  cidr_block        = local.private_subnet_cidr_block[count.index]

  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "pht_igw" {
  vpc_id = aws_vpc.pht_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "pht_public_route_table" {
  vpc_id = aws_vpc.pht_vpc.id

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "pht_public_rt_association" {
  count = var.public_subnet_count

  route_table_id = aws_route_table.pht_public_route_table.id
  subnet_id      = aws_subnet.pht_public_subnets[count.index].id

}

resource "aws_route" "pht_public_route" {
  route_table_id = aws_route_table.pht_public_route_table.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pht_igw.id

}

resource "aws_default_route_table" "pht_private_route_table" {
  default_route_table_id = aws_vpc.pht_vpc.default_route_table_id

  tags = {
    Name = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_security_group" "pht_security_groups" {
  for_each = local.security_groups

  vpc_id = aws_vpc.pht_vpc.id

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

resource "aws_db_subnet_group" "pht_db_subnet_group" {
  count = var.create_db_subnet_group ? 1 : 0

  subnet_ids = aws_subnet.pht_private_subnets.*.id

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

