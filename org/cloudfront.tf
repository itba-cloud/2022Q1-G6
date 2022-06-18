
resource "aws_cloudfront_distribution" "s3_distribution" {
    provider = aws.aws


    origin {
        origin_id   = module.s3["website"].id
        domain_name = module.s3["website"].bucket_regional_domain_name // TODO: Esto esta roto

        s3_origin_config {
            origin_access_identity = "origin-access-identity/cloudfront/${module.s3["website"].oai.id}"
        }
    }

    enabled             = true
    is_ipv6_enabled     = true
    comment             = "Some comment"
    default_root_object = "index.html"

    logging_config {
        include_cookies = false
        bucket          = module.s3["logs"].bucket_regional_domain_name//"mylogs.s3.amazonaws.com"
    }


    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = module.s3["website"].id

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "allow-all"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }

    # Cache behavior with precedence 0
    ordered_cache_behavior {
        path_pattern     = "/content/immutable/*"
        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD", "OPTIONS"]
        target_origin_id = module.s3["website"].id

        forwarded_values {
            query_string = false
            headers      = ["Origin"]

            cookies {
                forward = "none"
            }
        }

        min_ttl                = 0
        default_ttl            = 86400
        max_ttl                = 31536000
        compress               = true
        viewer_protocol_policy = "redirect-to-https"
    }

    # Cache behavior with precedence 1
    ordered_cache_behavior {
        path_pattern     = "/content/*"
        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = module.s3["website"].id

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
        compress               = true
        viewer_protocol_policy = "redirect-to-https"
    }

    price_class = "PriceClass_All"

    restrictions {
        geo_restriction {
            restriction_type = "none"
            locations = []
        }
    }

    tags = {
        Name = "grupo6-production-cloudfront"
        Environment = "production"
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}