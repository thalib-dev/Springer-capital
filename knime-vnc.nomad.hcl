job "knime-vnc" {
  datacenters = ["dc1"]
  type        = "service"

  group "knime-group" {
    count = 1

    network {
      port "vnc" {
        static = 5901
      }
      port "web" {
        static = 6080
      }
    }

    task "knime-vnc" {
      driver = "docker"

      config {
        image = "openkbs/knime-vnc-docker:latest"
        ports = ["vnc", "web"]
        volumes = [
          "/opt/knime_data:/home/developer/workspace"
        ]
      }

      resources {
        cpu    = 4000
        memory = 4096
      }

      env {
        USER = "developer"
        VNC_PASSWORD = "knime"
        RESOLUTION = "1280x800"
      }

      service {
        name = "knime-vnc"
        port = "web"
        tags = ["vnc", "gui", "knime"]
      }
    }
  }
}

