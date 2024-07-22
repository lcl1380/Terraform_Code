// 서브넷 생성 (ap-northeast-2a 가용영역)
resource "aws_subnet" "Public_A1" {
  vpc_id     = aws_vpc.KDT_Project2.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a" // 가용 영역 지정
  tags = {
    Name = "Public_A1" // 서브넷 이름 태그
  }
}

resource "aws_subnet" "Private_A2" {
  vpc_id     = aws_vpc.KDT_Project2.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "Private_A2"
  }
}

resource "aws_subnet" "Private_A3" {
  vpc_id     = aws_vpc.KDT_Project2.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "Private_A3"
  }
}


/*------------------------------------------------------------------------------*/


// 서브넷 생성 (ap-northeast-2b 가용영역)
resource "aws_subnet" "Public_B1" {
  vpc_id     = aws_vpc.KDT_Project2.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "Public_B1"
  }
}

resource "aws_subnet" "Private_B2" {
  vpc_id     = aws_vpc.KDT_Project2.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "Private_B2"
  }
}

resource "aws_subnet" "Private_B3" {
  vpc_id     = aws_vpc.KDT_Project2.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "Private_B3"
  }
}
