# 🚀 DevOps Assignment – Deploy Ruby on Rails App on AWS ECS Using Terraform

This project demonstrates deploying a Dockerized **Ruby on Rails** application with **Nginx** reverse proxy on **AWS ECS (Fargate)**, managed using **Terraform**. It integrates with **RDS PostgreSQL** and **S3**, using IAM roles for secure access — adhering to best practices in DevOps and Infrastructure as Code (IaC).

---

## 📁 Project Structure

```
.
├── docker/
│   ├── app/                 # Rails app Dockerfile and entrypoint
│   └── nginx/               # Nginx Dockerfile and config
│
├── infrastructure/
│   ├── dev/                 # Terraform code (env-specific)
│   ├── modules/             # Terraform modules (ecs, rds, alb, etc.)
│   └── architecture.png     # Architecture diagram
│
├── .github/workflows/
│   └── ci-cd.yml            # GitHub Actions CI/CD workflow
│
├── docker-compose.yml       # Local dev docker-compose setup
└── README.md
```

---

## 🔧 Technologies Used

- **Ruby on Rails 7.0.5**
- **PostgreSQL 13.3 (RDS)**
- **Docker & Nginx**
- **Amazon ECS (Fargate)**
- **Elastic Load Balancer (ALB)**
- **Amazon RDS**
- **Amazon S3**
- **Terraform**
- **GitHub Actions**

---

## 🧱 Infrastructure Provisioned

Using **Terraform**, the following AWS resources are provisioned:

- **VPC** with public & private subnets
- **NAT Gateway** and route tables
- **Security Groups** (ECS, ALB, RDS)
- **Elastic Load Balancer (ALB)** in public subnet
- **ECS Cluster (Fargate)** with:
  - Rails App container (port 3000)
  - Nginx reverse proxy container (port 80)
- **ECR Repositories** for both containers
- **RDS PostgreSQL** in private subnet
- **S3 Bucket** for file storage
- **IAM Roles and Policies** for ECS tasks and S3 access

---

## 🚦 CI/CD Pipeline

Using **GitHub Actions** (`.github/workflows/ci-cd.yml`):

1. On `push` to the `main` branch:
   - Rails and Nginx Docker images are built
   - Images are pushed to ECR
   - Terraform applies infrastructure changes
   - ECS service is automatically updated with new images

---

## 🔐 Environment Variables

The following environment variables are injected into the ECS task definitions.

### For Rails App:

```
RDS_DB_NAME         = your-db-name
RDS_USERNAME        = your-db-username
RDS_PASSWORD        = your-db-password
RDS_HOSTNAME        = your-db-endpoint
RDS_PORT            = 5432
S3_BUCKET_NAME      = your-s3-bucket-name
S3_REGION_NAME      = your-region
LB_ENDPOINT         = your-load-balancer-dns
```

> ✅ S3 is accessed via IAM Role-based auth — no access keys required.

---

## 🖼 Architecture Diagram

![Architecture](./infrastructure/architecture.png)

> The Load Balancer routes traffic to the Nginx container, which proxies to the Rails app inside ECS Fargate. Rails connects to RDS and S3 from within private subnets.

---

## 📦 Local Development

To test locally with Docker Compose:

```bash
docker-compose up --build
```

This will spin up the Rails app and Nginx locally.

---

## 🚀 Deployment Steps

1. **Fork** the [original repo](https://github.com/mallowtechdev/DevOps-Interview-ROR-App)
2. Add your AWS credentials as GitHub secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Push to the `main` branch
4. GitHub Actions will:
   - Build and push Docker images to ECR
   - Run Terraform to deploy the infrastructure
   - Trigger an ECS deployment with the new image tags
5. Visit the Load Balancer DNS to view the app live

---

## ✅ Notes

- All AWS services are provisioned using **Terraform** only
- **ECS Fargate** is used for serverless container hosting
- No credentials are hardcoded — follows IAM role best practices
- Follows separation of modules and environment config


---