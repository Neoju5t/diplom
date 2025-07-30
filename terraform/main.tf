# Сеть
resource "yandex_vpc_network" "diploma_net" {
  name = "diploma-network"
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma_net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Приватная подсеть
resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diploma_net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

# NAT gateway
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  network_id = yandex_vpc_network.diploma_net.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Security Group для Бастиона
resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "bastion-sg"
  network_id  = yandex_vpc_network.diploma_net.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["192.168.0.0/16"]
  }
  
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Бастион хост
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jfh73rvks3qlqp3ck" # Ubuntu 24.04
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

# Веб-сервера (2 шт)
resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-${count.index}"
  hostname    = "web-${count.index}.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jfh73rvks3qlqp3ck"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

# ВМ для Elasticsearch 
resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jfh73rvks3qlqp3ck" # Ubuntu 24.04
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elastic_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

# ВМ для Kibana 
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jfh73rvks3qlqp3ck"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

# ВМ для Zabbix 
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jfh73rvks3qlqp3ck"
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

# Security Group для Elasticsearch
resource "yandex_vpc_security_group" "elastic_sg" {
  name        = "elastic-sg"
  network_id  = yandex_vpc_network.diploma_net.id

# Разрешаем SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9300
    v4_cidr_blocks = ["192.168.20.0/24"]
  }
  
  ingress {
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["192.168.0.0/16"]
  }
  
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Kibana
resource "yandex_vpc_security_group" "kibana_sg" {
  name        = "kibana-sg"
  network_id  = yandex_vpc_network.diploma_net.id

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Разрешаем SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
  }
  
  ingress {
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["192.168.0.0/16"]
  }
  
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Zabbix
resource "yandex_vpc_security_group" "zabbix_sg" {
  name        = "zabbix-sg"
  network_id  = yandex_vpc_network.diploma_net.id

# Разрешаем SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["192.168.0.0/16"]
  }
  
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Балансировщика (исправленная)
resource "yandex_vpc_security_group" "balancer_sg" {
  name        = "balancer-sg"
  network_id  = yandex_vpc_network.diploma_net.id

  # Разрешаем HTTP от клиентов
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешаем health checks от Yandex (обязательное правило)
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  # Разрешаем health checks на порт 30080 (дополнительно)
  ingress {
    protocol       = "TCP"
    port           = 30080
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Веб-серверов (добавляем правило для health checks)
resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-sg"
  network_id  = yandex_vpc_network.diploma_net.id

  # Разрешаем трафик от балансировщика
  ingress {
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.balancer_sg.id
  }

  # Разрешаем health checks от Yandex (добавлено)
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  # Разрешаем SSH от бастиона
  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }
  
  ingress {
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["192.168.0.0/16"]
  }
  
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# HTTP Роутер 
resource "yandex_alb_http_router" "web_router" {
  name = "web-router"
}

# Целевая группа для балансировщика
resource "yandex_alb_target_group" "web_group" {
  name = "web-target-group"
  
  target {
    subnet_id  = yandex_vpc_subnet.private_subnet.id
    ip_address = yandex_compute_instance.web[0].network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private_subnet.id
    ip_address = yandex_compute_instance.web[1].network_interface[0].ip_address
  }
}

# Группа бэкендов
resource "yandex_alb_backend_group" "web_backend" {
  name = "web-backend-group"
  
  http_backend {
    name             = "http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_group.id]
    
    healthcheck {
      interval = "2s"
      timeout  = "1s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# Виртуальный хост
resource "yandex_alb_virtual_host" "web_vhost" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web_router.id
  
  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend.id
        timeout          = "3s"
      }
    }
  }
}

# Балансировщик (ALB)
resource "yandex_alb_load_balancer" "balancer" {
  name               = "web-balancer"
  network_id         = yandex_vpc_network.diploma_net.id
  security_group_ids = [yandex_vpc_security_group.balancer_sg.id]

allocation_policy {
  location {
    zone_id   = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.public_subnet.id
  }
  location {
    zone_id   = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private_subnet.id 
  }
}

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}