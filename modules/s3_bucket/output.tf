output "bucket_name" {
  value       = aws_s3_bucket.bucket.id
  description = "Name of the bucket."
}
