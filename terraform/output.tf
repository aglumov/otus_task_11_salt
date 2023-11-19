#output "nginx_public_ip_address" {
#  description = "Public address to connect to"
#  value       = yandex_compute_instance.lb[*].network_interface[0].nat_ip_address
#}
#
#output "lb_metadata" {
#  value = yandex_compute_instance.lb[0].metadata.user-data
#}

#output "sm_metadata" {
#  value = yandex_compute_instance.salt-master.metadata.user-data
#  sensitive = true
#}

#output "public_key_pem" {
#  value = tls_private_key.salt_master_ssh_key.public_key_pem
#}
#
#output "public_key_openssh" {
#  value = tls_private_key.salt_master_ssh_key.public_key_openssh
#}
