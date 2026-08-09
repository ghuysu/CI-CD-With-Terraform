data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project}-${var.environment}-${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.name}-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project}-${var.environment}-${var.name}-instance-profile"
  role = aws_iam_role.this.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.name}-instance-profile"
    }
  )
}