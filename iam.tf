resource "aws_iam_role" "jenkins-ec2-role" {
    name = "${var.environment}-jenkins-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ssm.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "jenkins-profile" {
    name = "${var.environment}-jenkins-profile"
    role = "${aws_iam_role.jenkins-ec2-role.name}"
}

resource "aws_iam_role" "jenkins-server-role" {
    name = "${var.environment}-jenkins-server-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "jenkins-role-policy" {
    name = "${var.environment}-jenkins-policy"
    role = "${aws_iam_role.jenkins-ec2-role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecs:CreateCluster",
            "ecs:DeregisterContainerInstance",
            "ecs:DiscoverPollEndpoint",
            "ecs:Poll",
            "ecs:RegisterContainerInstance",
            "ecs:StartTelemetrySession",
            "ecs:Submit*",
            "ecs:StartTask",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
            "s3:GetEncryptionConfiguration"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams"
          ],
          "Resource": [
              "arn:aws:logs:*:*:*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": [
            "${aws_kms_key.ebs_kms.arn}"
          ]
        }
    ]
}
EOF
}

# ecs service role
resource "aws_iam_role" "ecs-service-role" {
    name = "${var.environment}-ecs-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs-service-attach1" {
    name = "${var.environment}-ecs-service-attach"
    roles = ["${aws_iam_role.ecs-service-role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_policy_attachment" "ssm-attach" {
    name = "${var.environment}-ssm-attach"
    roles = ["${aws_iam_role.jenkins-ec2-role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

######
# Code Pipeline IAM Resources
######
resource "aws_iam_role" "code-pipeline-role" {
    name = "${var.environment}-pipeline-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "code-pipeline-policy" {
    name = "${var.environment}-pipeline-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com",
                        "ecs.amazonaws.com",
                        "ecr.amazonaws.com"
                    ]
                }
            }
        },
        {
          "Effect":"Allow",
          "Action": [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning"
          ],
          "Resource": [
            "${aws_s3_bucket.pipeline_bucket.arn}",
            "${aws_s3_bucket.pipeline_bucket.arn}/*"
          ]
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "rds:*",
                "ecs:*",
                "ecr:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "pipeline-attach" {
    name = "${var.environment}-pipeline-attach"
    roles = ["${aws_iam_role.code-pipeline-role.name}"]
    policy_arn = "${aws_iam_policy.code-pipeline-policy.arn}"
}