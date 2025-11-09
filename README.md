# Karnataka PoC - Complete GitLab CI/CD with EC2 Deployment Guide

This project demonstrates a complete GitLab CI/CD pipeline that automatically deploys a web application to EC2. Follow this comprehensive guide to set up everything from scratch and successfully deploy your web application.

## 📁 Project Overview

```
karnataka-poc/
├── gitlab/                 # GitLab CE setup with docker-compose
├── gitlab-runner/          # Custom GitLab Runner with Podman
├── web-app/               # Demo web application with complete CI/CD pipeline
├── scripts/               # Automated setup scripts (optional)
└── README.md              # This comprehensive guide
```

## 🎯 What You'll Achieve

- ✅ Self-hosted GitLab CE instance running locally with **Podman**
- ✅ GitLab Runner with shell executor for CI/CD
- ✅ Complete CI/CD pipeline (Build → Test → Deploy)
- ✅ Automated deployment to EC2 instance
- ✅ Web application accessible via EC2 public IP

> **Note**: This setup uses **Podman** and **Podman Compose** exclusively - no Docker required!

---

## 🚀 Complete Setup Guide

### Prerequisites

Before starting, ensure you have:
- **Podman** installed and working
- **An AWS EC2 instance** with SSH access
- **SSH key pair** for EC2 authentication
- **Internet connection** for downloading container images

### Step 1: Clone and Navigate to Project

```bash
git clone <your-repo-url>
cd karnataka-poc
```

### Step 2: Start GitLab Infrastructure

```bash
# Navigate to GitLab directory
cd gitlab/

# Start GitLab CE container (this takes 2-5 minutes to fully initialize)
podman compose up -d
```

**Important**: GitLab needs time to initialize. Wait 2-5 minutes before proceeding.

### Step 3: Get GitLab Root Password

```bash
# Wait for GitLab to fully start, then get the initial password
podman logs gitlab-selfhosted-gitlab | grep "Password:"
```

Expected output:
```
Password: <some-random-password>
```

### Step 4: Access GitLab Web Interface

1. **Open browser** and go to: http://localhost:8929
2. **Login credentials**:
   - Username: `root`
   - Password: `<password-from-step-3>`

### Step 5: Set Up GitLab Runner Token

1. **In GitLab web interface**, go to:
   - **Admin Area** (wrench icon) → **CI/CD** → **Runners**
2. **Click "New instance runner"**
3. **Configure runner**:
   - Operating systems: Linux
   - Tags: `shell,docker,podman` 
   - Configuration: Check "Run untagged jobs"
4. **Click "Create runner"**
5. **Copy the authentication token** (starts with `glrt-`)

### Step 6: Configure GitLab Runner

The GitLab Runner should already be running from the podman compose, but you need to update it with your runner token:

```bash
# Check if runner is running
podman ps --filter name=gitlab-runner

# Update the runner with your token from Step 5:
# 1. Edit gitlab/docker-compose.yaml 
# 2. Set RUNNER_TOKEN: "glrt-your-token-here"
# 3. Then restart the runner:
podman compose restart gitlab-runner
```

**Important**: You must update the `RUNNER_TOKEN` in `gitlab/docker-compose.yaml` with the token from Step 5 before the runner can connect to GitLab.

### Step 7: Verify Runner Registration

1. **In GitLab**, go to **Admin Area** → **CI/CD** → **Runners**
2. **Verify** that your runner appears in the "Available runners" list
3. **Status should be**: Online (green circle)

---

## 🌐 EC2 Instance Preparation

### Step 8: Prepare Your EC2 Instance

**SSH into your EC2 instance** and run:

```bash
# Update system packages
sudo apt update

# Install nginx web server
sudo apt install nginx -y

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify nginx is running
sudo systemctl status nginx
```

### Step 9: Configure EC2 Security Groups

**In AWS Console**, ensure your EC2 security group allows:
- **SSH (port 22)** from your IP or GitLab runner IP
- **HTTP (port 80)** from anywhere (0.0.0.0/0)
- **HTTPS (port 443)** from anywhere (optional)

### Step 10: Test EC2 Web Server

```bash
# From your local machine, test EC2 web server
curl http://YOUR_EC2_PUBLIC_IP
```

You should see the default nginx welcome page.

---

## 🔧 GitLab Project Setup

### Step 11: Create New GitLab Project

1. **In GitLab**, click **"Create a project"**
2. **Choose** "Create blank project"
3. **Project details**:
   - Project name: `karnataka-webapp`
   - Visibility Level: Internal or Private
4. **Click** "Create project"

### Step 12: Configure CI/CD Variables

**Essential**: Configure these variables in GitLab before deploying:

1. **Go to**: Project → Settings → CI/CD → Variables
2. **Add these variables**:

   | Variable Name | Value | Protected | Masked |
   |---------------|-------|-----------|--------|
   | `EC2_HOST` | Your EC2 public IP address | ✅ | ❌ |
   | `EC2_USER` | `ubuntu` (or `ec2-user` for Amazon Linux) | ✅ | ❌ |
   | `EC2_PRIVATE_KEY_BASE64` | Base64 encoded private key | ✅ | ✅ |

