// 로드 밸런서 생성
resource "aws_lb" "KDT_LoadBalancer" {
  name               = "KDT-LoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets            = [aws_subnet.Public_A1.id, aws_subnet.Public_B1.id]

  enable_deletion_protection = false

  tags = {
    Name = "KDT-LoadBalancer"
  }
}



/*------------------------------------------------------------------------------*/



// 대상 그룹 생성
resource "aws_lb_target_group" "KDT_Group" {
  name     = "KDT-Group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.KDT_Project2.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}



/*------------------------------------------------------------------------------*/



// 대상 그룹에 인스턴스 추가
resource "aws_lb_target_group_attachment" "A_Public" {
  target_group_arn = aws_lb_target_group.KDT_Group.arn
  target_id        = aws_instance.A_Public.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "B_Public" {
  target_group_arn = aws_lb_target_group.KDT_Group.arn
  target_id        = aws_instance.B_Public.id
  port             = 80
}



/*------------------------------------------------------------------------------*/



// 리스너 설정
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.KDT_LoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.KDT_Group.arn
  }
}
