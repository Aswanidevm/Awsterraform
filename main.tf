terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

module "template_files"{
  source = "hashicorp/dir/template"
  base_dir= "${path.module}/webresources"
}
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "mybucket_acl" {

  bucket = aws_s3_bucket.mybucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]

}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.mybucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.public]
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "mybucket_policy" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.mybucket_policy.json
}

data "aws_iam_policy_document" "mybucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["349018223180"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    effect = "Allow"

    resources = [
      aws_s3_bucket.mybucket.arn,
      "${aws_s3_bucket.mybucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.mybucket.id
  for_each= module.template_files.files
  key    = each.key
  source = "${path.module}/webresources"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
#  etag = filemd5("./each.key")
  acl = "public-read"
}
## Create a VPC
#resource "aws_vpc" "example" {
#  cidr_block = "10.0.0.0/16"
#}