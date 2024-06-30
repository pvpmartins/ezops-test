resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "sa-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  #  availability_zone       = "sa-east-1a" 
  map_public_ip_on_launch = true
}
resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowAllSG"
  }
}
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_instance" "master" {
  ami                    = "ami-04716897be83e3f04"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.ec2_key_name

  user_data = file("../${path.root}/kubernetes/setup.sh")

  tags = {
    Name = "Kubernetes-Master"
  }
}

resource "aws_instance" "worker" {
  count                  = 2
  ami                    = "ami-04716897be83e3f04"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.ec2_key_name

  user_data = file("../${path.root}/kubernetes/setup.sh")

  tags = {
    Name = "Kubernetes-Worker-${count.index + 1}"
  }
}

