resource "aws_security_group" "security-group" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-security-group"
  }
  egress {
    from_port       = 0             // all
    to_port         = 0             // all
    protocol        = "-1"          // all
    cidr_blocks     = ["0.0.0.0/0"] // all
    prefix_list_ids = []
  }
}

resource "aws_iam_role" "cluster-role" {
  name               = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/eks/${var.cluster_name}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
}

resource "aws_eks_cluster" "cluster" {
  name                      = "${var.prefix}-${var.cluster_name}"
  role_arn                  = aws_iam_role.cluster-role.arn
  enabled_cluster_log_types = ["api", "audit"]
  vpc_config {
    subnet_ids         = aws_subnet.subnet[*].id
    security_group_ids = [aws_security_group.security-group.id]
  }
  depends_on = [aws_cloudwatch_log_group.logs,
  aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy, aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController]
}
