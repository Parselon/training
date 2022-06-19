# Ejercicio 7

Se descargó el yaml para docker compose y se le puso de nombre `job-vacancy.yml`

Luego lo ejecuté con
```bash
$ docker-compose -f job-vacancy.yml up
```

![compose](compose.png)

* Se están ejecutando 2 containers, son los numeros de `services` definidos en el YAML (`web` y `db`).
Tambien pueden verse con `docker ps` una vez levantado:
```bash
$ docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS         PORTS                       NAMES
01fffda229a7   nicopaez/jobvacancy-ruby:1.3.0   "/jobvacancy/start_a…"   10 seconds ago   Up 9 seconds   0.0.0.0:3000->3000/tcp      ejercicio07_web_1
83d19db9d7a2   postgres                         "docker-entrypoint.s…"   10 seconds ago   Up 9 seconds   5432/tcp                    ejercicio07_db_1

```

* Las imagenes estan definidas dentro de la key `image` dentro de cada service en el YAML, para `web` usa `nicopaez/jobvacancy-ruby:1.3.0` y para `db` usa `postgres`

* Descripcion del YAML
```yml
# Version para el formato de este archivo 
# https://docs.docker.com/compose/compose-file/compose-versioning/
version: '2' 
# Defino los servicios que definen mi aplicacion
# https://docs.docker.com/compose/compose-file/#services-top-level-element
services:
  # Nombre del servicio, y si no se especifica `container_name` es el nombre del container https://docs.docker.com/compose/compose-file/#container_name
  web:
    # La imagen para crear el container https://docs.docker.com/compose/compose-file/#image
    image: nicopaez/jobvacancy-ruby:1.3.0
    # Define una forma de acceder a containers de otro servicio a traves del nombre https://docs.docker.com/compose/compose-file/#links
    links:
      - db
    # Expone puertos, vinculando puerto del host y del container
    # https://docs.docker.com/compose/compose-file/#ports
    ports:
      - "3000:3000"
    # Define las variables de entorno para el contenedor
    # https://docs.docker.com/compose/compose-file/#environment
    environment:
      PORT: "3000"
      RACK_ENV: "production"
      DATABASE_URL: "postgres://postgres:Passw0rd!@db:5432/postgres"
    # Indica que el servicio `db` debe estar up para poder arrancar este servicio
    # https://docs.docker.com/compose/compose-file/#depends_on
    depends_on:
      - db
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: Passw0rd!
```

* Los contenedores se levantan en una misma network que es creada por compose, si no se especifica se levantan ésta la network por defecto. Por lo tanto pueden verse entre si, ya que todos los containers en la misma network se veran.
En el log de `docker-compose ... up` puede verse como se crea la network y como adjunta los containers a ésta network creada:
```bash
Creating network "ejercicio07_default" with the default driver
Creating ejercicio07_db_1 ... done
Creating ejercicio07_web_1 ... done
Attaching to ejercicio07_db_1, ejercicio07_web_1
```

Tambien busque como inspeccionar una network y ver que containers tiene:
```bash
$ docker network inspect ejercicio07_default -f "{{json .Containers }}" | jq
{
  "01fffda229a70c88d7f7963d3854c7f8cf3e1ef0d84ebaaeddad48e2f0073434": {
    "Name": "ejercicio07_web_1",
    "EndpointID": "49f0cc905349c15566fe1dc5d0e886a68985b0740769856fff407e49a3e29766",
    "MacAddress": "02:42:ac:14:00:03",
    "IPv4Address": "172.20.0.3/16",
    "IPv6Address": ""
  },
  "83d19db9d7a21622d419ef6a485009d119ef0909568081fcee645191f3274dc7": {
    "Name": "ejercicio07_db_1",
    "EndpointID": "e6ccea87f744840d0007d4c27a94e61fec0535955af6f0350d3b308b2feb35ab",
    "MacAddress": "02:42:ac:14:00:02",
    "IPv4Address": "172.20.0.2/16",
    "IPv6Address": ""
  }
}

```