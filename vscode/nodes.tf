resource "aws_iam_role" "node" {
  name               = "${var.prefix}-${var.cluster_name}-node"
  assume_role_policy = <<POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
                }
            ]
        }
        POLICY
}


resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
} // permite que os pods se comuniquem entre si

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
} // permite que os pods se comuniquem com o ECR

# resource "aws_eks_node_group" "node-1" {
#   cluster_name    = aws_eks_cluster.cluster.name
#   node_group_name = "${var.prefix}-node-group-1"
#   node_role_arn   = aws_iam_role.node.arn
#   subnet_ids      = aws_subnet.subnet[*].id
#   scaling_config {
#     desired_size = var.desired_size
#     max_size     = var.max_size
#     min_size     = var.min_size
#   }

# }


resource "aws_eks_node_group" "node-2" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.prefix}-node-group-2"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.subnet[*].id
  instance_types  = ["t3.micro"]
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

}
