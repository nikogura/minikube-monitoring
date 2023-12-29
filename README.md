# minikube-monitoring

A scaled down kube-prometheus stack with Promtail and Loki that can run inside of Minikube for evaluation/exploration purposes.

# Requirements

1. [minikube](https://minikube.sigs.k8s.io/docs/)
2. [jsonnet](https://jsonnet.org/)
3. [gojson2yaml](https://github.com/brancz/gojsontoyaml) 

## Minikube Components

Run the following to start Minikube:

    minikube start --insecure-registry="192.168.49.2:5000"
    minikube addons enable registry
    minikube addons enable ingress
    minikube addons enable metrics-server


# Metrics Stack

## `make pave` - run all resources

## `make nuke` - remove all resources

# Accessing Services

You'll need to port-forward the following to access Prometheus, AlertManager, and Grafana:

* Grafana: svc/grafana 3000

* Prometheus: svc/prometheus-k8s 9090

* AlertManager: svc/alertmanager-main 9093
