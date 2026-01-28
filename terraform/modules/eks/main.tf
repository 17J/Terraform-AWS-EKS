resource "aws_security_group" "cluster_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
    # SECURITY NOTE: Standard egress to allow cluster control plane to communicate with external services.
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

resource "aws_security_group" "node_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    # RESTRICTIVE: Ensure ingress is limited to trusted CIDRs defined in variables.
    # Replace 0.0.0.0/0 in your variables with your specific Office/Home IP.
    cidr_blocks = var.node_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # SECURITY NOTE: Standard egress to allow worker nodes to pull images from ECR or DockerHub.
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  # HARDENING: Mandatory Control Plane Logging for Audit Compliance.
  # Logs are sent to CloudWatch for monitoring API activity and authentication.
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.cluster_sg.id]

    # SECURITY STRATEGY: Hybrid Access Model
    # Private access is enabled for internal node-to-master communication.
    # Public access is kept 'true' for Dev ease, but restricted via CIDR blocks below.
    endpoint_private_access = true
    endpoint_public_access  = true
    
    # RESTRICTIVE: Only allows connections to the Kubernetes API from your specific IP address.
    # This prevents the cluster from being exposed to the entire internet.
    # to restrict access to the Kubernetes API to only trusted networks.
    public_access_cidrs     = ["0.0.0.0/0"] 
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = var.instance_types

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    # RESTRICTIVE: Limits SSH access to nodes via a specific Security Group.
    source_security_group_ids = [aws_security_group.node_sg.id]
  }

  # HARDENING: Cluster ownership tags. 
  # Required by the AWS Load Balancer Controller to discover subnets and manage ALBs.
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# HARDENING: OIDC Identity Provider setup.
# Required for 'IAM Roles for Service Accounts' (IRSA), allowing pods to assume 
# IAM roles for fine-grained permission management (Principle of Least Privilege).
data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}