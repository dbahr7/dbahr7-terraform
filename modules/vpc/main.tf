module "vpc_cidrs" { source = "../vpc_cidrs" }

resource "aws_vpc" "main" {
  cidr_block = module.vpc_cidrs.cidrs[var.environment]["vpc"]

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["a"].id

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}"
  }
}

# public

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  for_each          = module.vpc_cidrs.cidrs[var.environment]["subnets"]["public"]
  cidr_block        = each.value
  availability_zone = "${var.region}${each.key}"

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = { for key, subnet in aws_subnet.public : key => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# private-compute

resource "aws_subnet" "private-compute" {
  vpc_id = aws_vpc.main.id

  for_each          = module.vpc_cidrs.cidrs[var.environment]["subnets"]["private-compute"]
  cidr_block        = each.value
  availability_zone = "${var.region}${each.key}"

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}-private-compute-${each.key}"
    Tier = "private-compute"
  }
}

resource "aws_route_table" "private-compute" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}-private-compute"
  }
}

resource "aws_route_table_association" "private-compute" {
  for_each       = { for key, subnet in aws_subnet.private-compute : key => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private-compute.id
}

# private-data
resource "aws_subnet" "private-data" {
  vpc_id = aws_vpc.main.id

  for_each          = module.vpc_cidrs.cidrs[var.environment]["subnets"]["private-data"]
  cidr_block        = each.value
  availability_zone = "${var.region}${each.key}"

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}-private-data-${each.key}"
    Tier = "private-data"
  }
}

resource "aws_route_table" "private-data" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.application}-${var.environment}-${var.purpose}-private-data"
  }
}

resource "aws_route_table_association" "private-data" {
  for_each       = { for key, subnet in aws_subnet.private-data : key => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private-data.id
}
