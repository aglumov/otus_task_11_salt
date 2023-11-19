resource "yandex_compute_instance" "salt-master" {
  name                      = "salt-master"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[1]
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    #core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd82sqrj4uk9j7vlki3q"
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[1].id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    #user-data = "#cloud-config\nssh-keys:\n  rsa_private: |\n    ${indent(4,tls_private_key.salt_master_ssh_key.private_key_openssh)}\n  rsa_public: ${tls_private_key.salt_master_ssh_key.public_key_openssh}${file("cloud-init-salt-master.cfg")}"
    user-data = "${file("cloud-init-salt-master.cfg")}write_files:\n- path: /home/ubuntu/.ssh/id_rsa\n  defer: true\n  permissions: '0600'\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode(tls_private_key.salt_master_ssh_key.private_key_openssh)}\nruncmd:\n- [ systemctl, start, salt-master ]"
  }
}

resource "yandex_compute_instance" "lb" {
  count                     = 1
  name                      = "lb${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd82sqrj4uk9j7vlki3q"
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index].id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    #ssh-keys  = "ubuntu:${tls_private_key.salt_master_ssh_key.public_key_openssh}"
    #user-data = "#cloud-config\nhostname: lb${count.index}\nwrite_files:\n- path: /etc/salt/minion\n  encoding: b64\n  content: ${base64encode("master:\n- ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n")}\nssh_authorized_keys:\n- ${tls_private_key.salt_master_ssh_key.public_key_openssh}\n${file("cloud-init-salt-minion.cfg")}"
    user-data = "#cloud-config\nhostname: lb${count.index}\nwrite_files:\n- path: /etc/salt/minion\n  encoding: b64\n  content: ${base64encode("master:\n- ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n")}\n- path: /etc/salt/minion.d/id.conf\n  encoding: b64\n  content: ${base64encode("id: lb${count.index}")}\n${file("cloud-init-salt-minion.cfg")}\nssh_authorized_keys:\n- ${tls_private_key.salt_master_ssh_key.public_key_openssh}"
  }
}

resource "yandex_compute_instance" "db" {
  count                     = 0
  name                      = "db${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    #core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd82sqrj4uk9j7vlki3q"
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nhostname: db${count.index}"
  }
}

resource "yandex_compute_instance" "app" {
  count                     = 0
  name                      = "app${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd82sqrj4uk9j7vlki3q"
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nhostname: app${count.index}"
  }
}

#resource "time_sleep" "wait_2m_after_inventory" {
#  depends_on      = [local_file.ansible_inventory]
#  create_duration = "2m"
#}
#
#resource "terraform_data" "ansible" {
#  depends_on = [time_sleep.wait_2m_after_inventory]
#  provisioner "local-exec" {
#    command     = "ansible-playbook install_postgresql.yaml"
#    working_dir = "../ansible"
#  }
#}

