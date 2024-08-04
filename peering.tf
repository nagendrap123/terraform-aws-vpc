resource "aws_vpc_peering_connection" "peering" {
    count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = var.acceptor_vpc_d == "" ? data.aws_vpc.default.id : var.acceptor_vpc_d  #acceptor VPC ID 
  vpc_id        = aws_vpc.main.id  #requestor VPC ID
  auto_accept = var.acceptor_vpc_d == "" ? true : false 
}

