output "repo_name" {
    value = aws_ecr_repository.this.name
}

output "repo_url" {
    value = aws_ecr_repository.this.repository_url
}

