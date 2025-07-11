// outputs.tf
output "bucket_id" {
  description = "The unique bucket id suffix"
  value       = random_id.static_assets_suffix.hex
}

output "bucket_name" {
  description = "The unique S3 bucket name"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.arn
}
