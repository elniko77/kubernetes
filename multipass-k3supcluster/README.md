##### multipass-k3supcluster #####

Este es un script para instalar un cluster kubernetes con k3sup (https://github.com/alexellis/k3sup)
El script está configurado para crear un master y dos nodos, y está pensado para ser usado con la herramienta multipass de canonical (https://multipass.run/), por ahora probando en Windows 10 Pro, con hyper-v de backend.


Se ejecuta desde una terminal de wsl, como 

    $ ./crear_cluster.sh

Para usarlo se debe configurar la variable de entorno para leer la config:

    $ export KUBECONFIG=kubeconfig
    $ kubectl get node -o wide
