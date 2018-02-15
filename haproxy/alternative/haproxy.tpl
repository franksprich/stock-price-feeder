global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  chroot /var/lib/haproxy
  user haproxy
  group haproxy

defaults
  log global
  mode http
  option httplog
  option dontlognull
  balance roundrobin
  timeout connect 5000
  timeout client 50000
  timeout server 50000
  errorfile 400 /etc/haproxy/errors/400.http
  errorfile 403 /etc/haproxy/errors/403.http
  errorfile 408 /etc/haproxy/errors/408.http
  errorfile 500 /etc/haproxy/errors/500.http
  errorfile 502 /etc/haproxy/errors/502.http
  errorfile 503 /etc/haproxy/errors/503.http
  errorfile 504 /etc/haproxy/errors/504.http

listen stats
  bind *:8001
  stats enable
  stats uri /
  stats auth admin:123123q
  stats realm HAProxy\ Statistics

frontend master-data-app
  bind *:1080
  mode http
  default_backend master-data-app-backend

frontend nb-back
  bind *:1081
  mode http
  default_backend nb-backend

backend master-data-app-backend
    balance roundrobin{{range service "master-data-app"}}
    server {{.Node}} {{.Address}}:{{.Port}} check{{end}}

backend nb-backend
   balance roundrobin{{range service "backend-service"}}
   server {{.Node}} {{.Address}}:{{.Port}} check{{end}}
