terraform {
  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "aws_route53_example_com" {
  provider = aws.us-east-1

  name              = "/aws/route53/${data.aws_route53_zone.example_com.name}"
  retention_in_days = 30
}



data "aws_route53_zone" "example_com" {
  name = local.values.name
}

resource "aws_route53_query_log" "example_com" {

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.aws_route53_example_com.arn
  zone_id                  = data.aws_route53_zone.example_com.zone_id
}