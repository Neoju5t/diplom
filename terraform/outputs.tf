output "bastion_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_ips" {
  value = [
    yandex_compute_instance.web[0].network_interface[0].ip_address,
    yandex_compute_instance.web[1].network_interface[0].ip_address
  ]
}

output "alb_ip" {
 value = try(
    yandex_alb_load_balancer.balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address,
    "not_created"
  ) 
  depends_on = [
    yandex_alb_load_balancer.balancer
  ]
}

output "kibana_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].ip_address
}

output "zabbix_ip" {
  value = yandex_compute_instance.zabbix.network_interface[0].ip_address
}

output "elastic_ip" {
  value = yandex_compute_instance.elastic.network_interface[0].ip_address
  depends_on = [yandex_vpc_subnet.private_subnet_b]
}
