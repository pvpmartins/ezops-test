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
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no = 100
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  }

  egress {
    rule_no = 100
    protocol    = "-1"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "AllowAllACL"
  }
}

resource "aws_network_acl_association" "public" {
  subnet_id     = aws_subnet.public.id
  network_acl_id = aws_network_acl.main.id
}

resource "aws_network_acl_association" "main" {
  subnet_id     = aws_subnet.main.id
  network_acl_id = aws_network_acl.main.id
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

resource "aws_key_pair" "deployer" {
  key_name   = "teste-paulo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCruLY7CXArU8UQ2+d+IS2ijTf4Yn9B0Coj4rXF9io2+K4T3e/HXE6zSSkYegJYskcETARMRcCl4nc5XSKxwxxyJGpZCNt166JyfGyjZUkw5dtmqlc+DXwSjslv61opsmDQMmPuNdnFUQf0Jo/jilYAOldD3Ni1GDZE0Y/lQZZ733mdZXXUc6oh+O5EuV1wh7026w21vhc4t0OilIePW7JMaTSPzxOvC9/JYqBaiCqJ5DsGgsx01hURnAJDrnSo5paqoF1xJsb+b2dXjRaLSlVLjQiwjAkkiA8X/5DyNngk9CG/wLjOZLoNKnII5bTNvX6sXKOo9P5D1Z5eCGpTNsg3AkjO6OuFu2ED0mc3vhyLFSfewOtj/uUCg9vxK8TDaAJedddQ214nU97beaOAAhQoaS8sMZBQU0pnjaPx2XOgXly066Z35doRkLE3OgIFzVoM9S/mCFRAM4ongQwDwpsPEcImoX00vXkBuMUgHb1soMOaQrfF6zJprvh5rxvXvOUI7NVswBQeYPsyb2cmXpB/P2MZ3zChfB2SLdNHLfcDZB0y7fqEtc6qar+C7bAy3/S4dK9YqvVZ0Z96tHIlMMt0Lk36AjgTTn8wjZlwxitED0tQfSa1Ps6+FgZZiuZOHSyjZvHjcIaByvcgqarVZOeZEqEo+o+1BXZQUWNRzvWErw== pvpmartins@hotmail.com
"
}
