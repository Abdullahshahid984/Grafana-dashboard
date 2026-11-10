  # Backup interval comes from conf.yaml (backup_interval_hours)
  backup_repeating_time_intervals = ["R/2026-01-01T00:00:00+00:00/PT${each.value.interval_hours}H"]

  default_retention_rule {
    life_cycle {
      duration        = "P${each.value.retention_days}D"
      data_store_type = "OperationalStore"
    }
  }
