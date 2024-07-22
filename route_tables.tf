// Public 라우팅 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.KDT_Project2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.KDT_Gateway.id // 인터넷 게이트웨이로 연결
  }
  tags = {
    Name = "public"
  }
}

// Public 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "public_a1" {
  subnet_id      = aws_subnet.Public_A1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b1" {
  subnet_id      = aws_subnet.Public_B1.id
  route_table_id = aws_route_table.public.id
}

// Elastic IP 생성 (NAT 게이트웨이용)
resource "aws_eip" "nat_eip_a" {
  vpc = true
}

resource "aws_eip" "nat_eip_b" {
  vpc = true
}

// NAT 게이트웨이 생성 및 Public 서브넷에 연결
resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.Public_A1.id
  tags = {
    Name = "Gateway_A"
  }
}

resource "aws_nat_gateway" "nat_gateway_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.Public_B1.id
  tags = {
    Name = "Gateway_B"
  }
}


/*------------------------------------------------------------------------------*/


// Private 라우팅 테이블 생성 및 NAT 게이트웨이로 연결
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.KDT_Project2.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
  }
  tags = {
    Name = "A_Private_RouteTable"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.KDT_Project2.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_b.id
  }
  tags = {
    Name = "B_Private_RouteTable"
  }
}


/*------------------------------------------------------------------------------*/


// Private 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "private_a2" {
  subnet_id      = aws_subnet.Private_A2.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_a3" {
  subnet_id      = aws_subnet.Private_A3.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b2" {
  subnet_id      = aws_subnet.Private_B2.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route_table_association" "private_b3" {
  subnet_id      = aws_subnet.Private_B3.id
  route_table_id = aws_route_table.private_b.id
}
