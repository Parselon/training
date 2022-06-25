# Ejercicio 09

### Sobre minikube
Despues de intentar actualizar la version, algo quedo roto con minikube, asique para hacer el ejercicio use microk8s, que ya lo tenia instalado.
```bash
$ minikube start --kubernetes-version=v1.24.1
😄  minikube v1.26.0 on Ubuntu 20.04
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.24.1 preload ...
    > preloaded-images-k8s-v18-v1...: 405.83 MiB / 405.83 MiB  100.00% 12.86 Mi
🔄  Restarting existing docker container for "minikube" ...
❗  This container is having trouble accessing https://k8s.gcr.io
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/

❌  Exiting due to RUNTIME_ENABLE: sudo systemctl enable cri-docker.socket: Process exited with status 1
stdout:

stderr:
Failed to enable unit: Unit file cri-docker.socket does not exist.


╭───────────────────────────────────────────────────────────────────────────────────────────╮
│                                                                                           │
│    😿  If the above advice does not help, please let us know:                             │
│    👉  https://github.com/kubernetes/minikube/issues/new/choose                           │
│                                                                                           │
│    Please run `minikube logs --file=logs.txt` and attach logs.txt to the GitHub issue.    │
│                                                                                           │
╰───────────────────────────────────────────────────────────────────────────────────────────╯

```

### Microk8s
```bash
$ microk8s start
Started.

$ microk8s status
microk8s is running
...
...
```

# Resolucion
Para hacer este ejercicio use el [cheatsheet de kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
Use el CLI para generar el yml para manifest (usando `--dry-run=client` y `-oyaml` para la salida YAML, luego lo escribo en el archivo `> deployment.yml`):
```bash
$ microk8s.kubectl create deployment ejercicio09 --image=nicopaez/password-api --replicas=3 --dry-run=client -oyaml > deployment.yml
```

Luego aplique el manifest:
```bash
$ microk8s.kubectl apply -f deployment.yml 
deployment.apps/ejercicio09 created
```

Despues de esperar a que los pods esten READY, podemos ver el deployment y los pods:
```bash
$ microk8s.kubectl get pods
NAME                                       READY   STATUS    RESTARTS          AGE
ejercicio09-59b56cfc7d-lqncn               1/1     Running   0                 62s
ejercicio09-59b56cfc7d-flvl6               1/1     Running   0                 62s
ejercicio09-59b56cfc7d-4hsbs               1/1     Running   0                 62s

$ microk8s.kubectl get deployments
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
ejercicio09               3/3     3            3           111s

```

Puedo ver los logs, sabiendo que tienen como label `app=ejercicio09`:
```bash
$ microk8s.kubectl logs -l app=ejercicio09

> passwordapi@1.0.0 start /usr/src/app
> node ./lib/server.js

App running on port: 3000

> passwordapi@1.0.0 start /usr/src/app
> node ./lib/server.js

App running on port: 3000

> passwordapi@1.0.0 start /usr/src/app
> node ./lib/server.js

App running on port: 3000
```

Despues segui las instrucciones para comprobar que funcionaba, conectandome al primer pod:
```bash
$ microk8s.kubectl exec -it pod/ejercicio09-59b56cfc7d-lqncn -- bash
root@ejercicio09-59b56cfc7d-lqncn:/usr/src/app# curl localhost:3000/password
{"password":"!823LlOoOo<<"}
root@ejercicio09-59b56cfc7d-lqncn:/usr/src/app# 
```
