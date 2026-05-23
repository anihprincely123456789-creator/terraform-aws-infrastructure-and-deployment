# Terraform AWS Website Deployment

## Project Overview

This project demonstrates how to provision AWS infrastructure and deploy a static website automatically using Terraform.

The project follows Infrastructure as Code (IaC) principles by automating the creation and configuration of cloud resources instead of manually configuring them through the AWS Console.

The deployed infrastructure includes:

- Custom VPC
- Public Subnet
- Internet Gateway
- Route Table
- Security Group
- EC2 Instance
- Apache Web Server

The website is automatically deployed during EC2 instance creation using a user-data script.

---

# Technologies Used

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| AWS | Cloud Platform |
| EC2 | Virtual Server Hosting |
| VPC | Network Isolation |
| Apache | Web Server |
| Linux | Operating System |

---

# Project Structure

```text
terraform-aws-website-deployment/
│
├── provider.tf
├── main.tf
├── outputs.tf
├── user-data.sh
└── README.md
```

---

# Provider Configuration

## File: `provider.tf`

```hcl
provider "aws" {
  region = sa-east-1
}
```

### Explanation

This block configures Terraform to use AWS as the cloud provider.

| Component | Meaning |
|---|---|
| provider "aws" | Specifies AWS as the cloud provider |
| region | Defines the AWS region for deployment |
| var.region | Uses a Terraform variable instead of hardcoding |


---

# VPC Configuration

## File: `main.tf`

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}
```

### Explanation

This resource creates a Virtual Private Cloud (VPC), which acts as the main network container for the infrastructure.

| Component | Meaning |
|---|---|
| aws_vpc | AWS Terraform resource type |
| main | Local Terraform resource name |
| cidr_block | Defines the IP address range |
| tags | Adds labels to AWS resources |

---

# Public Subnet Configuration

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}
```

### Explanation

This block creates a public subnet inside the VPC.

| Setting | Purpose |
|---|---|
| vpc_id | Connects subnet to the VPC |
| cidr_block | Defines subnet IP range |
| map_public_ip_on_launch | Automatically assigns public IPs |

This allows EC2 instances launched in the subnet to be accessible from the internet.

---

# Internet Gateway Configuration

```hcl
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}
```

### Explanation

The Internet Gateway allows resources inside the VPC to communicate with the internet.

Without this resource:

- EC2 instances would not have internet access
- Website hosting would fail

---

# Route Table Configuration

```hcl
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
```

### Explanation

This route table directs all internet traffic through the Internet Gateway.

| Route | Purpose |
|---|---|
| 0.0.0.0/0 | Allows all internet traffic |
| gateway_id | Uses the Internet Gateway |

---

# Route Table Association

```hcl
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
```

### Explanation

This block connects the route table to the public subnet.

Without this association:
- Public internet access would not work

---

# Security Group Configuration

```hcl
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = aws_vpc.main.id
}
```

### Explanation

The security group acts as a virtual firewall controlling inbound and outbound traffic.

---

## SSH Rule

```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

### Explanation

Allows SSH access to the EC2 instance for remote management.

| Port | Purpose |
|---|---|
| 22 | SSH Remote Access |

---

## HTTP Rule

```hcl
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

### Explanation

Allows web traffic to access the hosted website.

| Port | Purpose |
|---|---|
| 80 | HTTP Website Access |

---

# EC2 Instance Configuration

```hcl
resource "aws_instance" "web" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = file("user-data.sh")
}
```

### Explanation

This resource launches the EC2 instance that hosts the website.

| Component | Meaning |
|---|---|
| ami | Amazon Machine Image |
| instance_type | EC2 server size |
| subnet_id | Launches instance inside subnet |
| vpc_security_group_ids | Attaches security group |
| associate_public_ip_address | Enables internet access |
| user_data | Runs startup automation script |

---

# User Data Script

## File: `user-data.sh`

```bash
#!/bin/bash

yum update -y
yum install httpd -y

systemctl start httpd
systemctl enable httpd

echo "<h1>Website Deployed Successfully Using Terraform By Anih Princely</h1>" > /var/www/html/index.html
```

### Explanation

This script automatically configures the EC2 instance during launch.

| Command | Purpose |
|---|---|
| yum update -y | Updates Linux packages |
| yum install httpd -y | Installs Apache |
| systemctl start httpd | Starts Apache |
| systemctl enable httpd | Starts Apache on boot |
| echo | Creates website homepage |

---

# Outputs Configuration

## File: `outputs.tf`

```hcl
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
```

### Explanation

Displays the EC2 public IP after deployment.

This makes it easier to access the deployed website.

---

# Deployment Process

## Step 1 — Initialize Terraform

```bash
terraform init
```

### Purpose

- Downloads AWS provider plugins
- Initializes Terraform working directory

---

# Step 2 — Validate Configuration

```bash
terraform validate
```

### Purpose

Checks Terraform files for syntax errors.

---

# Step 3 — Preview Infrastructure

```bash
terraform plan
```

### Purpose

Displays resources Terraform will create before deployment.

---

# Step 4 — Deploy Infrastructure

```bash
terraform apply
```

### Purpose

Creates all AWS resources and deploys the website.

---

# Verification

After deployment:

1. Copy the EC2 public IP
2. Open it in a browser

Example:

```text
http://<EC2-PUBLIC-IP>
```

Expected Output:

```text
Website Deployed Successfully Using Terraform
```

---

# Challenges Encountered

During the project, some challenges included:

- Terraform provider installation issues
- Security group misconfiguration
- Public IP accessibility problems
- Apache service startup troubleshooting

---

# Lessons Learned

This project helped improve understanding of:

- Infrastructure as Code (IaC)
- AWS networking
- Terraform resource management
- Automated deployments
- Cloud infrastructure provisioning

---

# Future Improvements

Possible future enhancements:

- Terraform modules
- Load balancer integration
- Auto Scaling Groups
- HTTPS configuration
- Remote state management using S3

---

# Cleanup

To destroy all resources:

```bash
terraform destroy
```

---


# License

This project is for educational and portfolio purposes.

# Screenshots

## Project Structure

![Project Structure](screenshots/project-structure.png)

---

## Terraform Apply

![Terraform Apply](screenshots/terraform-apply.png)

---

## EC2 Instance Running

![EC2 Instance](screenshots/ec2-instance.png)

---

## Security Group

![Security Group](screenshots/security-group.png)

---

## Website Running

![Website](screenshots/website-running.png)

---

## Author

Anih Princely