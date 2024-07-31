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
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

 tags = merge(
  var.common_tags,
  var.public_subnet_cidrs_tags,
  {
    Name = "${local.resource_name}-${local.az_names[count.index]}"
  }
 )
}