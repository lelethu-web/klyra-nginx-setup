# Klyra Nginx Setup

## Overview

This project demonstrates how to deploy a Dockerized Nginx web server on AWS EC2 using Infrastructure as Code (Terraform), configuration management (Ansible), and continuous deployment (GitHub Actions). The setup ensures repeatable, automated deployments of the application whenever updates are pushed to the repository.

---

## Project Structure


klyra-nginx-setup/
├── ansible
│ ├── inventory
│ │ └── aws_ec2.ini # EC2 inventory for Ansible
│ └── playbooks
│ └── deploy.yml # Ansible playbook to deploy Dockerized Nginx
├── app
│ ├── Dockerfile # Dockerfile to build Nginx container
│ └── index.html # Web page served by Nginx
├── terraform
│ └── main.tf # Terraform configuration for AWS resources
└── .github/workflows
└── ci-cd.yml # GitHub Actions workflow for CI/CD


---

## Features

- **Infrastructure as Code**:  
  - Terraform provisions AWS EC2 instances to host the application.
  
- **Configuration Management**:  
  - Ansible installs Docker on EC2, builds the Nginx Docker image, and runs the container.

- **Dockerized Web Server**:  
  - Nginx serves a simple web page from inside a Docker container.

- **CI/CD Pipeline**:  
  - GitHub Actions automatically deploys updates when changes are pushed to the `main` branch.
  - Secure SSH access to EC2 is handled using secrets stored in GitHub.

---

## Why this Approach?

1. **Repeatability & Consistency**:  
   - Terraform ensures your infrastructure is versioned and can be recreated identically across environments.
   - Ansible ensures your EC2 instance is configured the same way every time.

2. **Isolation with Docker**:  
   - Docker containers isolate your application from host OS differences, reducing “it works on my machine” issues.
   - Containers can be quickly rebuilt and deployed without touching the host system.

3. **Automated Deployment (CI/CD)**:  
   - GitHub Actions monitors your repository and runs the deployment automatically on each push to `main`.
   - Reduces manual errors and ensures faster, reliable updates.

4. **Security & Best Practices**:  
   - SSH keys are stored securely as GitHub secrets.
   - EC2 instances are provisioned without hardcoding sensitive credentials.

---

## Prerequisites

- AWS account with an EC2 key pair
- Terraform installed locally
- Docker and Ansible installed on the EC2 instance
- GitHub repository with Actions enabled
- SSH key added as GitHub secret: `AWS_EC2_SSH_KEY`

---

## How it Works

1. **Provision EC2 with Terraform**:  
   Terraform creates an EC2 instance ready to run Docker containers.

2. **Deploy Nginx via Ansible**:  
   Ansible installs Docker, copies the app code, builds the Docker image, and runs the container.

3. **Automate Deployment with GitHub Actions**:  
   Any push to `main` triggers the workflow:
   - Checks out the repository.
   - Adds SSH key from GitHub secrets.
   - Runs Ansible playbook to deploy updates.

---

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/lelethu-web/klyra-nginx-setup.git
   cd klyra-nginx-setup


**Provision EC2:**
cd terraform
terraform init
terraform apply


ansible-playbook -i ansible/inventory/aws_ec2.ini ansible/playbooks/deploy.yml \
    --private-key ~/.ssh/klyra-nginx-key.pem -u ec2-user






