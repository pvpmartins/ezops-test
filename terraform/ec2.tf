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

  tags = {
    Name = "MainRouteTable"
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
    from_port   = 0 
    to_port     = 65535
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
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
  key_name   = "teste-paulo-key-2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClvi5JataXIAp9DeDoM67lykgnKU8Kkf2lvGLCc76K3K1li6GPAGnoiC8P6FxZoSoo3F1xnMBcL9mDrjZ0skuZGwvq5kTYt/qiZQJDLt5C+nZt+bGBkHoqsKCcbXDOrtpUnH5lA7u/p1VucPvOBMytIUr2nfx5sDK/sTEBHLgRUGyscnVtWSNRGDDMKYsSlCJ7thzeUqxheHFiOBU4Mx5OzHXVmq/93nMkALXEIpvMdF6bliskHNN2y3CN/3WvFUnFz1UPu6Hk9YDPXZHgX/osngzM3ua99lMjP3Wc1XL9Br680ATx54wuqmgQPZsBlCHlTg/mglXLBdFfW5UjZ3IZs9coBb58xQicovYbN9TUdiPqk8CbNFWXqkAD8D7cDQ/tFSzqfQ+8rlE4swLIWClvBiShlm+9CfKxEPL8KEB1/Jvk03y+LKaLmCJW0RZE8FJIDzEY1spHGhBpi+X6Uiwu6Np+qhH25O5Kp+wqrqjE0Gvmrf0TXX0hMseYMTqWw74DaAJu8pXWQfCBJVxUpvp7n1Rzn5DkMzMx/WQqGkLqLP3AtXj4cvEHgv6LNk/h+JlmPbS//D76F1/HtgN8lVBFlF3qAVFyowtRx77uMu/2hKinbT62AfBJTIuxaxEU6IrAwWfJXHQaglMxYOM6+1kyTTod/H+eafCMTBTY4fod9w== pvpmartins@hotmail.com"
}
