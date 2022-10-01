output "lb_target_id" {
    value = aws_alb_target_group.main.id
}

output "lb_sg_id" {
    value = aws_security_group.lb.id
}

# The load balancer DNS name
output "lb_dns" {
  value = aws_alb.this.dns_name
}
