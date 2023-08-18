resource "aws_vpc" "lamp_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lamp-vpc"
  }
}

resource "aws_subnet" "lamp_pub_1a" {
  vpc_id            = aws_vpc.lamp_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "lamp-pub-1a"
  }
}

resource "aws_subnet" "lamp_pub_1b" {
  vpc_id            = aws_vpc.lamp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "lamp-pub-1b"
  }
}

resource "aws_subnet" "lamp_app_1a" {
  vpc_id            = aws_vpc.lamp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "lamp-app-1a"
  }
}

resource "aws_subnet" "lamp_app_1b" {
  vpc_id            = aws_vpc.lamp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "lamp-app-1b"
  }
}

resource "aws_subnet" "lamp_rds_1a" {
  vpc_id            = aws_vpc.lamp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "lamp-rds-1a"
  }
}

resource "aws_subnet" "lamp_rds_1b" {
  vpc_id            = aws_vpc.lamp_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "lamp-rds-1b"
  }
}

resource "aws_internet_gateway" "lamp_igw" {
  vpc_id = aws_vpc.lamp_vpc.id

  tags = {
    Name = "lamp-igw"
  }
}

resource "aws_nat_gateway" "lamp_nat" {
  subnet_id     = aws_subnet.lamp_pub_1a.id
  allocation_id = aws_eip.lamp_eip.id

  tags = {
    Name = "lamp-nat"
  }
}

resource "aws_route_table" "lamp_pub_rt" {
  vpc_id = aws_vpc.lamp_vpc.id

  tags = {
    Name = "lamp-pub-rt"
  }
}

