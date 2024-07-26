// 가용영역 a의 DB는 Ubuntu 인스턴스 내에 MySQL 설정하여 연동
// 옵션에 -y 부여해야 하는지 아닌지 잘 보기 !!!!

resource "aws_instance" "bastion" {
  // Ubuntu 24.04 -> 22.04로 교체
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Public_A1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "Bastion_Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname Bastion-instance
              echo "127.0.1.1 Bastion-instance" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!"              

              # Docker 및 Jenkins 설치
              sudo apt update -y
              sudo apt-get install -y ca-certificates curl gnupg

              sudo install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              sudo chmod a+r /etc/apt/keyrings/docker.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              sudo apt update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              # 자바 설치
              sudo apt update -y
              sudo apt install -y openjdk-17-jdk

              # 젠킨스 설치
              sudo apt update

              # Jenkins 공식 키 가져오기
              curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null

              # Jenkins 레포지토리 추가
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null

              sudo apt update -y
              sudo apt install -y jenkins

              # Jenkins 서비스를 시작하고 부팅 시 자동으로 시작하도록 설정
              sudo systemctl start jenkins
              sudo systemctl enable jenkins

              echo "Docker와 Jenkins 설치가 완료되었습니다."
              EOF
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  vpc      = true
}

# -----------Logging & Grafana-----------------------

resource "aws_instance" "Logging" { // 로깅 서버
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Public_A1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "Logging"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-logging
              echo "127.0.2.1 a-logging" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!" 

              EOF
}

/*------------------------------------------------------------------------------*/



resource "aws_instance" "A_Public" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Public_A1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "A_Public"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-public
              echo "127.0.1.1 a-public" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!"

              # Nginx 및 OpenJDK 17 설치
              sudo apt update -y
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
              sudo apt update -y

              # nginx 설치
              sudo apt-get install -y nginx

              # nginx 버전 확인
              nginx -v

              # nginx 가동 시작
              sudo systemctl start nginx
              EOF
}

resource "aws_eip" "a_public_eip" {
  instance = aws_instance.A_Public.id
  vpc      = true
}

/*------------------------------------------------------------------------------*/


resource "aws_instance" "A_Private01" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Private_A2.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "A_Private01"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-private01
              echo "127.0.2.1 a-private01" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!" 
              EOF
}

resource "aws_instance" "A_Private02" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Private_A2.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "A_Private02"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-private02
              echo "127.0.2.1 a-private02" >> /etc/hosts

              # PEM 파일 생성 및 권한 설정
              echo "${var.key_pair_content}" > /home/ubuntu/KDT_Project2_AWS.pem
              chmod 444 /home/ubuntu/KDT_Project2_AWS.pem
              echo "PEM 파일 생성 및 권한 설정 성공!" 

              EOF
}

/*------------------------------------------------------------------------------*/



resource "aws_instance" "A_Private03" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Private_A3.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "A_Private_DB"
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