
resource "aws_s3_bucket" "S3_Bucket" {
  bucket = "final-exam-bucket-kim"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
tags = {
    Name        = "final-exam-bucket-kim"
}
}

