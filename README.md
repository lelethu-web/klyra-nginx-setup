The Klyra Nginx Setup project demonstrates a DevOps workflow for deploying a simple web application in a cloud environment. Its main goals are:
_
**Infrastructure as Code (IaC)**

Use Terraform to provision an AWS EC2 instance and its security groups automatically.

**Cloud Deployment**

Launch a fully functional EC2 instance on AWS.

Configure the server for incoming HTTP traffic.

**Containerized Web Server**

Deploy Nginx as a Docker container on the EC2 instance to serve a basic web page.

**CI/CD with GitHub Actions**

Automate infrastructure and application deployment pipelines.

Trigger builds, tests, and deployments on pushes and pull requests.

Keep infrastructure and application deployments continuous and repeatable.

**Version Control and Automation**

Use Git & GitHub to track infrastructure and application code.

Enforce best practices for collaboration and history management.
