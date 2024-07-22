// 기본 보안 그룹 생성 및 수정
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.KDT_Project2.id

  ingress { // HTTP 포트 80 개방
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress { // SSH 포트 22 개방
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["114.70.38.239/32", "211.205.129.90/32"] 
    description = "For_Labtop and For_Desktop(Port 22)"
  }

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
    protocol    = "-1" // 이게 무슨 의미람?
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

  ingress { // SSH 포트 22 개방
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["114.70.38.239/32", "211.205.129.90/32"] 
    description = "For_Labtop and For_Desktop(Port 22)"
  }

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

  ingress { // SSH 포트 22 개방
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.4.0/24"] // Public 서브넷의 내부 IP CIDR 블록으로 Public에서만 오는 SSH 요청 허용 : 10.0.1.0 ~ 10.0.1.255
    description = "For_Labtop and For_Desktop(Port 22)"
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

  ingress { // SSH 포트 22 개방
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.4.0/24"] // Public 서브넷의 내부 IP CIDR 블록으로 Public에서만 오는 SSH 요청 허용 : 10.0.1.0 ~ 10.0.1.255
    description = "For_Labtop and For_Desktop(Port 22)"
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



/*------------------------------------------------------------------------------*/


// Private 보안 그룹의 인바운드 규칙
resource "aws_security_group_rule" "private_ssh" {
  type              = "ingress"
  from_port         = 51228
  to_port           = 51228
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24", "10.0.4.0/24"] // Public 서브넷의 내부 IP CIDR 블록으로 Public에서만 오는 SSH 요청 허용  : 10.0.1.0 ~ 10.0.1.255
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.db.id // DB 보안 그룹에서 오는 요청만 허용
  security_group_id = aws_security_group.private.id
}


/*------------------------------------------------------------------------------*/


// DB 보안 그룹의 인바운드 규칙
resource "aws_security_group_rule" "db_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.private.id // Private 보안 그룹에서 오는 요청만 허용
  security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "db_ssh" {
  type              = "ingress"
  from_port         = 51228
  to_port           = 51228
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24", "10.0.4.0/24"] // Public 서브넷의 내부 IP CIDR 블록으로 Public에서만 오는 SSH 요청 허용 : 10.0.1.0 ~ 10.0.1.255
  security_group_id = aws_security_group.db.id
}
