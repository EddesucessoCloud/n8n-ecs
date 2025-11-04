
resource "aws_efs_file_system" "n8n_efs" {
  creation_token = "n8n-efs-token"
  tags = {
    Name = "n8n-efs"
  }
}

resource "aws_efs_access_point" "n8n_efs_ap" {
  file_system_id = aws_efs_file_system.n8n_efs.id

  root_directory {
    path = "/n8n"
    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "0755"
    }
  }

  tags = {
    Name = "n8n-efs-access-point"
  }
}

resource "aws_efs_mount_target" "n8n_efs_mt" {
  for_each = {
    "us-east-1a" = "subnet-0eb40e410749ac073"
    "us-east-1b" = "subnet-0715d416cf63cc9c8"
    "us-east-1c" = "subnet-0a2fa8fe3cf159e15"
    "us-east-1d" = "subnet-03717330c5353e44d"
    "us-east-1e" = "subnet-0485d7f3414eb5277"
    "us-east-1f" = "subnet-09b307391bb7a25f1"
  }

  file_system_id = aws_efs_file_system.n8n_efs.id
  subnet_id      = each.value
  security_groups = ["sg-00fc9a4a0bab615ff"]
}
