# ⚠️ INTENTIONALLY MISCONFIGURED — for testing the AI reviewer
# This file simulates leaving the front, back, AND garage doors of a
# house wide open — plus taping the house key to the front door.

resource "aws_security_group" "app_server_sg" {
  name        = "app-server-sg"
  description = "Security group for application server"

  # Problem 1: SSH (port 22) open to the entire internet
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Problem 2: Database port open to the entire internet (should be internal only)
  ingress {
    description = "Database access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Problem 3: All outbound traffic allowed to anywhere, any port
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"

  # Problem 4: Hardcoded database password directly in the code
  # (this gets committed to Git history forever — huge security risk)
  user_data = <<-EOF
              #!/bin/bash
              export DB_PASSWORD="SuperSecret123!"
              export API_KEY="sk-live-abc123xyz789"
              EOF

  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
}
