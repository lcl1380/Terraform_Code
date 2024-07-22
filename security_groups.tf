// 기본 보안 그룹 생성 및 수정
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.KDT_Project2.id

  ingress { // HTTP 포트 80 개방
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  // ingress { // SSH 포트 22 개방
  //   from_port   = 22
  //   to_port     = 22
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"] 
  // }

  ingress { // SSH 22 -> 51228로 수정
    from_port   = 51228
    to_port     = 51228
    protocol    = "tcp"
    cidr_blocks = ["114.70.38.239/32", "211.205.129.90/32"] 
    description = "For_Labtop and For_Desktop"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // 모든 아웃바운드 트래픽 허용
  }

  tags = {
    Name = "default"
  }
}


/*------------------------------------------------------------------------------*/


// Jenkins용 보안 그룹 생성
resource "aws_security_group" "jenkins" {
  vpc_id = aws_vpc.KDT_Project2.id

  // ingress { // SSH 포트 22 개방
  //   from_port   = 22
  //   to_port     = 22
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"] 
  // }

  ingress { // 51228 포트 개방
    from_port   = 51228
    to_port     = 51228
    protocol    = "tcp"
    cidr_blocks = ["114.70.38.239/32", "211.205.129.90/32"] 
    description = "For_Labtop and For_Desktop"
  }

  ingress { // Jenkins 포트 8080 개방
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress { // 모든 아웃바운드 트래픽 허용
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "Jenkins-SecurityGroup"
  }
}


/*------------------------------------------------------------------------------*/


// Private 보안 그룹 생성
resource "aws_security_group" "private" {
  vpc_id = aws_vpc.KDT_Project2.id

  // ingress { // SSH 포트 22 개방
  //   from_port   = 22
  //   to_port     = 22
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"] 
  // }

  ingress { // 51228 포트 개방
    from_port   = 51228
    to_port     = 51228
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  // ingress { // 포트 8080 개방
  //   from_port   = 8080
  //   to_port     = 8080
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"] 
  // }

  ingress { // MySQL 포트 3306 개방
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress { // 모든 아웃바운드 트래픽 허용
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "Private-SecurityGroup"
  }
}


/*------------------------------------------------------------------------------*/


// DB용 보안 그룹 생성
resource "aws_security_group" "db" {
  vpc_id = aws_vpc.KDT_Project2.id

  ingress { // Private-SecurityGroup으로부터의 MySQL 포트 3306 개방
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.private.id] 
  }

  // ingress { // SSH 포트 22 개방 -> Setting 용도.
  //   from_port   = 22
  //   to_port     = 22
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"] 
  // }

  ingress { // SSH 포트 51228 개방 -> Setting 용도.
    from_port   = 51228
    to_port     = 51228
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress { // 모든 아웃바운드 트래픽 허용
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "DB-SecurityGroup"
  }
}
