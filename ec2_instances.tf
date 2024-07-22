resource "aws_instance" "jenkins" {
  ami           = "ami-062cf18d655c0b1e8" // Ubuntu 24.04 이미지 ID
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Public_A1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.jenkins.id]

  tags = {
    Name = "Jenkins_Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname jenkins-instance
              echo "127.0.1.1 jenkins-instance" >> /etc/hosts

              # SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # Docker 및 Jenkins 설치
              sudo apt-get update
              sudo apt-get install -y ca-certificates curl gnupg

              sudo install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              sudo chmod a+r /etc/apt/keyrings/docker.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              sudo apt-get update
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              # 자바 설치
              sudo apt update
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

              sudo apt update
              sudo apt install -y jenkins

              # 빌드를 위해 gradle 설치
              sudo apt install -y gradle


              # Jenkins 서비스를 시작하고 부팅 시 자동으로 시작하도록 설정
              sudo systemctl start jenkins
              sudo systemctl enable jenkins

              echo "Docker와 Jenkins 설치가 완료되었습니다."
              EOF
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  vpc      = true
}



/*------------------------------------------------------------------------------*/



resource "aws_instance" "A_Public" {
  ami           = "ami-062cf18d655c0b1e8"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Public_A1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.default.id]

  tags = {
    Name = "A_Public"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-public
              echo "127.0.1.1 a-public" >> /etc/hosts

              SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # Nginx 및 OpenJDK 17 설치
              sudo apt-get update
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
              sudo apt-get update

              # nginx 설치
              sudo apt-get install -y nginx

              # nginx 버전 확인
              nginx -v

              # nginx 가동 시작
              sudo systemctl start nginx

              # OpenJDK 17 설치
              sudo apt update
              sudo apt install -y openjdk-17-jdk
              EOF
}

resource "aws_eip" "a_public_eip" {
  instance = aws_instance.A_Public.id
  vpc      = true
}



/*------------------------------------------------------------------------------*/



resource "aws_instance" "A_Private01" {
  ami           = "ami-062cf18d655c0b1e8"
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

              # SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # OpenJDK 17 설치
              sudo apt update
              sudo apt install -y openjdk-17-jdk
              EOF
}



/*------------------------------------------------------------------------------*/



resource "aws_instance" "A_Private02" {
  ami           = "ami-062cf18d655c0b1e8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Private_A3.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "A_Private02"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname a-private02
              echo "127.0.1.1 a-private02" >> /etc/hosts

              # SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # MySQL 설치
              sudo apt update
              sudo apt install -y mysql-server
              sudo systemctl start mysql
              sudo systemctl enable mysql
              sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '51228';"
              sudo mysql -e "CREATE USER 'cherish'@'%' IDENTIFIED BY '51228';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'cherish'@'%' WITH GRANT OPTION;"
              sudo mysql -e "FLUSH PRIVILEGES;"
              EOF
}



/*------------------------------------------------------------------------------*/



resource "aws_instance" "B_Public" {
  ami           = "ami-062cf18d655c0b1e8"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Public_B1.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.default.id]

  tags = {
    Name = "B_Public"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname b-public
              echo "127.0.1.1 b-public" >> /etc/hosts

              # SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # Nginx 및 OpenJDK 17 설치
              sudo apt-get update
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
              sudo apt-get update

              # nginx 설치
              sudo apt-get install -y nginx

              # nginx 버전 확인
              nginx -v

              # nginx 가동 시작
              sudo systemctl start nginx

              # OpenJDK 17 설치
              sudo apt update
              sudo apt install -y openjdk-17-jdk
              EOF
}

resource "aws_eip" "b_public_eip" {
  instance = aws_instance.B_Public.id
  vpc      = true
}



/*------------------------------------------------------------------------------*/



resource "aws_instance" "B_Private01" {
  ami           = "ami-062cf18d655c0b1e8"
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

              # SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # OpenJDK 17 설치
              sudo apt update
              sudo apt install -y openjdk-17-jdk

              EOF
}



/*------------------------------------------------------------------------------*/



resource "aws_instance" "B_Private02" {
  ami           = "ami-062cf18d655c0b1e8"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Private_B3.id
  key_name      = "KDT_Project2_AWS"

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "B_Private02"
  }

  user_data = <<-EOF
              #!/bin/bash
              # 호스트 이름 변경
              hostnamectl set-hostname b-private02
              echo "127.0.1.1 b-private02" >> /etc/hosts

              # SSH 포트 변경
              sed -i 's/#Port 22/Port 51228/' /etc/ssh/sshd_config
              systemctl restart sshd

              # MySQL 설치
              sudo apt update
              sudo apt install -y mysql-server
              sudo systemctl start mysql
              sudo systemctl enable mysql
              sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '51228';"
              sudo mysql -e "CREATE USER 'cherish'@'%' IDENTIFIED BY '51228';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'cherish'@'%' IDENTIFIED BY '51228' WITH GRANT OPTION;""
              sudo mysql -e "FLUSH PRIVILEGES;"
              EOF
}
