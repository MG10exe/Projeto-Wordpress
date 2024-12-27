resource "google_sql_database_instance" "database" {
  name             = "tutorial-database"
  region           = var.region
  database_version = var.db_settings.engine_version
  settings {
    tier = var.db_settings.tier
    ip_configuration {
      authorized_networks {
          name = "allow-compute-engine"
          value = "10.0.0.0/16"
      }
      require_ssl = true
    }
  }

  deletion_protection = var.db_settings.deletion_protection
}

resource "google_sql_database" "database" {
  name       = var.db_settings.database_name
  instance = google_sql_database_instance.database.name
}

resource "google_sql_user" "users" {
  name     = var.db_settings.root_username
  instance = google_sql_database_instance.database.name
  password = var.db_settings.root_password
}