provider "aws" {
  region  = var.region
  profile = var.profile_name
  default_tags {
    tags = {
      Budget      = "Education"
      Environment = "Hillel"
    }
  }
}

module "s3" {
  source      = "./s3"
  bucket_name = var.bucket_name
}

module "cf" {
  source                      = "./cf"
  bucket_id                   = module.s3.bucket_id
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  depends_on = [
    module.s3
  ]
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = module.s3.bucket_id
  depends_on = [
    module.s3,
    module.cf
  ]
  policy = <<EOF
{
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "${module.s3.bucket_arn}/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "${module.cf.distribution_arn}"
                    }
                }
            }
        ]
      }
EOF
}