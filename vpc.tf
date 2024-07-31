### VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.tags,
    {
      Name = local.resource_name

    }
  )
}
## IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.resource_name

    }
  )
  
}
### public subnet 
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

 tags = merge(
  var.common_tags,
  var.public_subnet_cidrs_tags,
  {
    Name = "${local.resource_name}-public-${local.az_names[count.index]}"
  }
 )
}
#### private subnet 
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

 tags = merge(
  var.common_tags,
  var.private_subnet_cidrs_tags,
  {
    Name = "${local.resource_name}-private-${local.az_names[count.index]}"
  }
 )
}
#### database subnet 
resource "aws_subnet" "database" { # create database[0], and database[1]
  count = length(var.database_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

 tags = merge(
  var.common_tags,
  var.database_subnet_cidrs_tags,
  {
    Name = "${local.resource_name}-database-${local.az_names[count.index]}"
  }
 )
}

###create eip ##
resource "aws_eip" "nat" {
  domain   = "vpc"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  #we are giving nat for one availability zone

  tags = merge(
  var.common_tags,
  var.nat_tags,
  {
    Name = "${local.resource_name}"
  }
 )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]  #explicity dependancy
}

##public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
  var.common_tags,
  var.public_route_table_tags,
  {
    Name = "${local.resource_name}-public"
  }
 )
}
##private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
  var.common_tags,
  var.private_route_table_tags,
  {
    Name = "${local.resource_name}-private"
  }
 )
}

## database route table 
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
  var.common_tags,
  var.database_route_table_tags,
  {
    Name = "${local.resource_name}-database"
  }
 )
}

#public route 
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route_nat" {
  destination_cidr_block    = "0.0.0.0/0"
  route_table_id            = aws_route_table.private.id
  nat_gateway_id = aws_nat_gateway.nat.id
}
resource "aws_route" "database_route_nat" {
  destination_cidr_block    = "0.0.0.0/0"
  route_table_id            = aws_route_table.database.id
  nat_gateway_id = aws_nat_gateway.nat.id
}

## route table association with subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[*].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[*].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[*].id
  route_table_id = aws_route_table.database.id
}