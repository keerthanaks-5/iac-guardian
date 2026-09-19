# ⚠️ INTENTIONALLY MISCONFIGURED — for testing the AI reviewer
# This file simulates wasteful spending — like renting a warehouse
# to store a single shoebox, and leaving the lights on 24/7.

# Problem 1: Wildly oversized instance for a simple dev/test workload
resource "aws_instance" "dev_test_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m5.24xlarge" # 96 vCPUs — massive overkill for "dev/test"

  # Problem 2: No tags at all — impossible to track who owns this
  # or which team/project to bill the cost to
}

# Problem 3: An Elastic IP allocated but never attached to anything
# (AWS charges for unattached Elastic IPs — pure waste)
resource "aws_eip" "orphaned_ip" {
  domain = "vpc"
}

# Problem 4: An EBS volume with no lifecycle policy or deletion protection,
# provisioned way larger than needed, using expensive io2 storage
# for a workload that doesn't need high IOPS
resource "aws_ebs_volume" "oversized_volume" {
  availability_zone = "us-east-1a"
  size              = 2000 # 2TB, for a workload that logs a few MB/day
  type              = "io2"
  iops              = 10000
}

# Problem 5: RDS instance running Multi-AZ (2x cost) for a
# non-production database that doesn't need high availability
resource "aws_db_instance" "staging_db" {
  identifier        = "staging-database"
  engine            = "postgres"
  instance_class    = "db.r5.2xlarge"
  allocated_storage = 500
  multi_az          = true # unnecessary cost for staging
}
