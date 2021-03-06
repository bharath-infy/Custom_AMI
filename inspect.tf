resource "aws_instance" "inspector-instance" {
  ami = "ami-0bbe28eb2173f6167"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.sample_sg.name}"]
  user_data = "${file("startup.sh")}"

  tags = {
    Name = "InspectInstances"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ansible"
      password = "ansible123"
      host = "${aws_instance.inspector-instance.public_ip}"
    }
    inline = [
      "wget https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install -P /tmp/",
      "sudo bash /tmp/install"
    ]
  }
}

resource "aws_security_group" "sample_sg" {
  name = "Allow SSH"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_inspector_resource_group" "bar" {
  tags = {
    Name = "${aws_instance.inspector-instance.tags.Name}"
  }
}

resource "aws_inspector_assessment_target" "myinspect" {
  name = "inspector-instance-assessment"
  resource_group_arn = "${aws_inspector_resource_group.bar.arn}"
}

resource "aws_inspector_assessment_template" "foo" {
  name       = "bar template"
  target_arn = "${aws_inspector_assessment_target.myinspect.arn}"
  duration   = 3600

  rules_package_arns = [
    "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-gEjTy7T7",
    "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-rExsr2X8",
    "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-R01qwB5Q",
    "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-gBONHN9h",
  ]
}
