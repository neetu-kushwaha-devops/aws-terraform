output "nlb_id" {
  description = "The ID of the NLB"
  value       = aws_lb.this.id
}

output "nlb_arn" {
  description = "The ARN of the NLB"
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "The DNS name of the NLB"
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in Route 53 Route)"
  value       = aws_lb.this.zone_id
}

output "listener_arns" {
  description = "A map of listener protocol/port combinations to their ARNs"
  value       = { for k, v in aws_lb_listener.this : k => v.arn }
}
