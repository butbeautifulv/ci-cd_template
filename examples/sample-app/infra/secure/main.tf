resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Least-privilege example for Checkov triage contrast"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "allowed_cidr" {
  description = "CIDR allowed to reach the app"
  type        = string
  default     = "10.0.0.0/8"
}
