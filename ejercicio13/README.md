# Ejercicio 13

Despues de leer la documentacion https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
Configure readiness, liveness y startup.
Primero probe poniendo un puerto cualquiera (3000) para ver como fallaba

```bash
$ kubectl describe pods

Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  51s               default-scheduler  Successfully assigned ejercicio13/ejercicio13-54567c84cf-58h7b to onalap1305
  Warning  Unhealthy  2s (x5 over 42s)  kubelet            Startup probe failed: Get "http://10.1.4.151:3000/actuator/health": dial tcp 10.1.4.151:3000: connect: connection refused
  Normal   Killing    2s                kubelet            Container password-api failed startup probe, will be restarted
```

Busque algun comando para ver directamente todos los eventos

```bash
 kubectl alpha events pod ejercicio13
LAST SEEN                TYPE      REASON              OBJECT                              MESSAGE
10m                      Normal    SuccessfulCreate    ReplicaSet/ejercicio13-7489dbcd6c   Created pod: ejercicio13-7489dbcd6c-hwttg
10m                      Normal    ScalingReplicaSet   Deployment/ejercicio13              Scaled up replica set ejercicio13-7489dbcd6c to 1
10m                      Normal    Scheduled           Pod/ejercicio13-7489dbcd6c-hwttg    Successfully assigned ejercicio13/ejercicio13-7489dbcd6c-hwttg to onalap1305
10m                      Normal    Pulling             Pod/ejercicio13-7489dbcd6c-hwttg    Pulling image "nicopaez/password-api:1.5.0-java"
10m                      Normal    Started             Pod/ejercicio13-7489dbcd6c-hwttg    Started container password-api
10m                      Normal    Pulled              Pod/ejercicio13-7489dbcd6c-hwttg    Successfully pulled image "nicopaez/password-api:1.5.0-java" in 13.01326565s
10m                      Normal    Created             Pod/ejercicio13-7489dbcd6c-hwttg    Created container password-api
8m2s                     Normal    SuccessfulCreate    ReplicaSet/ejercicio13-54567c84cf   Created pod: ejercicio13-54567c84cf-58h7b
8m2s                     Normal    ScalingReplicaSet   Deployment/ejercicio13              Scaled up replica set ejercicio13-54567c84cf to 1
8m2s                     Normal    Scheduled           Pod/ejercicio13-54567c84cf-58h7b    Successfully assigned ejercicio13/ejercicio13-54567c84cf-58h7b to onalap1305
6m49s (x21 over 10m)     Warning   Unhealthy           Pod/ejercicio13-7489dbcd6c-hwttg    Startup probe failed: Get "http://10.1.4.160:3000/actuator/health": dial tcp 10.1.4.160:3000: connect: connection refused
6m23s                    Normal    ScalingReplicaSet   Deployment/ejercicio13              Scaled down replica set ejercicio13-7489dbcd6c to 0
6m23s                    Normal    SuccessfulDelete    ReplicaSet/ejercicio13-7489dbcd6c   Deleted pod: ejercicio13-7489dbcd6c-hwttg
6m23s                    Normal    SuccessfulCreate    ReplicaSet/ejercicio13-7cdbf8fdcb   Created pod: ejercicio13-7cdbf8fdcb-mvdt2
```

Luego cambie el puerto por el 8080 y no veo los eventos OK, no encontre como mirarlos, pero el pod esta ok:
```bash
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
ejercicio13-7cdbf8fdcb-mvdt2   1/1     Running   0          9m37s
```