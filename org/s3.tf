
module "s3" {
  for_each = local.s3
  source   = "../modules/s3"

  providers = {
    aws = aws.aws
  }

  bucket_name = each.value.bucket_name
  objects     = try(each.value.objects, {})
}

resource "aws_s3_object" "this" {
  provider = aws.aws

  bucket        = module.s3["website"].id
  key           = "index.html"
  content_type  = "text/html"
  storage_class = "STANDARD"
  content = data.template_file.userdata.rendered
}



