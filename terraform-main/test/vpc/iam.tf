
resource "aws_iam_user" "example_user" {
  name = "example_user"
}

resource "aws_iam_access_key" "example_user_access_key" {
  user = aws_iam_user.example_user.name
}

resource "aws_iam_user_policy" "example_user_policy" {
  name = "example_user_policy"
  user = aws_iam_user.example_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.example_bucket.id}/*"
      ]
    }
  ]
}
EOF
}
