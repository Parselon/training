# Ejercicio 1
Luego de leer las instrucciones en las secciones `Hosting some simple static content` y `Exposing external port` en la [documentación](https://hub.docker.com/_/nginx) de Nginx, se creó la página en `html/index.html` y necesitamos montar la carpeta html como volumen y mapear un puerto para poder acceder. El comando es:

```bash
docker run --name ejercicio1 -d -p 8080:80 -v $PWD/html:/usr/share/nginx/html:ro -d nginx
```

La secuencia completa del ejercicio:

```bash
$ docker run --name ejercicio1 -d -p 8080:80 -v $PWD/html:/usr/share/nginx/html:ro -d nginx
96bdb02e885043d5cb496e7da622dc2b1b89c8ebcf23fed92c9716b549ad96b2

$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS          PORTS                       NAMES
96bdb02e8850   nginx                  "/docker-entrypoint.…"   6 seconds ago   Up 5 seconds    0.0.0.0:8080->80/tcp        ejercicio1

$ curl http://localhost:8080
<!DOCTYPE html>
<head>
  <title>Ejercicio 1</title>
</head>

<body>
  <h1>Onapsis: Matias</h1>
</body>
</html>
```