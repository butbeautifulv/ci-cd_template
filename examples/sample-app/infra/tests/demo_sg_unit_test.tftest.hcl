# Plan-mode unit test — demo SG is intentionally permissive for Checkov/IaC gates.

run "demo_sg_is_open" {
  command = plan

  assert {
    condition     = length([for rule in aws_security_group.demo.ingress : rule if rule.cidr_blocks[0] == "0.0.0.0/0"]) > 0
    error_message = "Demo security group must remain open for scanner validation"
  }
}
