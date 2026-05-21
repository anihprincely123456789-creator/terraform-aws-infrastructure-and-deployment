
#!/bin/bash

sudo dnf update -y
sudo dnf install -y httpd

sudo systemctl start httpd
sudo systemctl enable httpd

echo "<h1>Website Deployed with Terraform By Anih Princely</h1>" | sudo tee /var/www/html/index.html