**To create EC2_PRIVATE_KEY_BASE64**:
```bash
# On your local machine with the EC2 private key:
base64 -w 0 ~/.ssh/your-ec2-key.pem
# Copy the entire output and paste as the variable value
````

### Step 13: Push Web Application Code

```bash
# Navigate to web-app directory
cd web-app/

# Initialize git repository
git init
git add .
git commit -m "Initial commit: Karnataka PoC Web Application"

# Add GitLab remote (replace with your GitLab URL)
git remote add origin http://localhost:8929/root/karnataka-webapp.git

# Push to main branch
git push -u origin main
```

---

## 🚀 Deployment and Testing

### Step 14: Trigger CI/CD Pipeline

**The pipeline should automatically start** after pushing code. You can monitor it:

1. **In GitLab project**, go to **CI/CD** → **Pipelines**
2. **Click on the running pipeline** to see details
3. **Pipeline stages**:
   - **Build**: Prepares application files
   - **Test**: Validates content and files
   - **Deploy**: Deploys to EC2 (only on main branch)

### Step 15: Monitor Deployment

**Watch the deploy job logs** for:
- SSH key decoding and validation
- SSH connection test to EC2
- File transfer to EC2
- Deployment script execution
- Success confirmation

### Step 16: Verify Deployment

1. **Check deployment success** in GitLab pipeline logs
2. **Access your web application**:
   ```
   http://YOUR_EC2_PUBLIC_IP
   ```
3. **You should see** the Karnataka PoC web application

---

## �️ Troubleshooting Guide

### Common GitLab Issues

**GitLab not starting:**
```bash
# Check GitLab status
podman logs gitlab-selfhosted-gitlab

# If needed, restart GitLab
podman compose restart gitlab
```

**Runner not connecting:**
```bash
# Check runner logs
podman logs gitlab-selfhosted-runner

# Verify runner token is correct
# Update token in docker-compose.yaml and restart
```

### Common Pipeline Issues

**SSH connection fails:**
- Verify `EC2_PRIVATE_KEY_BASE64` is correctly base64 encoded
- Check EC2 security group allows SSH (port 22)
- Ensure EC2 instance is running and accessible

**Deployment fails:**
- Check nginx is installed and running on EC2
- Verify EC2 user has sudo permissions
- Check /var/log/auth.log on EC2 for SSH issues

**Pipeline stuck:**
- Ensure runner is online in GitLab Admin → Runners
- Check runner has correct tags: `shell,docker,podman`
- Verify runner can execute shell commands

### EC2 Issues

**Web server not accessible:**
```bash
# On EC2, check nginx status
sudo systemctl status nginx

# Restart nginx if needed
sudo systemctl restart nginx

# Check if files were deployed
ls -la /var/www/html/
```

**File permission issues:**
```bash
# On EC2, fix web server permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 644 /var/www/html/*
```

---

## 🔧 Manual Commands Reference

### GitLab Management
```bash
# Start GitLab
cd gitlab/ && podman compose up -d

# Stop GitLab
podman compose down

# View GitLab logs
podman logs gitlab-selfhosted-gitlab

# Get initial password
podman logs gitlab-selfhosted-gitlab | grep "Password:"
```

### Runner Management
```bash
# Check runner status
podman ps --filter name=gitlab-runner

# View runner logs
podman logs gitlab-selfhosted-runner

# Restart runner
podman compose restart gitlab-runner
```

### EC2 Deployment Commands
```bash
# Test SSH connection to EC2
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_EC2_IP

# Manual deployment (if needed)
scp -i ~/.ssh/your-key.pem web-app/index.html ubuntu@YOUR_EC2_IP:~/
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_EC2_IP "sudo cp index.html /var/www/html/"
```

---

## 📋 Verification Checklist

**Before deployment, verify:**
- [ ] GitLab is accessible at http://localhost:8929
- [ ] GitLab Runner shows as "Online" in Admin → Runners
- [ ] EC2 instance is running and accessible via SSH
- [ ] Nginx is installed and running on EC2
- [ ] EC2 security groups allow SSH (22) and HTTP (80)
- [ ] GitLab CI variables are set correctly
- [ ] EC2_PRIVATE_KEY_BASE64 is properly base64 encoded

**After deployment, verify:**
- [ ] Pipeline completed successfully (green checkmark)
- [ ] Web application is accessible at http://YOUR_EC2_IP
- [ ] Application shows "Karnataka PoC" content
- [ ] No errors in GitLab pipeline logs

---

## 📝 Architecture Summary

**Local Infrastructure:**
- GitLab CE: http://localhost:8929
- GitLab Runner: Connected via Podman network
- Pipeline: Build → Test → Deploy

**AWS Infrastructure:**
- EC2 instance with nginx
- SSH key-based authentication
- Automated deployment via GitLab CI/CD

**Deployment Flow:**
1. Code push to GitLab triggers pipeline
2. Build stage prepares application files
3. Test stage validates content
4. Deploy stage connects to EC2 via SSH
5. Files copied and deployed to nginx web root
6. Application accessible via EC2 public IP

---

**🎉 Congratulations!** You now have a complete GitLab CI/CD pipeline that automatically deploys to EC2. Any changes pushed to the main branch will trigger automatic deployment to your EC2 instance.
