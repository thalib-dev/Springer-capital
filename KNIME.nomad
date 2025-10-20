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
      min_healthy_time  = "30s"
      healthy_deadline  = "10m"
      progress_deadline = "15m"
    }

    task "knime-task" {
      driver = "docker"

      config {
        image = "knime/knime-server:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 1000
        memory = 4096
      }

      service {
        name = "knime"
        port = "http"

        check {
          type     = "http"
          path     = "/knime"
          interval = "20s"
          timeout  = "5s"
          initial_status = "passing"
        }
      }
    }
  }
}
