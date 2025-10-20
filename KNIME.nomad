job "knime" {
  datacenters = ["dc1"]
  type = "service"

  group "knime-group" {
    network {
      port "http" {
        static = 8080
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
        cpu    = 500
        memory = 512
      }

      service {
        name = "knime"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "20s"
          timeout  = "5s"
          initial_status = "passing"
        }
      }
    }
  }
}
