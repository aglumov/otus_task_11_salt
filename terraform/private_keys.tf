resource "tls_private_key" "salt_master_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
