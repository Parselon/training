#! /bin/bash
echo "Ejecutando contenedor"
docker run --name ejercicio1 -d -p 8080:80 -v $PWD/html:/usr/share/nginx/html:ro -d nginx
echo "Abre http://localhost:8080/"