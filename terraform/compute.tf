resource "yandex_compute_instance" "salt-master" {
  name                      = "salt-master"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[1]
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("cloud-init-salt-master.yaml")}"
  }
}

resource "yandex_compute_instance" "lb" {
  count                     = 1
  name                      = "lb${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
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
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    #user-data = "#cloud-config\nhostname: lb${count.index}\nwrite_files:\n- path: /etc/salt/minion\n  encoding: b64\n  content: ${base64encode("startup_states: highstate\nmaster:\n- ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n")}\n- path: /etc/salt/minion.d/id.conf\n  encoding: b64\n  content: ${base64encode("id: lb${count.index}")}\n${file("cloud-init-salt-minion.yaml")}"
    user-data = "${file("cloud-init-salt-minion.yaml")}\n- path: /etc/salt/minion\n  defer: true\n  permissions: '0644'\n  owner: salt:salt\n  content: |\n    startup_states: highstate\n    master:\n    - ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n    id: lb${count.index}\nhostname: lb${count.index}"
  }
}

resource "yandex_compute_instance" "db" {
  count                     = 1
  name                      = "db${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[2 - count.index % length(var.yc_zones)]
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
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
    subnet_id = yandex_vpc_subnet.yc_subnet[2- count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    #user-data = "#cloud-config\nhostname: db${count.index}\nwrite_files:\n- path: /etc/salt/minion\n  encoding: b64\n  content: ${base64encode("startup_states: highstate\nmaster:\n- ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n")}\n- path: /etc/salt/minion.d/id.conf\n  content: >\n    id: db${count.index}\n- path: /etc/salt/minion.d/mysql.conf\n  defer: true\n  permissions: '0644'\n  owner: salt:salt\n  encoding: b64\n  content: ${base64encode("mysql.unix_socket: /run/mysqld/mysqld.sock")}\n${file("cloud-init-salt-minion.yaml")}"
    user-data = "${file("cloud-init-salt-minion.yaml")}\n- path: /etc/salt/minion\n  defer: true\n  permissions: '0644'\n  owner: salt:salt\n  content: |\n    startup_states: highstate\n    master:\n    - ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n    id: db${count.index}\n    mysql.unix_socket: /run/mysqld/mysqld.sock\nhostname: db${count.index}"
  }
}

resource "yandex_compute_instance" "app" {
  count                     = 2
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    #user-data = "#cloud-config\nhostname: app${count.index}\nwrite_files:\n- path: /etc/salt/minion\n  encoding: b64\n  content: ${base64encode("startup_states: highstate\nmaster:\n- ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n")}\n- path: /etc/salt/minion.d/id.conf\n  encoding: b64\n  content: ${base64encode("id: app${count.index}")}\n${file("cloud-init-salt-minion.yaml")}"
    user-data = "${file("cloud-init-salt-minion.yaml")}\n- path: /etc/salt/minion\n  defer: true\n  permissions: '0644'\n  owner: salt:salt\n  content: |\n    startup_states: highstate\n    master:\n    - ${yandex_compute_instance.salt-master.network_interface[0].ip_address}\n    id: app${count.index}\nhostname: app${count.index}"
  }
}
