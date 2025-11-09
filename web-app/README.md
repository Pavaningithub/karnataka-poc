# Karnataka PoC Web Application

This is a simple web application designed to demonstrate GitLab CI/CD deployment to EC2.

## Structure

```
web-app/
├── index.html          # Main web application
├── deploy.sh          # Deployment script for EC2
├── .gitlab-ci.yml     # GitLab CI/CD pipeline
└── README.md          # This file
```

## Deployment Pipeline

The CI/CD pipeline consists of three stages:

1. **Build** - Prepares the application files
2. **Test** - Validates the application content
3. **Deploy** - Deploys to EC2 instance (manual trigger)

## EC2 Setup Requirements

Before running the deployment, ensure your EC2 instance has:

1. **Web Server**: nginx or apache2 installed
2. **SSH Access**: SSH key pair configured
3. **Permissions**: User can sudo for deployment tasks

## GitLab CI Variables Required

Set these variables in GitLab CI/CD settings:

- `EC2_HOST`: Your EC2 public IP address
- `EC2_USER`: SSH username (e.g., ubuntu, ec2-user)
- `EC2_PRIVATE_KEY`: Private key content for SSH access

## Usage

1. Push code to GitLab repository
2. Pipeline will automatically run build and test stages
3. Manually trigger the deploy stage to deploy to EC2
4. Access the web application at `http://YOUR_EC2_IP`

## Security Notes

- Deployment stage requires manual approval for safety
- Only deploys from main branch
- Uses SSH key authentication
- Creates backups before deployment
