output "security_group_id" {
  description = "생성된 Security Group의 ID"
  value       = aws_security_group.this.id
}

output "security_group_name" {
  description = "생성된 Security Group의 이름"
  value       = aws_security_group.this.name
}
