# 🚀 Terraform EKS Cluster on AWS

This guide provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster using **Terraform**, including configurations for accessing and managing the cluster.

## 🏗️ Deployment Options

You can deploy this EKS cluster using two methods:

### 🏗️ Project Deployment Flow

<p align="center">
    <img src="snapshot\IaCSecOps_Pipeline.png" alt="IaCSecOps Pipeline Flow"/>
</p>

### **Security Tools (DevSecOps)**

```
Secret Scanning:
└── Gitleaks          # Detect hardcoded secrets

Dependency Scanning (SCA):
└── Snyk              # Software Composition Analysis

Code Quality (SAST):
└── SonarQube         # Static Application Security Testing

Filesystem Security:
└── Trivy             # Vulnerability Scanner

Terraform Code Scanning:
└── Terrascan         # Terraform Code Scan

```

## 📊 Pipeline Results

### **Jenkins Pipeline View**

<p align="center">
    <img src="snapshot\eks-pipeline-phase.png" alt="Jenkins Pipeline Stages" width="800"/>
</p>

### **Report View**

<p align="center">
    <img src="snapshot/terraform-aws-eks-report.png" alt="Pipeline Execution Details" width="800"/>
</p>

### **AWS EKS Cluster View**

<p align="center">
    <img src="snapshot\nodes-eks-image.png" alt="EKS Cluster  Details" width="800"/>
</p>

---

## Option 1: CI/CD Pipeline (Recommended)

This project is optimized for a DevSecOps pipeline using Jenkins.

### 🛠️ Prerequisites

**Step 1: Setup AWS CLI and IAM User**

```bash
# 1. Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y && unzip awscliv2.zip && sudo ./aws/install

# 2. Create Admin User for Pipeline
aws iam create-user --user-name jenkins-eks-admin

# 3. Create and Attach Policy
cat <<EOF > policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["eks:*", "ec2:*", "iam:*", "vpc:*", "autoscaling:*", "cloudformation:*"],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy --policy-name EKS-Admin-Policy --policy-document file://policy.json
aws iam attach-user-policy --user-name jenkins-eks-admin --policy-arn $(aws iam list-policies --query 'Policies[?PolicyName==`EKS-Admin-Policy`].Arn' --output text)

# 4. Generate Access Keys
aws iam create-access-key --user-name jenkins-eks-admin
```

**⚠️ Important:** Save the Access Key ID and Secret Access Key generated in Step 4. You will need to run `aws configure` and provide these keys to authorize the pipeline.

**Step 2:** Install Jenkins Plugins

- Pipeline: AWS Steps
- SonarQube Scanner
- Docker

**Step 3:** Configure Credentials

- Add `aws-creds`, `sonar`, and `snyk_cred` in Jenkins Credentials Manager

**Step 4:** Install Tools

- Ensure `terraform`, `terrascan`, and `trivy` are installed on the Jenkins agent

---

## Option 2: Manual Deployment (CLI)

Use this method for local testing or quick deployment.

### 🛠️ Prerequisites

Ensure the following tools are installed and configured:

#### 1. Install AWS CLI v2

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

#### 2. Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

#### 3. Install Terraform

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt-get install terraform
terraform --version
```

---

### 🔐 IAM Setup (Programmatic Access)

Run these commands to create a dedicated IAM user for Jenkins/Terraform.

#### Step 1: Create IAM User

```bash
aws iam create-user --user-name jenkins-eks-admin
```

#### Step 2: Create Policy File

```bash
cat <<EOF > policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "vpc:*",
        "autoscaling:*",
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```

#### Step 3: Attach Policy

```bash
# Create custom policy
aws iam create-policy --policy-name EKS-Admin-Policy --policy-document file://policy.json

# Attach it (Using AdministratorAccess for learning — use EKS-Admin-Policy in production)
aws iam attach-user-policy --user-name jenkins-eks-admin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

#### Step 4: Generate Access Keys

```bash
aws iam create-access-key --user-name jenkins-eks-admin
```

**⚠️ Important:** Save the `AccessKeyId` and `SecretAccessKey` from the output **securely**.

---

## 🚀 Deploy EKS Cluster

### 1️⃣ Authentication

Configure your AWS CLI with the keys generated above:

```bash
aws configure
```

Enter:

- **Access Key ID:** (from Step 4)
- **Secret Access Key:** (from Step 4)
- **Default region name:** `ap-south-1` (or your preferred region)
- **Default output format:** `json`

### 2️⃣ Initialize Terraform

```bash
cd TERRAFORM-AWS-EKS/terraform/
terraform init
```

### 3️⃣ Validate, Plan and Deploy

```bash
terraform validate
terraform plan
terraform apply --auto-approve
```

**⏳ Wait:** 10–15 minutes for AWS to provision the cluster.

### 4️⃣ Configure kubectl

Connect your local `kubectl` to the new EKS cluster:

```bash
aws eks --region ap-south-1 update-kubeconfig --name <cluster-name>
```

Verify connection:

```bash
kubectl get nodes
```

---

## 🧹 Cleanup

To avoid unnecessary AWS costs, destroy the resources when you're done:

```bash
terraform destroy --auto-approve
```

---

## 🤝 Contributing

Feel free to submit issues and pull requests to improve this project!
