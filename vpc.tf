// VPC 생성
resource "aws_vpc" "KDT_Project2" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "KDT_Project2"
  }
}

// 인터넷 게이트웨이 생성 및 VPC에 연결
resource "aws_internet_gateway" "KDT_Gateway" {
  vpc_id = aws_vpc.KDT_Project2.id
  tags = {
    Name = "KDT_Gateway"
  }
}
