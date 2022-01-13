resource "aws_iam_instance_profile" "webserver_profile" {
  name = "webserver_profile"
  role = aws_iam_role.webserver_role.id
}

resource "aws_iam_role" "webserver_role" {
  name = "webserver_role"
  path = "/"

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

resource "aws_iam_policy" "webserver_policy" {
  name        = "webserver_policy"
  path        = "/"
  description = "Permissions required for bootstrapping of webserver"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:DescribeDBInstances",
        "iam:GetServerCertificate",
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "webserver_policy_attachment" {
  role       = aws_iam_role.webserver_role.name
  policy_arn = aws_iam_policy.webserver_policy.arn
}

resource "aws_iam_server_certificate" "webserver_cert" {
  name              = "webserver_cert"
  certificate_body  = acme_certificate.certificate.certificate_pem
  certificate_chain = acme_certificate.certificate.issuer_pem
  private_key       = acme_certificate.certificate.private_key_pem
}
