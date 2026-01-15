# 🚀 Terraform EKS Cluster on AWS

This guide provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster using **Terraform**, including configurations for accessing and managing the cluster.

## 🛠️ Prerequisites

Ensure the following tools are installed and configured:

### 1. Install AWS CLI v2

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### 2. Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 3. Install Terraform

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt-get install terraform
```

## 🔐 IAM Setup (Programmatic Access)

Run these commands to create a dedicated IAM user for Jenkins/Terraform.

### Step 1: Create IAM User

```bash
aws iam create-user --user-name jenkins-eks-admin
```

### Step 2: Create Policy File

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

### Step 3: Attach Policy

```bash
# Create custom policy
aws iam create-policy --policy-name EKS-Admin-Policy --policy-document file://policy.json

# Attach it
# (Using AdministratorAccess for learning — use EKS-Admin-Policy in production)
aws iam attach-user-policy --user-name jenkins-eks-admin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### Step 4: Generate Access Keys

```bash
aws iam create-access-key --user-name jenkins-eks-admin
```

**⚠️ Note:** Save the `AccessKeyId` and `SecretAccessKey` from the output **securely**.

## 🧪 Deploy EKS Cluster

### 1️⃣ Authentication

Configure your AWS CLI with the keys generated above:

```bash
aws configure
```

Enter:

- Access Key ID
- Secret Access Key
- Default region name → `ap-south-1` (or your preferred region)
- Default output format → `json`

### 2️⃣ Initialize Terraform

```bash
cd TERRAFORM-AWS-EKS
terraform init
```

### 3️⃣ Validate ,Plan and Deploy

```bash
terraform validate
terraform plan
terraform apply --auto-approve
```

Wait **10–15 minutes** for AWS to provision the cluster.

### 4️⃣ Configure kubectl

Connect your local `kubectl` to the new EKS cluster:

```bash
aws eks --region ap-south-1 update-kubeconfig --name <cluster-name>
```

Verify connection:

```bashgit
kubectl get nodes
```

## 🧹 Cleanup

To avoid unnecessary AWS costs, destroy the resources when you're done:

```bash
terraform destroy --auto-approve
```
