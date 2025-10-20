job "knime" {
  datacenters = ["dc1"]
  type = "service"

  group "knime-group" {
    network {
      port "http" {
        static = 7080
      }
    }

    update {
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "20m"
      progress_deadline = "25m"
    }

    task "knime-task" {
      driver = "docker"

      config {
        image = "knime/knime:r-5.8.0-402"
        ports = ["http"]
      }

      resources {
        cpu    = 2000
        memory = 8192
      }

      env {
        JAVA_OPTS = "-Xmx4G"

      }

      service {
        name = "knime"
        port = "http"

        check {
          type           = "http"
          path           = "/health"
          interval       = "60s"
          timeout        = "10s"
          initial_status = "critical"
        }
      }
    }
  }
}
