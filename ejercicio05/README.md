# HEALTHCHECK

Estuve leyendo la documentacion oficial de [healthcheck](https://docs.docker.com/engine/reference/builder/#healthcheck) y sirve para indicarle como chequear la aplicación del container para determinar si está funcionando, incluso si el proceso está ejecutándose.
Se provee un comando `CMD` con algunas opciones que permite configurar cuando y cada tanto se ejecuta.

Hice algunas pruebas con el dockerfile del ejercicio anterior para ver como funcionaba.
* Healthcheck OK
Agregue al Dockerfile:
```
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 CMD [ "curl", "http://localhost:8080/password/"]
```
Luego generá la imagen y ejecuté un container, luego me fijé el estado:
```bash
$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED              STATUS                        PORTS                       NAMES
debddf1ef12a   passwordapi                         "java -jar passworda…"   About a minute ago   Up About a minute (healthy)                               youthful_benz
```

* Healthcheck Bad
Agregue al Dockerfile algo que yo sabía que podía dar mal, como el puerto
```
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 CMD [ "curl", "http://localhost:8090/bad/"]
```
Actualice la misma imagen generando el build y luego ejecute un container.
Vi como le setea el STATUS luego de unos segundos:
```bash
$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS                      PORTS                       NAMES
70700da28f16   passwordapi            "java -jar passworda…"   39 seconds ago   Up 39 seconds (unhealthy)   0.0.0.0:8080->8080/tcp      silly_herschel
```

En estado `unhealthy` probé si se podía acceder o si respondia, y se puede acceder normalmente, por lo que solamente le marca el estado al container y no afecta el funcionamiento.

# ONBUILD

Se leyo la documentacion oficial [onbuild](https://docs.docker.com/engine/reference/builder/#onbuild).
Sirve para ejecutar cualquier instruccion mas tarde, sirviendo para generar imagenes reutilizables que sirvan como imagenes base.
De lo que entendi, en la practica se puede usar para añadir instrucciones de build aunque todavia no este la aplicacion disponible, se usa esta imagen base para agregar la aplicacion y en el build se ejecutaran las instrucciones.
Trate de ampliar un poco leyendo en esta pagina un caso de uso [https://www.linuxsysadmin.ml/2017/08/creando-imagenes-con-estilo-la-instruccion-onbuild.html](https://www.linuxsysadmin.ml/2017/08/creando-imagenes-con-estilo-la-instruccion-onbuild.html)

También busqué algun ejemplo de como se usa: [https://github.com/finn-no/node-docker/blob/master/Dockerfile.onbuild](https://github.com/finn-no/node-docker/blob/master/Dockerfile.onbuild)


# VOLUME
Se leyo la documentacion oficial [volume](https://docs.docker.com/engine/reference/builder/#volume).
Basicamente nos permite montar un directorio usando otro de nuestro host, lo que nos va a permitir almacenar datos de forma permanente.
Con VOLUME le indicamos a la imagen que debe montar un directorio.
Luego docker run va a inicializar el volumen con el dato que exista.

Hice una prueba para determinar donde estaria en el host el directorio montado, siguiendo el ejemplo que provee la documentacion oficial.

Hice el build del Dockerfile correspondiente y luego ejecute un container:
```bash
$ docker build . -f Dockerfile.volume -t test
Sending build context to Docker daemon  25.44MB
Step 1/4 : FROM python:3.9
 ---> d0ce03c9330c
Step 2/4 : RUN mkdir /myvol
 ---> Running in 256efdaa0388
Removing intermediate container 256efdaa0388
 ---> ce5e0a9bf87e
Step 3/4 : RUN echo "hello world" > /myvol/greeting
 ---> Running in 61e57410144d
Removing intermediate container 61e57410144d
 ---> 8991dd72758c
Step 4/4 : VOLUME /myvol
 ---> Running in 99221010bfa5
Removing intermediate container 99221010bfa5
 ---> ecc7e77c70fd
Successfully built ecc7e77c70fd
Successfully tagged test:latest

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them

$ docker run -it test bash
```

Y luego con `docker inspect` me fije los volumenes montados:

```bash
$ docker inspect 5d052cfe26ac
...
        "Mounts": [
            {
                "Type": "volume",
                "Name": "45e3b74d267e11163ba5730c9e5c23c3e032f14d543bdef5d3e737708ee6a660",
                "Source": "/var/lib/docker/volumes/45e3b74d267e11163ba5730c9e5c23c3e032f14d543bdef5d3e737708ee6a660/_data",
                "Destination": "/myvol",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
...

```