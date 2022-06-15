
data "aws_region" "current" {
  provider = aws.aws
}

data "aws_caller_identity" "current" {
  provider = aws.aws
}
/*
data "template_file" "userdata" {
  template = file("${path.module}/html/index.html")
  vars = {
    ENDPOINT = "${aws_api_gateway_stage.this.invoke_url}"
  }
}
*/