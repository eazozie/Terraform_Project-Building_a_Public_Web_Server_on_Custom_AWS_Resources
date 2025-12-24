


data "aws_key_pair" "existing" {
  key_name = "awesome-key-east1" 
}

#Step 1. Create vpc 

resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "192.168.0.0/16"
  
  tags = {
    Name = "terraform_vpc"
  }
}


#Step 2. Create internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "Terraform_gw"
  }
}

#Step 3. Create custom route table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terra_route_table"
  }
}

#Step 4. Create a subnet

resource "aws_subnet" "Terraform_Pub_Subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}


#Step 5. Associate subnet with route table 


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Terraform_Pub_Subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

#Step 6. Create security group to allow port 22, 80, and 443

resource "aws_security_group" "allow_rules" {
  name        = "Terraform_custom-web-sg"
  description = "Allow this inbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description = "Allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["134.41.221.117/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform_custom-web-sg"
  }
}

#Step 7. Create a network interface with an IP in the subnet that was created in step 4

resource "aws_network_interface" "interface1" {
  subnet_id       = aws_subnet.Terraform_Pub_Subnet.id
  private_ips     = ["192.168.1.10"]
  security_groups = [aws_security_group.allow_rules.id]


}

#Step 8. Assign an elastic IP to the network interface created in step 7


resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.interface1.id
  associate_with_private_ip = "192.168.1.10"
  depends_on = [ aws_internet_gateway.gw ]
}

#Step 9. Create an ubuntu server and installl and enable apache2

resource "aws_instance" "Terraform_webserver" {

    #Arguments
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t3.micro"
    availability_zone = "us-east-1a"
    key_name = data.aws_key_pair.existing.key_name
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.interface1.id
    }

    user_data = <<EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                echo " Deployed via Terraform " > /var/www/html/index.html
                EOF

    tags = {
        Name = "Apache_web_Server"
    }
}