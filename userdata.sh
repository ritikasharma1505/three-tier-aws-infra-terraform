#!/bin/bash
set -e

# Update packages and Mysql client
apt update -y
apt install -y apache2 curl mysql-client

# Get Instance ID (IMDSv2 compatible)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/instance-id)

# Create HTML file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Homepage</title>
</head>
<body>
  <h1>From ALB </h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <p>Load Balancing Example</p>
</body>
</html>
EOF

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

