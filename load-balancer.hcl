job "demo-saul-load-balancer" {
  namespace = "default"
  type      = "batch"
  region    = "global"
  id        = "demo-saul-load-balancer"
  priority  = "50"

  group "loadBalancer" {

    count = 1

    reschedule {
      attempts  = 0
      unlimited = false
    }

    network {

      port "api" {
        to = 5000  # -1 will assign random port
      }

      port "http" {
        static = 8080
      }

    }

    service {
      name = "demo-back"
      port = "api"
    }

    service {
      name = "demo-saul-load-balancer"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.demo-saul-load-balancer.tls=true",
        "traefik.http.routers.demo-saul-load-balancer.rule=Host(`api-demo-saul-load-balancer.${meta.domain}-deployments.cloud.ai4eosc.eu`, `www.api-demo-saul-load-balancer.${meta.domain}-deployments.cloud.ai4eosc.eu`)",
      ]
    }

    ephemeral_disk {
      size = 500
    }

    task "usertask-1" {

      driver = "docker"

      config {
        image    = "deephdc/deep-oc-image-classification-tf:latest"
        command  = "timeout"
        args    = ["--preserve-status", "3000s", "deep-start", "--deepaas"]
        ports    = ["api"]
        shm_size = 1000000000
      }

      resources {
        cores  = 4
        memory = 4000
      }

      restart {
        attempts = 0
        mode     = "fail"
      }

    }

    task "usertask-2" {

      driver = "docker"

      config {
        image    = "deephdc/deep-oc-image-classification-tf:latest"
        command  = "timeout"
        args    = ["--preserve-status", "3000s", "deep-start", "--deepaas"]
        ports    = ["api"]
        shm_size = 1000000000
      }

      resources {
        cores  = 4
        memory = 4000
      }

      restart {
        attempts = 0
        mode     = "fail"
      }

    }

    task "nginx" {
      driver = "docker"

      config {
        image = "sftobias/autoexit-nginx:latest"
        ports = ["http"]
        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
          upstream backend {
          {{ range service "demo-back" }}
            server {{ .Address }}:{{ .Port }};
          {{ else }}server 127.0.0.1:65535; # force a 502
          {{ end }}
          }

          server {
            listen 8080;

            location / {
                proxy_pass http://backend;
            }
          }
          EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cores  = 4
        memory = 4000
      }

      restart {
        attempts = 1
        mode     = "fail"
      }

    }

  }

}