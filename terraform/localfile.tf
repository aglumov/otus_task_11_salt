#resource "local_file" "salt-master-private-key" {
#  filename        = "salt-master-private-key"
#  file_permission = 0644
#  content = tls_private_key.salt_master_ssh_key.private_key_openssh
#}
