# Ejercicio 08

Primero lei un poco de como funciona Nginx [como balanceador](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer) para determinar la mejor configuracion.
Segun lo visto, seria el metodo round-robin (por defecto).
Lei en la documentacion oficial de la imagen de nginx como montar el archivo de configuracion: [https://hub.docker.com/_/nginx](https://hub.docker.com/_/nginx) seccion `Complex Configuration`.
Tambien tuve que leer un poco porque me faltaba el `events` en la configuracion.

En el docker compose exponen 2 servicios de paswordapi (`passwordapi1` y `passwordapi2`).
En el archivo de configuracion de nginx se hace referencia a estos nombres y sus respectivos puertos (`3000`), y para asegurarse que puedan conmunicarse a tarves de ese alias agregue el apartado `links` en el servicio de `nginx`, que se expone el el puerto `8080`.
Tambien se monta el archivo de configuracion con `volumes`

Al el compose y hacer una pruebas con curl al endpoint del enunciado:
```bash
$ docker-compose -f nginx-balancer-passwordapi.yml up
Starting ejercicio08_passwordapi2_1 ... done
Starting ejercicio08_passwordapi1_1 ... done
Starting ejercicio08_nginx_1        ... done
Attaching to ejercicio08_passwordapi2_1, ejercicio08_passwordapi1_1, ejercicio08_nginx_1
nginx_1         | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
nginx_1         | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
nginx_1         | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
nginx_1         | 10-listen-on-ipv6-by-default.sh: info: ipv6 not available
nginx_1         | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
nginx_1         | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
nginx_1         | /docker-entrypoint.sh: Configuration complete; ready for start up
passwordapi2_1  | 
passwordapi2_1  | > passwordapi@1.0.0 start /usr/src/app
passwordapi2_1  | > node ./lib/server.js
passwordapi2_1  | 
passwordapi1_1  | 
passwordapi1_1  | > passwordapi@1.0.0 start /usr/src/app
passwordapi1_1  | > node ./lib/server.js
passwordapi1_1  | 
passwordapi2_1  | App running on port: 3000
passwordapi1_1  | App running on port: 3000
nginx_1         | 172.18.0.1 - - [25/Jun/2022:18:56:27 +0000] "GET /health HTTP/1.1" 200 119 "-" "curl/7.68.0"
nginx_1         | 172.18.0.1 - - [25/Jun/2022:18:56:28 +0000] "GET /health HTTP/1.1" 200 119 "-" "curl/7.68.0"
nginx_1         | 172.18.0.1 - - [25/Jun/2022:18:56:29 +0000] "GET /health HTTP/1.1" 200 119 "-" "curl/7.68.0"
nginx_1         | 172.18.0.1 - - [25/Jun/2022:18:56:30 +0000] "GET /health HTTP/1.1" 200 119 "-" "curl/7.68.0"
nginx_1         | 172.18.0.1 - - [25/Jun/2022:18:56:31 +0000] "GET /health HTTP/1.1" 200 119 "-" "curl/7.68.0"
```

Puedo ver como responden los dos hosts diferentes:
```bash
$ curl localhost:8080/health
{"host":"cb609d96c55c","loadavg":[1.79296875,1.6376953125,1.509765625],"freemem":6006157312,"appversion":"1.0.0"}
$ curl localhost:8080/health
{"host":"7281ab2b47fe","loadavg":[1.79296875,1.6376953125,1.509765625],"freemem":6103093248,"appversion":"1.0.0"}
$ curl localhost:8080/health
{"host":"cb609d96c55c","loadavg":[1.72900390625,1.626953125,1.5068359375],"freemem":6090403840,"appversion":"1.0.0"}
$ curl localhost:8080/health
{"host":"7281ab2b47fe","loadavg":[1.72900390625,1.626953125,1.5068359375],"freemem":6083031040,"appversion":"1.0.0"}
$ curl localhost:8080/health
{"host":"cb609d96c55c","loadavg":[1.72900390625,1.626953125,1.5068359375],"freemem":6096199680,"appversion":"1.0.0"}
$ 
```

Puedo ver los containers ejecutandose, y como el id del container coincide con el del host:
```bash
$ docker ps
CONTAINER ID   IMAGE                                                                     COMMAND                  CREATED          STATUS          PORTS                                                                                                                                  NAMES
c94069855311   nginx:1.23.0                                                              "/docker-entrypoint.…"   25 minutes ago   Up 15 minutes   0.0.0.0:8080->80/tcp                                                                                                                   ejercicio08_nginx_1
cb609d96c55c   nicopaez/password-api:latest                                              "npm start"              25 minutes ago   Up 15 minutes   3000/tcp                                                                                                                               ejercicio08_passwordapi2_1
7281ab2b47fe   nicopaez/password-api:latest                                              "npm start"              25 minutes ago   Up 15 minutes   3000/tcp                                                                                                                               ejercicio08_passwordapi1_1

```