// 가용영역 b의 DB는 RDS(MySQl) 이용하여 연동 할 **예정**

resource "aws_instance" "B_Public" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Public_B1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "B_Public"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname b-public
              echo "127.0.1.1 b-public" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!" 

              # Nginx 및 OpenJDK 17 설치
              sudo apt-get update -y
              sudo apt-get install -y curl gnupg2 ca-certificates lsb-release

              # ubuntu-keyring 패키지 설치
              sudo apt-get install -y ubuntu-keyring

              # nginx.list 파일 생성 : 공식 저장소에서 서명 키 가져오기
              curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
                  | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

              # 다운로드한 키가 올바른지 확인
              gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

              # 저장소 설정 (Stable version)
              echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
              http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" \
                  | sudo tee /etc/apt/sources.list.d/nginx.list

              # 저장소 업데이트
              sudo apt-get update -y

              # nginx 설치
              sudo apt-get install -y nginx

              # nginx 버전 확인
              nginx -v

              # nginx 가동 시작
              sudo systemctl start nginx

              EOF
}

resource "aws_eip" "b_public_eip" {
  instance = aws_instance.B_Public.id
  vpc      = true
}

/*------------------------------------------------------------------------------*/

resource "aws_instance" "B_Private01" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Private_B2.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "B_Private01"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname b-private01
              echo "127.0.1.1 b-private01" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!" 

              EOF
}


resource "aws_instance" "B_Private02" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Private_B2.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "B_Private02"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname b-private02
              echo "127.0.1.1 b-private02" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!" 

              EOF
}

/*------------------------------------------------------------------------------*/

resource "aws_instance" "B_Private03" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.Private_B3.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "B_Private_DB"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-private-db
              echo "127.0.1.1 a-private-db" >> /etc/hosts

              # MySQL 설치
              sudo apt update
              sudo apt install -y mysql-server

              # MySQL 설정 파일 수정 (bind-address 주석 처리 또는 0.0.0.0으로 변경)
              sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

              # MySQL 서비스 시작 및 활성화
              sudo systemctl start mysql
              sudo systemctl enable mysql

              # MySQL root 유저 비밀번호 설정 및 사용자 생성
              sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '51228';"

              # MySQL 서비스 재시작
              sudo systemctl restart mysql
              EOF
}