
####keypair
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key-2"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "${path.module}/my-key-2.pem"
  file_permission = "0400"

}

### Network
#vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

}

##subnet public

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "sa-east-1a"

}


### internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

}



## Route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

## SG
# public sg
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
### Data source
data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
}

### ec2 instances
# public instance

resource "aws_instance" "public_instance" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id

  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  associate_public_ip_address = true

  user_data = file("user-data.sh")

  tags = {
    Name = "Public-Server"
  }

}


## output 
output "publicip_public_instance" {
  value = aws_instance.public_instance.public_ip
}