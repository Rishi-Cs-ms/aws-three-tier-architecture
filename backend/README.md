# AWS Three-Tier Demo - Backend

Node.js + Express backend for the AWS Three-Tier Architecture demo.

## Setup

1.  Install dependencies:
    ```bash
    npm install
    ```

2.  Configure `.env`:
    ```
    DB_HOST=your-rds-endpoint
    DB_USER=admin
    DB_PASSWORD=password
    DB_NAME=demo_db
    ```

3.  Start server:
    ```bash
    npm start
    ```

## EC2 User Data Script

Use this script to deploy the backend on EC2 instances in your Auto Scaling Group.

```bash
#!/bin/bash
# Update system
yum update -y

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git

# Clone the repository
# REPLACE WITH YOUR REPO URL
git clone https://github.com/your-username/aws-three-tier-demo.git /home/ec2-user/app

# Navigate to backend directory
cd /home/ec2-user/app/backend

# Install dependencies
npm install

# Create .env file
# REPLACE WITH YOUR ACTUAL RDS CREDENTIALS
cat <<EOF > .env
DB_HOST=your-rds-endpoint.us-east-1.rds.amazonaws.com
DB_USER=admin
DB_PASSWORD=yourpassword
DB_NAME=demo_db
EOF

# Start the application
nohup npm start > app.log 2>&1 &
```
