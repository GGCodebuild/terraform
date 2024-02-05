output "iam_emr_service_role_arn" {
  value = aws_iam_role.iam_emr_service_role.arn
}

output "iam_ec2_profile_role_arn" {
  value = aws_iam_role.iam_ec2_profile_role.arn
}


output "emr_profile_arn" {
  value = aws_iam_instance_profile.emr_profile.arn
}