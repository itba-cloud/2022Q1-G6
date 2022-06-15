locals {
  bucket_name = "bucketgrupo6-itba-cloud-computing"
  path        = "../resources"

  s3 = {

    # 1 - Website
    website = {
      bucket_name = local.bucket_name
      path        = "../resources"

      objects = {
        error = {
          filename     = "html/error.html"
          content_type = "text/html"
        },
        index={
          filename     = "html/index.html"
          content_type = "text/html"
        }


      }
    }

    # 2 - WWW Website
    www-website = {
      bucket_name = "www.${local.bucket_name}"
    }

    #Logs 
    logs = {
      bucket_name = "logs.${local.bucket_name}"
    }

    


  }
}