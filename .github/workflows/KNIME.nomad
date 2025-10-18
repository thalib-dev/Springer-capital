job "knime" {
  datacenters = ["dc1"]
  type = "service"

  group "knime-group" {
    task "knime-task" {
      driver = "docker"

      config {
        image = "knime/knime-server:latest"
        port_map {
          http = 8080
        }
      }

      resources {
        cpu    = 500
        memory = 512
        network {
          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "knime"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
