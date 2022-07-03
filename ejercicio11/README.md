# Ejercicio11

Cree un namespace y modifique el context para usar el namespace `ejercicio11`. Utilice `microk8s` que ya lo tengo instalado.
Se crearon los configmaps y el secret. Para el secret decidi usar `stringData` en vez de data para probarlo (en vez de poner el base64), despues de aplicar los archivos verifique los datos:
```bash
$ kubectl create namespace ejercicio11
namespace/ejercicio11 created

$ kubectl config set-context --current --namespace=ejercicio11
Context "microk8s" modified.

$ ls
configmap1.yml  configmap2.yml  deployment.yml  README.md  secret1.yml  service.yml

$ kubectl apply -f configmap1.yml
configmap/ejercicio11-c1 created

$ kubectl apply -f configmap2.yml
configmap/ejercicio11-c2 created

$ kubectl apply -f secret1.yml 
secret/ejercicio11-s1 created

$ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-6jjrb   kubernetes.io/service-account-token   3      8m40s
ejercicio11-s1        Opaque                                1      27s

$ kubectl get secret ejercicio11-s1 -ojson
{
    "apiVersion": "v1",
    "data": {
        "secret.json": "eyJteXBhc3MiOiJwYXNzd29yZCEifQ=="
    },
    "kind": "Secret",
    "metadata": {
        "annotations": {
            "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Secret\",\"metadata\":{\"annotations\":{},\"labels\":{\"app\":\"ejercicio11\"},\"name\":\"ejercicio11-s1\",\"namespace\":\"ejercicio11\"},\"stringData\":{\"secret.json\":\"{\\\"mypass\\\":\\\"password!\\\"}\"},\"type\":\"Opaque\"}\n"
        },
        "creationTimestamp": "2022-07-03T22:03:21Z",
        "labels": {
            "app": "ejercicio11"
        },
        "name": "ejercicio11-s1",
        "namespace": "ejercicio11",
        "resourceVersion": "9428012",
        "selfLink": "/api/v1/namespaces/ejercicio11/secrets/ejercicio11-s1",
        "uid": "d7b808e4-d7f0-414a-8352-2158de0f9a0b"
    },
    "type": "Opaque"
}

$ echo eyJteXBhc3MiOiJwYXNzd29yZCEifQ== | base64 --decode
{"mypass":"password!"}
```

Luego cree el deployment leyendo [como montar un configmap como volumen](https://kubernetes.io/es/docs/concepts/configuration/configmap/#usando-configmaps-como-ficheros-en-un-pod) y [como montar un secret como volumen](https://kubernetes.io/es/docs/concepts/configuration/secret/#usando-secrets-como-archivos-de-un-pod) y aplique:
```bash
$ kubectl apply -f deployment.yml 
deployment.apps/ejercicio11 created

$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
ejercicio11-5f54989dfc-9gjct   1/1     Running   0          107s
ejercicio11-5f54989dfc-pdhjh   1/1     Running   0          107s
ejercicio11-5f54989dfc-6xfkc   1/1     Running   0          107s
```

Luego para crear el service entre a un pod y lei el README.md para ver que puerto exponia, y luego elegi el NodePort 30456
```bash
$ kubectl apply -f service.yml 
service/ejercicio11 created

$ kubectl get svc
NAME          TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
ejercicio11   NodePort   10.152.183.186   <none>        4567:30456/TCP   11s
```

Al terminar de eployar todo verifique que todo funcione:
```bash
$ curl localhost:30456/config
{"key1": "value1"}

$ curl localhost:30456/secrets
{"mypass":"password!"}
```

# Probando editar
Una cosa que me parecio interesante fue que un configmap montado como volumen se actualiza cuando cambia (el tiempo depende de varios factores): https://kubernetes.io/es/docs/concepts/configuration/configmap/#configmaps-montados-son-actualizados-autom%C3%A1ticamente

Entonces edite el configmap y despues de unos segundos pude ver que el cambio se realizo (modifique `value1` por `prueba-edit`):
```bash

$ kubectl edit cm ejercicio11-c2
configmap/ejercicio11-c2 edited

$ curl localhost:30456/config
{"key1": "value1"}
$ curl localhost:30456/config
{"key1": "value1"}
$ curl localhost:30456/config
{"key1": "value1"}
$ curl localhost:30456/config
{"key1": "value1"}
$ curl localhost:30456/config
{"key1": "prueba-edit"}
$ 
```
