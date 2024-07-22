variable "key_pair_content" {
  description = "Content of the key pair"
  type        = string
}

// 키 페어를 bastion, public, private1에 전달 (SSH 접속 용도)
// 변수 파일(variables.tf)을 생성하고, terraform.tfvars 파일을 사용하여 값을 지정할 수 있음