resource "aws_api_gateway_rest_api" "this" {
  provider = aws.aws

  name        = "AWSAPIGateway-${local.bucket_name}"
  description = "API Gateway de grupo 6}"
}

resource "aws_api_gateway_resource" "this" {
  provider = aws.aws

  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "this" {
  provider = aws.aws

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  provider = aws.aws

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  provider = aws.aws

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      # aws_api_gateway_rest_api.this.body,
      aws_api_gateway_resource.this.id,
      aws_api_gateway_method.this.id,
      aws_api_gateway_integration.this.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  provider = aws.aws

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "production"
}