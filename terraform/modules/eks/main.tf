resource "aws_security_group" "cluster_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # SUGGESTION: Restrict egress rules to only necessary ports and protocols.
    # Example:
    # cidr_blocks = ["0.0.0.0/0"] # Change to specific CIDR blocks if possible.
    # protocol = "tcp"
    # to_port = 443
    # from_port = 443
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

resource "aws_security_group" "node_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = var.node_ingress_cidrs
    # SUGGESTION: Replace "0.0.0.0/0" with specific IP ranges or security groups for security.
    # Example:
    # cidr_blocks = ["192.168.1.0/24"] # Replace with your allowed IP range.
    # source_security_group_id = aws_security_group.some_other_sg.id # Or use another security group.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # SUGGESTION: Restrict egress rules to only necessary ports and protocols.
    # Example:
    # cidr_blocks = ["0.0.0.0/0"] # Change to specific CIDR blocks if possible.
    # protocol = "tcp"
    # to_port = 443
    # from_port = 443
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

resource "aws_eks_cluster" "cluster" {
  name    = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.cluster_sg.id]
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
    # SUGGESTION: Consider making scaling policies configurable via variables.
  }

  instance_types = var.instance_types
  # SUGGESTION: Consider using launch templates for more detailed node configurations.

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.node_sg.id]
  }
}
