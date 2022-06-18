
data "aws_region" "current" {
	provider = aws.aws
}

data "aws_caller_identity" "current" {
  	provider = aws.aws
}

# TODO: fix once LB is added
data "template_file" "userdata" {
	template = file("${path.module}/html/index.html")
	# vars = {
	# 	ENDPOINT = "${aws_api_gateway_stage.this.invoke_url}"
	# }
}

data "aws_ami" "app" {
	provider = aws.aws
	most_recent = true

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}

	filter {
		name   = "architecture"
		values = ["x86_64"]
	}

	owners = ["099720109477"] # Canonical official
}
