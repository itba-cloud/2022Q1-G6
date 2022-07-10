
module "s3" {
  for_each = local.s3
  source   = "../modules/s3"

  providers = {
    aws = aws.aws
  }

  bucket_name = each.value.bucket_name
  objects     = try(each.value.objects, {})
}

