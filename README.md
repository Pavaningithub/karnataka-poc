# Karnataka PoC - GitLab CI/CD with EC2 Deployment

This project demonstrates a complete GitLab CI/CD pipeline that automatically deploys a web application to EC2.

## 🏗️ What's Working

- ✅ GitLab CE (localhost:8929)
- ✅ GitLab Runner with container networking
- ✅ CI/CD pipeline with EC2 deployment
- ✅ Web application deployment to nginx

## 📁 Project Structure

```
karnataka-poc/
├── gitlab/                 # GitLab CE setup
├── gitlab-runner/          # GitLab Runner configuration
├── web-app/               # Demo web application with CI/CD
└── demo-project/          # Initial test project
```

## 🚀 Quick Start

### 1. Start GitLab Infrastructure

```bash
cd gitlab/
podman compose up -d
```

### 2. Access GitLab

- URL: http://localhost:8929
- Login as `root` with the initial password from container logs

### 3. Get Initial Password

```bash
podman logs gitlab-selfhosted-gitlab | grep "Password:"
```

## 🌐 Web Application with EC2 Deployment

### 4. Deploy Web App with CI/CD

The `web-app/` folder contains a complete CI/CD pipeline that deploys to EC2:

#### Setup GitLab Project

1. Create new project in GitLab: "karnataka-webapp"
2. Push the web-app code to GitLab

#### Setup EC2 Deployment

1. **Prepare EC2 instance**:

   ```bash
   # On your EC2 instance
   sudo apt update
   sudo apt install nginx -y
   sudo systemctl start nginx
   ```

2. **Setup GitLab CI Variables**:

   Go to Project → Settings → CI/CD → Variables:

   - **EC2_PRIVATE_KEY_BASE64**: Your SSH private key (base64 encoded)
   - Create with: `base64 -w 0 ~/.ssh/your-key.pem`

3. **Push and Deploy**:

   ```bash
   cd web-app/
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin http://localhost:8929/root/karnataka-webapp.git
   git push -u origin main
   ```

4. **Pipeline runs automatically**:
   - Build → Test → Deploy to EC2
   - Access your app at your EC2 public IP

## 🔧 Manual Steps Summary

1. Start GitLab: `cd gitlab && podman compose up -d`
2. Get password: `podman logs gitlab-selfhosted-gitlab | grep Password`
3. Login to GitLab at http://localhost:8929
4. Install nginx on EC2
5. Set EC2_PRIVATE_KEY_BASE64 variable in GitLab
6. Push web-app code to GitLab project
7. Pipeline deploys to EC2 automatically

## 🛠️ Troubleshooting

### GitLab Runner Issues

```bash
# Check runner status
podman logs gitlab-selfhosted-runner

# Check GitLab status
podman logs gitlab-selfhosted-gitlab
```

### Pipeline Issues

- Ensure EC2_PRIVATE_KEY_BASE64 is set correctly in GitLab CI variables
- Check EC2 security group allows SSH (port 22) and HTTP (port 80)
- Verify nginx is running on EC2: `sudo systemctl status nginx`

## 📝 Notes

- GitLab takes 2-5 minutes to fully start
- GitLab Runner uses "shell" executor for simplicity
- EC2 deployment creates backups before each deployment
- All configurations are generic and portable

---

**That's it! Everything is working and ready to use.** 🚀
