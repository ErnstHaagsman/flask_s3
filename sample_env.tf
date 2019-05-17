variable "bucket_name" {}
variable "key_name" {}

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

resource "aws_instance" "sample" {

  ami = "${data.aws_ami.ubuntu.id}"

  # t2 is free tier, t3 isn't.
  instance_type = "t2.micro"

  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.flask-sg.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.flask-s3-profile.name}"

  tags = {
    Name = "S3-Flask-Example"
  }
}

output "instance_dns_name" {
  value = "${aws_instance.sample.public_dns}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl = "public-read"

  tags = {
    Name = "S3-Flask-Example"
  }
}

resource "aws_security_group" "flask-sg" {
  name = "S3-Flask-Example"

  ingress {
    # The port the Flask app runs on
    from_port = "5000"
    to_port = "5000"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # SSH, for remote interpreter
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "S3-Flask-Example"
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "instance-s3-access-policy" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
    ]
  }
}

resource "aws_iam_role" "role" {
  name = "flask-s3-role"

  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_policy" "flask-s3-policy" {
  policy = "${data.aws_iam_policy_document.instance-s3-access-policy.json}"
}

resource "aws_iam_role_policy_attachment" "flask-s3-attach" {
  policy_arn = "${aws_iam_policy.flask-s3-policy.arn}"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_instance_profile" "flask-s3-profile" {
  role = "${aws_iam_role.role.name}"
}

