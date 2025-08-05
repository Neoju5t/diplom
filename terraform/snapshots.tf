resource "yandex_compute_snapshot_schedule" "daily_snapshots" {
  name        = "daily-backup"
  description = "Daily snapshot schedule for all VMs"

  schedule_policy {
    expression = "0 3 * * *" # каждый день в 03:00 по UTC
  }

  snapshot_spec {
    description = "Automated snapshot"
  }

  snapshot_count   = 7
  retention_period = "168h" # 7 дней = 168 часов

  disk_ids = flatten([
    [for instance in yandex_compute_instance.web : instance.boot_disk[0].disk_id],
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id,
    yandex_compute_instance.elastic.boot_disk[0].disk_id
  ])
}