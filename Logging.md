# Fluent Bit Integration Guide

This guide outlines the steps to integrate Fluent Bit for log management in Kubernetes environment, focusing on middleware, local-controller and container logs.

## Introduction to Logging

- **Categories**: INFO, DEBUG, ERROR, and CRITICAL.
- **Implementation**: Logging statements added in both the controller and middleware.
- **Logging Level**: Set to DEBUG for comprehensive log collection.
- **Log Files**: Individual `out.log` files for middleware and controller.

## 2. Setting Up Fluent Bit

- **Install Helm**
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

- **Add the Fluent Helm Charts repo**
helm repo add fluent https://fluent.github.io/helm-charts

- **Install default Fluent Bit chart**
helm upgrade --install fluent-bit fluent/fluent-bit

- **Modify the default Fluent Bit ConfigMap to collect specific logs:**
```yaml
[INPUT]
   Name tail
   Path /home/k8s-user/middleware/out.log
   Parser docker
   Tag middleware
   Refresh_Interval 10

[INPUT]
   Name tail
   Path /home/k8s-user/local-controller/out.log
   Parser docker_no_time
   Tag local-controller
   Refresh_Interval 10

[FILTER]
   Name grep
   Match local-controller
   Regex log ^(.*scaling up.*|.*scaling down.*)$

[OUTPUT]
    Name stdout
    Match *
    Format json
    Json_date_key timestamp
    Json_date_format iso8601

- **Update the daemonset.yaml to include necessary volume mounts:**
```yaml
- mountPath: /home/k8s-user/middleware 
  name: middleware-logs
  readOnly: true

- mountPath: /home/k8s-user/local-controller
  name: localcontroller-logs
  readOnly: true

- hostPath:
    path: /home/k8s-user/middleware
    type: “”
    name: middleware-logs

- hostPath:
    path: /home/k8s-user/local-controller
    type: “”
    name: localcontroller-logs

- **Apply the updated DaemonSet configuration with Kubernetes:**
kubectl apply -f fluent-bit-ds.yaml

- **Check Fluent Bit pods and their logs:**
kubectl get pods -n default
kubectl logs <fluent-bit-pod-name> -n default
