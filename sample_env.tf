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

  # for performance considerations, something bigger than micro is required
  instance_type = "t3.medium"

  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.flask-sg.id}"]

  tags = {
    Name = "Guestbook-EC2-Example"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jdk-headless git",
      "git clone https://github.com/ernsthaagsman/guestbook ~/guestbook",
      "cd ~/guestbook/backend",
      "chmod +x ./gradlew",
      "./gradlew bootJar",
      "sudo sed -i -e '/^assistive_technologies=/s/^/#/' /etc/java-*-openjdk/accessibility.properties"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
    }
  }
}

output "instance_dns_name" {
  value = "${aws_instance.sample.public_dns}"
}

resource "aws_security_group" "flask-sg" {
  name = "Guestbook-EC2-Example"

  ingress {
    # The port the Guestbook app runs on
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # JDWP
    from_port = "5005"
    to_port = "5005"
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
    Name = "Guestbook-EC2-Example"
  }
}