resource "aws_route" "lamp_pub_rt_local" {
  route_table_id         = aws_route_table.lamp_pub_rt.id
  gateway_id             = aws_vpc.lamp_vpc.id
  destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route" "lamp_pub_rt_internet" {
  route_table_id         = aws_route_table.lamp_pub_rt.id
  gateway_id             = aws_internet_gateway.lamp_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "lamp_pub_rt_local_default" {
  route_table_id         = aws_route_table.lamp_pub_rt.id
  local_gateway_id       = aws_vpc.lamp_vpc.id
  destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route_table" "lamp_app_rt" {
  vpc_id = aws_vpc.lamp_vpc.id

  tags = {
    Name = "lamp-app-rt"
  }
}

resource "aws_route" "lamp_app_rt_local" {
  route_table_id         = aws_route_table.lamp_app_rt.id
  gateway_id             = aws_vpc.lamp_vpc.id
  destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route" "lamp_app_rt_nat" {
  route_table_id         = aws_route_table.lamp_app_rt.id
  nat_gateway_id         = aws_nat_gateway.lamp_nat.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "lamp_rds_rt" {
  vpc_id = aws_vpc.lamp_vpc.id

  tags = {
    Name = "lamp-rds-rt"
  }
}

resource "aws_route" "lamp_rds_rt_local" {
  route_table_id         = aws_route_table.lamp_rds_rt.id
  gateway_id             = aws_vpc.lamp_vpc.id
  destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route_table_association" "lamp_pub_1a_assoc" {
  subnet_id      = aws_subnet.lamp_pub_1a.id
  route_table_id = aws_route_table.lamp_pub_rt.id
}

resource "aws_route_table_association" "lamp_pub_1b_assoc" {
  subnet_id      = aws_subnet.lamp_pub_1b.id
  route_table_id = aws_route_table.lamp_pub_rt.id
}

resource "aws_route_table_association" "lamp_rds_1a_assoc" {
  subnet_id      = aws_subnet.lamp_rds_1a.id
  route_table_id = aws_route_table.lamp_rds_rt.id
}

resource "aws_route_table_association" "lamp_rds_1b_assoc" {
  subnet_id      = aws_subnet.lamp_rds_1b.id
  route_table_id = aws_route_table.lamp_rds_rt.id
}

resource "aws_route_table_association" "lamp_app_1a_assoc" {
  subnet_id      = aws_subnet.lamp_app_1a.id
  route_table_id = aws_route_table.lamp_app_rt.id
}

resource "aws_route_table_association" "lamp_app_1b_assoc" {
  subnet_id      = aws_subnet.lamp_app_1b.id
  route_table_id = aws_route_table.lamp_app_rt.id
}

resource "aws_cloud9_environment_ec2" "lam_cloud9" {
  subnet_id                   = aws_subnet.lamp_pub_1b.id
  name                        = "lam-cloud9"
  instance_type               = "t2.micro"
  automatic_stop_time_minutes = 30
}

resource "aws_cloud9_environment_membership" "lam_cloud9_membership" {
  user_arn       = "arn:aws:iam::123456789012:user/demo"
  environment_id = aws_cloud9_environment_ec2.lam_cloud9.id
}

resource "aws_security_group" "lamp_cloud9_sg" {
  vpc_id      = aws_vpc.lamp_vpc.id
  name        = "lamp-cloud9-sg"
  description = "Security group for lamp-cloud9"

  tags = {
    Name = "lamp-cloud9-sg"
  }
}

resource "aws_security_group" "lamp_ingress_sg" {
  vpc_id      = aws_vpc.lamp_vpc.id
  name        = "lamp-ingress-sg"
  description = "Security group for lamp-ingress"

  tags = {
    Name = "lamp-ingress-sg"
  }
}

resource "aws_security_group_rule" "lamp_ingress_rule" {
  type              = "ingress"
  to_port           = 80
  security_group_id = aws_security_group.lamp_ingress_sg.id
  protocol          = "tcp"
  from_port         = 80

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group" "lamp_app_sg" {
  vpc_id      = aws_vpc.lamp_vpc.id
  name        = "lamp-app-sg"
  description = "Security group for lamp-app"

  tags = {
    Name = "lamp-app-sg"
  }
}

resource "aws_security_group_rule" "lamp_app_rule_1" {
  type                     = "ingress"
  to_port                  = 80
  source_security_group_id = aws_security_group.lamp_ingress_sg.id
  security_group_id        = aws_security_group.lamp_app_sg.id
  protocol                 = "tcp"
  from_port                = 80
}

resource "aws_security_group_rule" "lamp_app_rule_2" {
  type                     = "ingress"
  to_port                  = 22
  source_security_group_id = aws_security_group.lamp_cloud9_sg.id
  security_group_id        = aws_security_group.lamp_app_sg.id
  protocol                 = "tcp"
  from_port                = 22
}

resource "aws_security_group" "lamp_rds_sg" {
  vpc_id      = aws_vpc.lamp_vpc.id
  name        = "lamp-rds-sg"
  description = "Security group for lamp-rds"

  tags = {
    Name = "lamp-rds-sg"
  }
}

resource "aws_security_group_rule" "lamp_rds_rule_1" {
  type                     = "ingress"
  to_port                  = 3306
  source_security_group_id = aws_security_group.lamp_app_sg.id
  security_group_id        = aws_security_group.lamp_rds_sg.id
  protocol                 = "tcp"
  from_port                = 3306
}

resource "aws_security_group_rule" "lamp_rds_rule_2" {
  type                     = "ingress"
  to_port                  = 3306
  source_security_group_id = aws_security_group.lamp_cloud9_sg.id
  security_group_id        = aws_security_group.lamp_rds_sg.id
  protocol                 = "tcp"
  from_port                = 3306
}

resource "aws_db_subnet_group" "lamp_rds_subnet_group" {
  name        = "lamp-rds-subnet-group"
  description = "DB subnet group for LAMP RDS"

  subnet_ids = [
    aws_subnet.lamp_rds_1a.id,
    aws_subnet.lamp_rds_1b.id,
  ]

  tags = {
    Name = "lamp-rds-subnet-group"
  }
}

resource "aws_db_instance" "lamp_rds_mysql" {
  username             = "admin"
  storage_type         = "gp2"
  skip_final_snapshot  = true
  password             = "123456"
  name                 = "lamp-rds-mysql"
  multi_az             = true
  instance_class       = "db.t2.micro"
  engine_version       = "5.7"
  engine               = "mysql"
  db_subnet_group_name = aws_db_subnet_group.lamp_rds_subnet_group.name
  allocated_storage    = 20

  tags = {
    Name = "lamp-rds-mysql"
  }

  vpc_security_group_ids = [
    aws_security_group.lamp_rds_sg.id,
  ]
}

resource "aws_instance" "lamp_linux" {
  subnet_id     = aws_subnet.lamp_app_1a.id
  instance_type = "t2.micro"
  count         = 1
  ami           = "ami-0c55b159cbfafe1f0"

  security_groups = [
    aws_security_group.lamp_app_sg.id,
  ]

  tags = {
    Name = "lamp-linux"
  }
}

resource "aws_lb" "lamp_alb" {
  name                       = "lamp-alb"
  load_balancer_type         = "application"
  internal                   = false
  enable_http2               = true
  enable_deletion_protection = false

  security_groups = [
    aws_security_group.lamp_ingress_sg.id,
  ]

  subnets = [
    aws_subnet.lamp_pub_1a.id,
    aws_subnet.lamp_pub_1b.id,
  ]
}

resource "aws_lb_target_group" "lamp_alb_target_group" {
  vpc_id      = aws_vpc.lamp_vpc.id
  protocol    = "HTTP"
  port        = 80
  name_prefix = "lamp-alb-tg-"

  health_check {
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    matcher             = "200,301,302"
    interval            = 10
    healthy_threshold   = 2
  }
}

resource "aws_launch_configuration" "lamp_linux_launch_config" {
  name          = "lamp-linux"
  key_name      = aws_key_pair.lamp_key.key_name
  instance_type = "t3"
  image_id      = "lamp-linux"

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    aws_security_group.lamp_app_sg.name,
  ]
}

resource "aws_autoscaling_group" "lamp_asg" {
  name                 = "lamp-asg"
  min_size             = 2
  max_size             = 2
  launch_configuration = aws_launch_configuration.lamp_linux_launch_config.name
  health_check_type    = "ELB"
  desired_capacity     = 2

  tags {
    value               = "lamp-linux"
    propagate_at_launch = true
    key                 = "Name"
  }

  target_group_arns = [
    aws_lb_target_group.lamp_alb_target_group.arn,
  ]

  vpc_zone_identifier = [
    aws_subnet.lamp_pub_1a.id,
    aws_subnet.lamp_pub_1b.id,
  ]
}

